# WanderP - 智能旅行规划平台

## 项目简介

WanderP 是一个基于 AI 的智能旅行规划平台，支持多人协作规划行程、智能推荐美食与景点、实时轨迹记录、费用分摊等功能。系统采用微服务架构，后端使用 Go 构建核心服务，Python 实现 AI 引擎，前端使用 Flutter 开发跨平台移动应用。

### 核心特性

- **AI 智能规划**：基于大语言模型和 RAG 技术，根据用户偏好自动生成旅行方案
- **多人协作**：实时协同编辑行程，投票决策，偏好聚合
- **美食推荐**：基于用户口味偏好和位置的混合推荐引擎
- **实时轨迹**：MQTT 协议实时记录和回放旅行轨迹
- **费用分摊**：灵活的费用记录和自动分摊计算
- **离线支持**：Flutter 客户端支持离线数据缓存和同步

## 架构概览

```
                          ┌─────────────────────────────────────────────────┐
                          │                   客户端                         │
                          │              Flutter App (iOS/Android)            │
                          └────────────────────┬────────────────────────────┘
                                               │
                                               ▼
                          ┌─────────────────────────────────────────────────┐
                          │              API Gateway (:8080)                 │
                          │         路由 / 认证 / 限流 / 日志                 │
                          └──┬────────┬────────┬────────┬────────┬──────────┘
                             │        │        │        │        │
              ┌──────────────▼──┐ ┌───▼────┐ ┌▼──────┐ ┌▼──────┐ ┌▼──────────────┐
              │  User Service   │ │Planner │ │  Map  │ │ Notif │ │  AI Engine    │
              │    (:8001)      │ │(:8002) │ │(:8003)│ │(:8004)│ │   (:8005)     │
              │  用户/认证/费用  │ │行程规划│ │地图/轨迹│ │推送/WS│ │  Python AI    │
              └──────┬──────────┘ └───┬────┘ └──┬───┘ └──┬───┘ └──────┬───────┘
                     │               │        │        │             │
        ┌────────────┼───────────────┼────────┼────────┼─────────────┼──────────┐
        │            │               │        │        │             │          │
        ▼            ▼               ▼        ▼        ▼             ▼          │
   ┌─────────┐ ┌─────────┐   ┌──────────┐ ┌────────┐ ┌──────┐ ┌──────────┐    │
   │PostgreSQL│ │  Redis  │   │ InfluxDB │ │ MongoDB│ │ EMQX │ │  Milvus  │    │
   │  (:5432) │ │ (:6379) │   │ (:8086)  │ │(:27017)│ │(MQTT)│ │ (:19530) │    │
   │ 主数据库  │ │缓存/队列│   │ 时序数据  │ │ 文档库 │ │消息代理│ │ 向量数据库│    │
   └─────────┘ └─────────┘   └──────────┘ └────────┘ └──────┘ └──────────┘    │
                                                                           │
   ┌─────────┐                                                            │
   │  MinIO  │ ◄───────────────────────────────────────────────────────────┘
   │(对象存储)│
   └─────────┘
```

## 快速开始

### 前提条件

- [Docker](https://docs.docker.com/get-docker/) >= 24.0
- [Docker Compose](https://docs.docker.com/compose/install/) >= 2.20
- [Go](https://go.dev/dl/) >= 1.22（本地开发）
- [Python](https://www.python.org/downloads/) >= 3.10（本地开发 AI 引擎）
- [Flutter](https://flutter.dev/docs/get-started/install) >= 3.19（客户端开发）
- [Make](https://www.gnu.org/software/make/)（可选，便捷命令）

### 启动步骤

#### 1. 克隆项目

```bash
git clone https://github.com/your-org/wanderp.git
cd wanderp
```

#### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件，填入必要的 API Key
```

#### 3. 启动基础设施（仅数据库和中间件）

```bash
# 使用 Make
make infra

# 或使用 Docker Compose
docker compose -f docker-compose.yaml -f docker-compose.dev.yaml up -d
```

#### 4. 启动所有服务（含应用）

```bash
# 使用 Make
make dev

# 或使用 Docker Compose
docker compose up -d --build
```

#### 5. 验证服务状态

```bash
make ps
# 或
docker compose ps
```

### 服务访问地址

| 服务 | 地址 | 说明 |
|------|------|------|
| API Gateway | http://localhost:8080 | API 网关 |
| EMQX Dashboard | http://localhost:18083 | MQTT 管理面板 (admin/wanderp_emqx_2024) |
| MinIO Console | http://localhost:9001 | 对象存储管理面板 |
| InfluxDB UI | http://localhost:8086 | 时序数据库管理面板 |
| MinIO API | http://localhost:9000 | 对象存储 API |

## 项目结构

```
wanderp/
├── ai-engine/                  # AI 引擎（Python）
│   ├── app/
│   │   ├── api/                # API 路由
│   │   ├── core/               # 核心模块
│   │   │   ├── nlp/            # 自然语言处理
│   │   │   ├── planner/        # 行程规划引擎
│   │   │   ├── rag/            # 检索增强生成
│   │   │   └── recommender/    # 推荐引擎
│   │   ├── models/             # 数据模型
│   │   ├── services/           # 外部服务集成
│   │   └── utils/              # 工具函数
│   ├── tests/                  # 测试
│   ├── Dockerfile              # Python 服务 Dockerfile
│   └── requirements.txt        # Python 依赖
├── client/                     # Flutter 客户端
│   ├── lib/
│   │   ├── blocs/              # BLoC 状态管理
│   │   ├── config/             # 应用配置
│   │   ├── core/               # 核心模块（网络/存储/工具）
│   │   ├── models/             # 数据模型
│   │   ├── pages/              # 页面
│   │   ├── providers/          # Provider
│   │   ├── services/           # 服务层
│   │   └── widgets/            # 通用组件
│   └── test/                   # 测试
├── server/                     # Go 后端服务
│   ├── cmd/                    # 服务入口
│   │   ├── gateway/            # API 网关
│   │   ├── user/               # 用户服务
│   │   ├── planner/            # 规划服务
│   │   ├── map/                # 地图服务
│   │   └── notification/       # 通知服务
│   ├── internal/               # 内部包
│   │   ├── gateway/            # 网关实现
│   │   ├── user/               # 用户模块
│   │   ├── planner/            # 规划模块
│   │   ├── map/                # 地图模块
│   │   ├── notification/       # 通知模块
│   │   └── pkg/                # 公共包
│   │       ├── config/         # 配置管理
│   │       ├── database/       # 数据库连接
│   │       ├── logger/         # 日志
│   │       ├── middleware/     # 中间件
│   │       ├── mqtt/           # MQTT 客户端
│   │       ├── response/       # 响应封装
│   │       └── validator/      # 参数校验
│   ├── configs/                # 配置文件
│   ├── migrations/             # 数据库迁移
│   ├── api/                    # OpenAPI 定义
│   ├── Dockerfile              # Go 服务 Dockerfile
│   ├── go.mod                  # Go 模块定义
│   └── Makefile                # 服务端 Makefile
├── scripts/                    # 脚本
│   └── init-db.sql             # 数据库初始化
├── docker-compose.yaml         # Docker Compose 主配置
├── docker-compose.dev.yaml     # 开发环境 Override
├── .env.example                # 环境变量模板
├── .gitignore                  # Git 忽略规则
├── Makefile                    # 根目录 Makefile
└── README.md                   # 项目说明文档
```

## 开发指南

### 本地开发（推荐）

1. 启动基础设施：

```bash
make infra
```

2. 本地运行 Go 服务：

```bash
cd server
go run ./cmd/gateway/main.go
go run ./cmd/user/main.go
go run ./cmd/planner/main.go
go run ./cmd/map/main.go
go run ./cmd/notification/main.go
```

3. 本地运行 AI 引擎：

```bash
cd ai-engine
pip install -r requirements.txt
python -m app.main
```

4. 运行 Flutter 客户端：

```bash
cd client
flutter pub get
flutter run
```

### 运行测试

```bash
# 运行所有测试
make test

# 单独运行 Go 测试
make test-server

# 单独运行 AI 引擎测试
make test-ai

# 单独运行 Flutter 测试
make test-client
```

### 数据库迁移

```bash
# 运行迁移
make migrate

# 进入 PostgreSQL Shell
make shell-postgres
```

## 环境变量说明

核心环境变量如下，完整列表请参考 [.env.example](.env.example)。

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| `APP_ENV` | 运行环境 | `development` |
| `POSTGRES_USER` | PostgreSQL 用户名 | `wanderp` |
| `POSTGRES_PASSWORD` | PostgreSQL 密码 | `wanderp_dev_2024` |
| `REDIS_PASSWORD` | Redis 密码 | `wanderp_redis_2024` |
| `JWT_SECRET` | JWT 签名密钥 | 需修改 |
| `AMAP_API_KEY` | 高德地图 API Key | 无 |
| `OPENAI_API_KEY` | OpenAI API Key | 无 |
| `EMQX_DASHBOARD_USER` | EMQX 管理面板用户名 | `admin` |

## 部署说明

### 生产环境部署

1. 修改 `.env` 文件中的所有密码和密钥为强密码
2. 设置 `APP_ENV=production`
3. 配置 SSL/TLS 证书
4. 启动所有服务：

```bash
docker compose up -d --build
```

### 数据备份

```bash
# PostgreSQL 备份
docker exec wanderp-postgres pg_dump -U wanderp wanderp > backup.sql

# 恢复
cat backup.sql | docker exec -i wanderp-postgres psql -U wanderp wanderp
```

### 监控

- EMQX Dashboard: http://localhost:18083
- MinIO Console: http://localhost:9001
- InfluxDB UI: http://localhost:8086

## 技术栈

| 层级 | 技术选型 |
|------|----------|
| 客户端 | Flutter 3.x + Dart |
| API 网关 | Go + Gin + 反向代理 |
| 用户服务 | Go + Gin + GORM |
| 规划服务 | Go + Gin + GORM |
| 地图服务 | Go + Gin + 高德地图 API |
| 通知服务 | Go + Gorilla WebSocket + MQTT |
| AI 引擎 | Python + FastAPI + LangChain |
| 主数据库 | PostgreSQL 16 |
| 缓存 | Redis 7 |
| 向量数据库 | Milvus 2.x |
| 时序数据库 | InfluxDB 2.x |
| 文档数据库 | MongoDB 7 |
| 对象存储 | MinIO |
| 消息队列 | EMQX 5.x (MQTT) |
| 容器化 | Docker + Docker Compose |

## License

MIT
