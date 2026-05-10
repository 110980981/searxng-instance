# SearXNG Instance Config

双模式 SearXNG 实例配置项目 — 一套配置，两种启动方式。

## 项目结构

```
searxng-instance/
├── start-free.sh         # 免费模式启动 (Bash)
├── start-free.bat        # 免费模式启动 (Windows)
├── start-paid.sh         # 付费模式启动 (Bash)
├── start-paid.bat        # 付费模式启动 (Windows)
├── stop.sh               # 停止所有实例
├── config/
│   ├── settings-free.yml # 免费模式配置文件
│   └── settings-paid.yml # 付费模式配置文件
├── docker-compose.yml    # Docker 编排
├── Makefile              # 快捷命令
├── .env.example           # 环境变量模板
└── .gitignore
```

## 前置准备

### 1. SearXNG（外部依赖）

SearXNG 作为外部依赖引入，需要先克隆到同级目录：

```bash
cd ..
git clone https://github.com/searxng/searxng.git
```

或通过 Docker 使用官方镜像（无需本地克隆）。

### 2. Python 依赖（本地开发模式）

```bash
cd ../searxng
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### 3. API Key（付费模式）

复制环境变量模板并填写：

```bash
cp .env.example .env
```

编辑 `.env`，填入你的 API Key。

## 启动方式

### 免费模式 — 仅免费 API

使用 DuckDuckGo、Qwant、Wikipedia、Brave 等免费搜索引擎（网页抓取，无需 API Key）。

**Bash：**

```bash
./start-free.sh
```

**Windows：**

```cmd
start-free.bat
```

**Docker 直接启动：**

```bash
docker compose --profile free up -d
```

访问 http://localhost:8888

### 付费模式 — 免费 + 付费 API

在免费引擎基础上增加 YouTube API、WolframAlpha、DeepL、Flickr 等需要 API Key 的引擎。

**Bash：**

```bash
./start-paid.sh
```

**Windows：**

```cmd
start-paid.bat
```

**Docker 直接启动：**

```bash
docker compose --profile paid up -d
```

访问 http://localhost:8889

### 停止

```bash
./stop.sh
```

## 免费 vs 付费引擎说明

| 模式 | 搜索引擎 | API Key |
|------|---------|---------|
| 免费 | DuckDuckGo, Google, Brave, Wikipedia, GitHub, StackOverflow, Arxiv, OpenStreetMap 等 | 无需 |
| 免费 | Qwant, Wikibooks, Pixabay, PeerTube, OpenLibrary 等（默认禁用，免费模式下手动启用） | 无需 |
| 付费 | YouTube Data API, WolframAlpha API, DeepL API, Flickr API | 需要 |
| 付费 | Bing Web Search API, Google Custom Search API | 需要 |

## 配置自定义

编辑 `config/settings-free.yml` 或 `config/settings-paid.yml`：

- 开启/关闭引擎：修改 `disabled: true/false`
- 调整超时：修改 `timeout` 值
- 添加新引擎：在 `engines` 段新增条目

所有配置使用 `use_default_settings: true` 继承 SearXNG 默认配置，只做增量覆盖，方便升级。

## License

本项目采用 [AGPL-3.0](LICENSE) 许可证（与 SearXNG 一致）。
