@echo off
chcp 65001 >nul
REM SearXNG 免费模式启动脚本 (Windows)
REM 使用方式: start-free.bat

set SCRIPT_DIR=%~dp0
set CONFIG_FILE=%SCRIPT_DIR%config\settings-free.yml
set RESOLVED_CONFIG=%SCRIPT_DIR%config\.settings-free.yml

REM 生成运行时配置（替换密钥占位符）
echo [SearXNG Free] 生成运行时配置...
if not defined SEARXNG_SECRET (
    for /f %%i in ('powershell -Command "[System.Convert]::ToBase64String((1..24|%%{[byte](Get-Random -Min 33 -Max 126)})) -replace '[^a-zA-Z0-9]',''"') do set SEARXNG_SECRET=%%i
)
powershell -Command "(Get-Content '%CONFIG_FILE%' -Raw) -replace '__SEARXNG_SECRET__', $env:SEARXNG_SECRET | Set-Content -Path '%RESOLVED_CONFIG%' -Encoding UTF8"
if %ERRORLEVEL% neq 0 (
    echo [SearXNG Free] 配置生成失败
    pause
    exit /b 1
)

REM 尝试 Docker 启动
where docker >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [SearXNG Free] 通过 Docker 启动...
    docker compose --profile free up -d
    if %ERRORLEVEL% equ 0 (
        echo [SearXNG Free] 启动完成: http://localhost:8888
    ) else (
        echo [SearXNG Free] Docker 启动失败
    )
    goto :end
)

REM 本地 Python 启动
echo [SearXNG Free] 通过本地 Python 启动...
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
