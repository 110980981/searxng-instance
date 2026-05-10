# SearXNG Instance Config

双模式 SearXNG 实例配置项目 — 一套配置，两种启动方式。

## 项目结构

```
searxng-instance/
├── searxng/               # SearXNG 源码（外部依赖，被 .gitignore 排除）
├── config/
│   ├── settings-free.yml  # 免费模式配置文件
│   └── settings-paid.yml  # 付费模式配置文件
├── githooks/
│   ├── pre-commit         # pre-commit hook: 阻止 API Key 泄漏
│   └── setup-hooks.sh     # 安装 git hooks
├── start-free.sh          # 免费模式启动 (Bash)
├── start-free.bat         # 免费模式启动 (Windows)
├── start-paid.sh          # 付费模式启动 (Bash)
├── start-paid.bat         # 付费模式启动 (Windows)
├── stop.sh                # 停止所有实例
├── docker-compose.yml     # Docker 编排
├── Makefile               # 快捷命令
├── .env.example           # 环境变量模板
├── .gitignore
└── README.md
```

## 前置准备

### 1. SearXNG（外部依赖）

SearXNG 已包含在项目目录中，或通过 Docker 使用官方镜像。

### 2. Python 依赖（本地开发模式）

```bash
cd searxng
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

## API Key 安全防护

本项目采用 **多层防护** 防止 API Key 意外提交到 Git 仓库：

### 第 1 层: `.gitignore` 排除

`.gitignore` 已排除 `.env` 文件，从源头防止被追踪。

### 第 2 层: pre-commit hook（推荐安装）

提交代码时会自动扫描 staged 文件中的 API Key / Secret 模式，发现则阻止提交。

```bash
# 安装 hook（只需执行一次）
make setup
# 或
./githooks/setup-hooks.sh
```

检测范围：
- `api_key`, `secret`, `token`, `password` 等键名 + 长字符串
- GitHub Token (`ghp_*`, `gho_*`)
- OpenAI Key (`sk-*`)
- Google API Key (`AIza*`)
- AWS Access Key (`AKIA*`)

需要强制提交时可绕过：

```bash
git commit --no-verify -m "message"
```

### 第 3 层: 环境变量注入

敏感信息不写在配置文件中，通过环境变量传入：

```bash
# 方式 A: .env 文件（推荐）
SEARXNG_SECRET=your-secret-key
GOOGLE_API_KEY=your-google-api-key

# 方式 B: 直接 export
export SEARXNG_SECRET=your-secret-key

# 方式 C: 单次命令行
SEARXNG_SECRET=your-secret-key ./start-free.sh
```

### 第 4 层（可选）: GitHub 密钥扫描

GitHub 内置 [secret scanning](https://docs.github.com/code-security/secret-scanning)，会自动检测推送中的已知密钥模式并通知你。

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
