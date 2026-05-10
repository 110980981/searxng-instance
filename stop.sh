#!/usr/bin/env bash
# SearXNG 停止脚本
# 使用方式: ./stop.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Docker 停止
if command -v docker &> /dev/null; then
    echo "[SearXNG] 停止 Docker 容器..."
    cd "$SCRIPT_DIR"
    docker compose --profile free --profile paid down
fi

echo "[SearXNG] 已停止"
