#!/usr/bin/env bash
# SearXNG 免费模式启动脚本
# 使用方式: ./start-free.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/settings-free.yml"
RESOLVED_CONFIG="$SCRIPT_DIR/config/.settings-free.yml"
PORT=8888

# 加载 .env 中的环境变量
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "[SearXNG Free] 加载 .env 环境变量..."
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
fi

# 生成运行时配置（替换密钥占位符）
echo "[SearXNG Free] 生成运行时配置..."
SEARXNG_SECRET="${SEARXNG_SECRET:-$(head -c 24 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')}"
sed "s/__SEARXNG_SECRET__/${SEARXNG_SECRET}/g" "$CONFIG_FILE" > "$RESOLVED_CONFIG"
sed -i "s/^  port: [0-9]*/  port: $PORT/" "$RESOLVED_CONFIG"

# 优先尝试 Docker 启动
if command -v docker &> /dev/null && docker info &>/dev/null; then
    echo "[SearXNG Free] 通过 Docker 启动..."
    cd "$SCRIPT_DIR"
    docker compose --profile free up -d
    echo "[SearXNG Free] 启动完成: http://localhost:$PORT"
    exit 0
fi

# 回退到本地 Python 启动
echo "[SearXNG Free] 通过本地 Python 启动..."

export SEARXNG_SETTINGS_PATH="$RESOLVED_CONFIG"

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
