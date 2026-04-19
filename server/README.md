# WanderP Server

WanderP 旅行规划平台后端微服务。

## 项目架构

```
server/
├── cmd/                    # 服务入口
│   ├── gateway/            # API网关 (端口8080)
│   ├── planner/            # 规划服务 (端口8002)
│   ├── map/                # 地图服务 (端口8003)
│   ├── user/               # 用户服务 (端口8001)
│   └── notification/       # 通知服务 (端口8004)
├── internal/               # 内部包
│   ├── gateway/            # 网关服务实现
│   ├── planner/            # 规划服务实现
│   ├── map/                # 地图服务实现
│   ├── user/               # 用户服务实现
│   ├── notification/       # 通知服务实现
│   └── pkg/                # 公共工具包
├── api/                    # API定义
├── migrations/             # 数据库迁移
├── configs/                # 配置文件
└── scripts/                # 脚本工具
```

## 技术栈

- **Web框架**: Gin
- **ORM**: GORM
- **数据库**: PostgreSQL
- **缓存**: Redis
- **时序数据**: InfluxDB
- **文档数据库**: MongoDB
- **日志**: Zap
- **配置管理**: Viper
- **WebSocket**: gorilla/websocket
- **认证**: JWT
- **消息队列**: MQTT

## 快速开始

### 环境要求

- Go 1.21+
- PostgreSQL 14+
- Redis 7+
- InfluxDB 2.x (可选)
- MongoDB 6.x (可选)

### 安装依赖

```bash
go mod download
```

### 数据库迁移

```bash
make migrate-up
```

### 编译

```bash
make build
```

### 运行

```bash
# 运行所有服务
make run-all

# 或单独运行某个服务
make run  # 运行网关
```

## 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| Gateway | 8080 | API网关，统一入口 |
| User | 8001 | 用户认证与管理 |
| Planner | 8002 | 行程规划与AI规划 |
| Map | 8003 | 地图、路线、POI |
| Notification | 8004 | 推送与WebSocket |

## 配置说明

配置文件位于 `configs/` 目录下：

- `dev.yaml` - 开发环境
- `prod.yaml` - 生产环境

支持环境变量覆盖配置项。
