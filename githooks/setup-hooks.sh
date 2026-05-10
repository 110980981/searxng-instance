#!/usr/bin/env bash
# 安装 git hooks（配置 git hooks 路径）
# 使用方式: ./githooks/setup-hooks.sh
set -e

cd "$(dirname "$0")/.."
git config core.hooksPath githooks
echo "[OK] git hooks 已安装 (core.hooksPath = githooks)"
chmod +x githooks/pre-commit
