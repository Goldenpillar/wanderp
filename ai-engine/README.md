# WanderP AI Engine

智能旅行规划AI引擎 - 基于LLM与约束求解的行程规划服务。

## 项目简介

WanderP AI Engine 是一个基于大语言模型(LLM)和约束求解技术的智能旅行规划引擎。通过通义千问大模型生成初始行程方案，结合Google OR-Tools约束求解器进行优化，为用户提供高质量、可执行的旅行行程。

## 核心能力

- **智能行程规划**：LLM生成 + 约束求解的混合规划策略
- **个性化推荐**：美食推荐、景区推荐、综合推荐
- **多人偏好聚合**：支持多人出行时的偏好融合与妥协区域识别
- **知识增强检索(RAG)**：基于Milvus的混合检索（稠密向量+BM25）
- **自然语言理解**：意图解析、情绪分析、能量状态评估

## 技术栈

| 组件 | 技术 |
|------|------|
| Web框架 | FastAPI |
| LLM | 通义千问 (DashScope) |
| 约束求解 | Google OR-Tools CP-SAT |
| 向量数据库 | Milvus |
| 缓存 | Redis |
| 地图服务 | 高德地图 |
| 天气服务 | 和风天气 |
| Embedding | 通义 text-embedding-v3 |

## 快速开始

### 环境要求

- Python >= 3.11
- Redis (可选，用于缓存)
- Milvus (可选，用于向量检索)

### 安装

```bash
# 使用 pip
pip install -r requirements.txt

# 或使用 uv
uv pip install -r requirements.txt
```

### 配置

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑配置文件，填入API密钥
vim .env
```

### 启动服务

```bash
# 开发模式
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 生产模式
uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
```

### Docker 部署

```bash
# 构建镜像
docker build -t wanderp-ai-engine .

# 运行容器
docker run -d -p 8000:8000 --env-file .env wanderp-ai-engine
```

## API 文档

启动服务后访问：
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### 主要接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/health` | GET | 健康检查 |
| `/api/health/ready` | GET | 就绪检查 |
| `/api/plan/create` | POST | 创建行程规划 |
| `/api/plan/{plan_id}` | GET | 获取行程详情 |
| `/api/plan/optimize/{plan_id}` | POST | 优化行程 |
| `/api/plan/stream` | POST | 流式行程规划 |
| `/api/recommend/food` | GET | 美食推荐 |
| `/api/recommend/scenic` | GET | 景区推荐 |
| `/api/recommend/hybrid` | GET | 综合推荐 |
| `/api/preference/analyze` | POST | 偏好分析 |
| `/api/preference/aggregate` | POST | 多人偏好聚合 |

## 项目结构

```
ai-engine/
├── app/
│   ├── main.py              # FastAPI入口
│   ├── config.py            # 配置管理
│   ├── api/                 # API路由
│   ├── core/                # 核心引擎
│   │   ├── planner/         # 行程规划引擎
│   │   ├── recommender/     # 推荐引擎
│   │   ├── rag/             # 知识检索
│   │   └── nlp/             # 自然语言处理
│   ├── services/            # 外部服务对接
│   ├── models/              # 数据模型
│   └── utils/               # 工具模块
├── data/                    # 数据目录
├── tests/                   # 测试文件
├── Dockerfile               # Docker构建
├── pyproject.toml           # 项目配置
└── requirements.txt         # 依赖清单
```

## 运行测试

```bash
# 安装开发依赖
pip install -e ".[dev]"

# 运行测试
pytest tests/ -v
```

## License

MIT
