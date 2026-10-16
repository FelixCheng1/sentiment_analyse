# 尚舆分析平台

多专家圆桌讨论的 AI 深度舆情研究平台。三个 Agent 协作产出舆情报告：

- **Insight（私域检索智能体）** — 从本地 MySQL 舆情库做多通道召回 + 可选 Milvus 向量检索
- **Media（公域检索智能体）** — 通过 Tavily / Bocha / Anspire 做 Web 检索
- **Host（研判智能体）** — 按五个维度对两个 Agent 的产出做阶段裁判，最后汇总为综合报告

后端 FastAPI + LangGraph，前端 Vue 3 + Vite。

## 环境要求

| 依赖 | 版本 | 说明 |
| --- | --- | --- |
| Python | >= 3.11 | `pyproject.toml` 要求 |
| uv | 最新 | 依赖与虚拟环境管理（也可用 venv + pip） |
| Node.js | >= 18 | 前端构建，实测 v24 可用 |
| MySQL | 8.x | Insight Agent 私域检索必需 |
| Milvus | 2.6.x | **可选**，仅在启用向量检索时需要 |

## 一、准备配置

```powershell
copy .env.example .env
```

然后编辑 `.env`，**必须**填写：

1. 四个角色的 LLM 配置（OpenAI 兼容接口即可，可四者共用同一个 Key）
   - `INSIGHT_ENGINE_*` / `MEDIA_ENGINE_*` / `REPORT_ENGINE_*` / `HOST_*`
2. 搜索工具：`SEARCH_SWITCH`（`TavilyAPI` / `AnspireAPI` / `BochaAPI`）及对应的 `*_API_KEY`
3. 数据库：`DB_HOST` / `DB_PORT` / `DB_USER` / `DB_PASSWORD` / `DB_NAME`

`.env` 已被 `.gitignore` 忽略，不要提交。

## 二、启动后端

```powershell
# 基础依赖(不含 torch/sentence-transformers，够用)
uv sync

# 需要向量检索或语义聚类时再加上 ml 依赖组(会拉取 CUDA 版 torch，体积很大)
# uv sync --extra ml

uv run python main.py
# 或 .\.venv\Scripts\python.exe main.py
```

启动后监听 `http://0.0.0.0:5000`（由 `.env` 的 `HOST` / `PORT` 控制）。
注意：必须在**项目根目录**启动，报告输出目录 `data/report/**` 是相对路径。

## 三、启动前端

```powershell
cd front
npm install
npm run dev
```

访问 <http://localhost:3000>（Vite 已把 `/api` 代理到 `http://localhost:5000`，无需额外配置跨域）。

> 若 `127.0.0.1:3000` 打不开，请用 `localhost:3000`：Vite 默认只绑定 localhost。

生产构建：`npm run build` 产出 `front/dist`。后端目前**不托管**前端静态文件，需要自己用 Nginx/`npx serve` 等托管，或自行在后端挂载 `StaticFiles`。

## 四、使用流程

1. **研究** — 输入主题 → 自动 `stopHost`/`startHost` 后启动 insight + media 两个 Agent；SSE 实时推进度
2. **主持人研判** — 每个 Agent 的章节产出会触发 Host 的维度裁判，可在该页查看讨论记录
3. **综合报告** — 三个角色的报告都落盘后 `输入就绪`，点击生成由 LLM 汇总的 HTML/Markdown 报告
4. **系统配置** — 在线修改 LLM / 搜索 / 数据库配置，写回根目录 `.env`（部分改动需重启）

## 五、数据依赖

Insight Agent 会查询以下 MySQL 表（表名与字段在
`engines/insight_agent/tools/platform_mappings.py` 中配置），
结构对应 [MediaCrawler](https://github.com/NanmiCoder/MediaCrawler) 的抖音/微博表：

- `douyin_aweme`、`douyin_aweme_comment`
- `weibo_note`、`weibo_note_comment`

没有这些表时接口不会报错，但 Insight 侧召回为空、报告内容会明显变薄。
若只想跑通流程，也可先只用 Media + Host 部分功能。

## 六、可选：向量检索 / 语义聚类

两条链路默认关闭，开启需要：

1. 安装 ml 依赖：`uv sync --extra ml`（torch / FlagEmbedding / sentence-transformers / scikit-learn）
2. 准备 Milvus 服务，并在 `.env` 中配置 `MILVUS_URI`、`INSIGHT_EMBEDDING_MODEL`（本地路径或 HF 模型名）
3. 设置 `INSIGHT_VECTOR_ENABLED=true`；语义聚类另需 `INSIGHT_CLUSTERING_ENABLED=true` 和 `INSIGHT_CLUSTER_MODEL`

## 七、常见问题

| 现象 | 原因 / 处理 |
| --- | --- |
| `ModuleNotFoundError: FlagEmbedding` | 启用了 `INSIGHT_VECTOR_ENABLED=true` 但未装 ml 依赖组 |
| 控制台中文日志乱码 | Windows 控制台编码问题，执行 `chcp 65001` 后重跑 |
| 数据库连接失败 | Insight 检索会捕获异常并返回空结果，检查 `.env` 的 `DB_*` 与表结构 |
| 报告页提示"输入文件未准备就绪" | `data/report/{insight,media,host}` 三个目录都要有 `.md` 报告 |
| 前端页面空白 | 后端未启动，或端口不是 5000（需同步改 `front/vite.config.js` 的 proxy） |
| `npm audit` 报高危 | 均来自 vite 开发链路的间接依赖，不影响本地使用，可 `npm audit fix` |

## 八、目录结构

```
app/         FastAPI 应用层：routers(REST/SSE)、services、schemas、依赖注入
engines/     引擎层：三个 Agent、报告引擎、编排、公共节点/事件总线/日志
  contracts/  角色定义、五维维度、证据模型、全局配置(.env 读取)
  common/     事件总线、LLM 客户端、LangGraph 公共节点、报告落盘
data/report/  各角色与最终报告的落盘目录
front/        Vue 3 前端
test/         学习/调试用脚本(不是真正的单元测试)
logs/         按角色分流的运行日志
```
