#!/usr/bin/env bash
# SearXNG 免费模式启动脚本
# 使用方式: ./start-free.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/settings-free.yml"

# 优先尝试 Docker 启动
if command -v docker &> /dev/null; then
    echo "[SearXNG Free] 通过 Docker 启动..."
    export SEARXNG_SETTINGS_PATH="$CONFIG_FILE"
    docker compose --profile free up -d
    echo "[SearXNG Free] 启动完成: http://localhost:8888"
    exit 0
fi

# 回退到本地 Python 启动
echo "[SearXNG Free] 通过本地 Python 启动..."
export SEARXNG_SETTINGS_PATH="$CONFIG_FILE"
export SEARXNG_SECRET="${SEARXNG_SECRET:-ultrasecretkey}"

SEARXNG_DIR="$SCRIPT_DIR/searxng"
if [ ! -d "$SEARXNG_DIR" ]; then
    echo "错误: 未找到 SearXNG 代码目录 ($SEARXNG_DIR)"
    echo "请确保 searxng 仓库存放在 ./searxng 位置"
    exit 1
fi

cd "$SEARXNG_DIR"
PYTHON="$SCRIPT_DIR/venv/bin/python"
if [ ! -f "$PYTHON" ]; then
    PYTHON="python"
fi
exec "$PYTHON" -m searx.webapp
