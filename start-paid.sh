#!/usr/bin/env bash
# SearXNG 付费模式启动脚本
# 使用方式: ./start-paid.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config/settings-paid.yml"
RESOLVED_CONFIG="$SCRIPT_DIR/config/.settings-paid.yml"

# 加载 .env 中的 API Key
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "[SearXNG Paid] 加载 .env 环境变量..."
    set -a
    source "$SCRIPT_DIR/.env"
    set +a
fi

# 生成解析后的配置文件（替换占位符为真实 API Key）
echo "[SearXNG Paid] 生成运行时配置..."
sed "s/__SERPER_API_KEY__/${SERPER_API_KEY}/g" "$CONFIG_FILE" > "$RESOLVED_CONFIG"

# 优先尝试 Docker 启动
if command -v docker &> /dev/null; then
    echo "[SearXNG Paid] 通过 Docker 启动..."
    cd "$SCRIPT_DIR"
    docker compose --profile paid up -d
    echo "[SearXNG Paid] 启动完成: http://localhost:8889"
    exit 0
fi

# 回退到本地 Python 启动
echo "[SearXNG Paid] 通过本地 Python 启动..."
export SEARXNG_SETTINGS_PATH="$RESOLVED_CONFIG"
export SEARXNG_SECRET="${SEARXNG_SECRET:-ultrasecretkey}"

SEARXNG_DIR="$SCRIPT_DIR/searxng"
if [ ! -d "$SEARXNG_DIR" ]; then
    echo "错误: 未找到 SearXNG 代码目录 ($SEARXNG_DIR)"
    echo "请确保 searxng 仓库存放在 ./searxng 位置"
    exit 1
fi

cd "$SEARXNG_DIR"
exec python -m searx.webapp
