# SearXNG Instance Management
# ===========================
# 免费模式: make free
# 付费模式: make paid
# 停止:     make stop

.PHONY: free paid stop free-dev paid-dev

# === Docker 模式 ===

free:
	docker compose --profile free up -d

paid:
	docker compose --profile paid up -d

stop:
	docker compose --profile free --profile paid down

logs:
	docker compose --profile free --profile paid logs -f

restart-free: stop free
restart-paid: stop paid

# === 本地开发模式（需要先安装 SearXNG 依赖）===
# 假设 searxng 仓库存放在 ./searxng 目录

SEARXNG_DIR ?= searxng
FREE_CONFIG := $(shell pwd)/config/settings-free.yml
PAID_CONFIG := $(shell pwd)/config/settings-paid.yml

free-dev:
	SEARXNG_SETTINGS_PATH=$(FREE_CONFIG) \
	cd $(SEARXNG_DIR) && python -m searx.webapp

paid-dev:
	SEARXNG_SETTINGS_PATH=$(PAID_CONFIG) \
	cd $(SEARXNG_DIR) && python -m searx.webapp
