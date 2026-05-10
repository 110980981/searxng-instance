@echo off
chcp 65001 >nul
REM SearXNG 付费模式启动脚本 (Windows)
REM 使用方式: start-paid.bat

set SCRIPT_DIR=%~dp0
set CONFIG_FILE=%SCRIPT_DIR%config\settings-paid.yml
set RESOLVED_CONFIG=%SCRIPT_DIR%config\.settings-paid.yml
set SEARXNG_SECRET=%SEARXNG_SECRET%
if not defined SEARXNG_SECRET set SEARXNG_SECRET=ultrasecretkey

REM 加载 .env（跳过注释和空行）
if exist "%SCRIPT_DIR%.env" (
    echo [SearXNG Paid] 加载 .env 环境变量...
    for /f "usebackq tokens=1* delims==" %%a in (`type "%SCRIPT_DIR%.env" ^| findstr /b /v "#" ^| findstr .`) do (
        set "%%a=%%b"
    )
)

REM 替换 __SERPER_API_KEY__ 占位符，生成解析后的配置文件
echo [SearXNG Paid] 生成运行时配置...
powershell -Command "^
    $content = Get-Content '%CONFIG_FILE%' -Raw; ^
    $content = $content -replace '__SERPER_API_KEY__', $env:SERPER_API_KEY; ^
    Set-Content -Path '%RESOLVED_CONFIG%' -Value $content -Encoding UTF8"

REM 尝试 Docker 启动
where docker >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [SearXNG Paid] 通过 Docker 启动...
    cd /d "%SCRIPT_DIR%"
    docker compose --profile paid up -d
    echo [SearXNG Paid] 启动完成: http://localhost:8889
    goto :end
)

REM 本地 Python 启动
echo [SearXNG Paid] 通过本地 Python 启动...
set SEARXNG_SETTINGS_PATH=%RESOLVED_CONFIG%
set SEARXNG_DIR=%SCRIPT_DIR%searxng
if not exist "%SEARXNG_DIR%" (
    echo 错误: 未找到 SearXNG 代码目录 (%SEARXNG_DIR%)
    pause
    exit /b 1
)
cd /d "%SEARXNG_DIR%"
python -m searx.webapp

:end
