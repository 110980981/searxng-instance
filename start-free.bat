@echo off
chcp 65001 >nul
REM SearXNG 免费模式启动脚本 (Windows)
REM 使用方式: start-free.bat

set SCRIPT_DIR=%~dp0
set CONFIG_FILE=%SCRIPT_DIR%config\settings-free.yml
set SEARXNG_SETTINGS_PATH=%CONFIG_FILE%
set SEARXNG_SECRET=%SEARXNG_SECRET:ultrasecretkey%

REM 尝试 Docker 启动
where docker >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [SearXNG Free] 通过 Docker 启动...
    docker compose --profile free up -d
    echo [SearXNG Free] 启动完成: http://localhost:8888
    goto :end
)

REM 本地 Python 启动
echo [SearXNG Free] 通过本地 Python 启动...
set SEARXNG_DIR=%SCRIPT_DIR%..\searxng
if not exist "%SEARXNG_DIR%" (
    echo 错误: 未找到 SearXNG 代码目录 (%SEARXNG_DIR%)
    pause
    exit /b 1
)
cd /d "%SEARXNG_DIR%"
python -m searx.webapp

:end
