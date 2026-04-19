# =============================================================================
# WanderP - 项目根目录 Makefile
# =============================================================================
# 使用方式:
#   make infra        # 启动基础设施服务
#   make infra-down   # 停止基础设施服务
#   make dev          # 启动所有服务（含应用）
#   make dev-down     # 停止所有服务
#   make build        # 构建所有服务镜像
#   make test         # 运行所有测试
#   make logs         # 查看服务日志
#   make clean        # 清理所有容器和数据卷
# =============================================================================

.PHONY: help infra infra-down dev dev-down build test logs clean \
        build-gateway build-user build-planner build-map build-notification \
        test-server test-ai test-client \
        logs-infra logs-app logs-gateway logs-user logs-planner \
        logs-map logs-notification logs-ai \
        migrate minio-init

# ---------------------------------------------------------------------------
# 默认目标
# ---------------------------------------------------------------------------
.DEFAULT_GOAL := help

# ---------------------------------------------------------------------------
# Docker Compose 配置
# ---------------------------------------------------------------------------
DC_BASE := docker compose -f docker-compose.yaml
DC_DEV  := docker compose -f docker-compose.yaml -f docker-compose.dev.yaml

# ---------------------------------------------------------------------------
# 颜色输出
# ---------------------------------------------------------------------------
GREEN  := \033[0;32m
YELLOW := \033[0;33m
BLUE   := \033[0;34m
RED    := \033[0;31m
NC     := \033[0m

# =============================================================================
# 帮助信息
# =============================================================================
help: ## 显示帮助信息
	@echo ""
	@echo "$(BLUE)WanderP - 可用命令$(NC)"
	@echo "=============================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-18s$(NC) %s\n", $$1, $$2}'
	@echo ""

# =============================================================================
# 基础设施管理
# =============================================================================
infra: ## 启动基础设施服务 (PostgreSQL, Redis, Milvus, InfluxDB, MongoDB, MinIO, EMQX)
	@echo "$(BLUE)启动基础设施服务...$(NC)"
	@$(DC_DEV) up -d
	@echo "$(GREEN)基础设施服务已启动$(NC)"
	@echo "$(YELLOW)等待服务健康检查通过...$(NC)"
	@sleep 5
	@$(DC_DEV) ps

infra-down: ## 停止基础设施服务
	@echo "$(BLUE)停止基础设施服务...$(NC)"
	@$(DC_DEV) down
	@echo "$(GREEN)基础设施服务已停止$(NC)"

# =============================================================================
# 开发环境管理
# =============================================================================
dev: ## 启动所有服务（基础设施 + 应用服务）
	@echo "$(BLUE)启动所有服务...$(NC)"
	@$(DC_BASE) up -d --build
	@echo "$(GREEN)所有服务已启动$(NC)"
	@sleep 5
	@$(DC_BASE) ps

dev-down: ## 停止所有服务
	@echo "$(BLUE)停止所有服务...$(NC)"
	@$(DC_BASE) down
	@echo "$(GREEN)所有服务已停止$(NC)"

# =============================================================================
# 构建服务
# =============================================================================
build: ## 构建所有服务镜像
	@echo "$(BLUE)构建所有服务镜像...$(NC)"
	@$(DC_BASE) build
	@echo "$(GREEN)所有服务镜像构建完成$(NC)"

build-gateway: ## 构建网关服务
	@echo "$(BLUE)构建网关服务...$(NC)"
	@docker build --build-arg SERVICE=gateway -t wanderp-gateway:latest ./server
	@echo "$(GREEN)网关服务构建完成$(NC)"

build-user: ## 构建用户服务
	@echo "$(BLUE)构建用户服务...$(NC)"
	@docker build --build-arg SERVICE=user -t wanderp-user:latest ./server
	@echo "$(GREEN)用户服务构建完成$(NC)"

build-planner: ## 构建规划服务
	@echo "$(BLUE)构建规划服务...$(NC)"
	@docker build --build-arg SERVICE=planner -t wanderp-planner:latest ./server
	@echo "$(GREEN)规划服务构建完成$(NC)"

build-map: ## 构建地图服务
	@echo "$(BLUE)构建地图服务...$(NC)"
	@docker build --build-arg SERVICE=map -t wanderp-map:latest ./server
	@echo "$(GREEN)地图服务构建完成$(NC)"

build-notification: ## 构建通知服务
	@echo "$(BLUE)构建通知服务...$(NC)"
	@docker build --build-arg SERVICE=notification -t wanderp-notification:latest ./server
	@echo "$(GREEN)通知服务构建完成$(NC)"

# =============================================================================
# 测试
# =============================================================================
test: test-server test-ai ## 运行所有测试

test-server: ## 运行Go服务端测试
	@echo "$(BLUE)运行Go服务端测试...$(NC)"
	@cd server && go test ./... -v -race -coverprofile=coverage.txt
	@echo "$(GREEN)Go服务端测试完成$(NC)"

test-ai: ## 运行AI引擎测试
	@echo "$(BLUE)运行AI引擎测试...$(NC)"
	@cd ai-engine && python -m pytest tests/ -v --tb=short
	@echo "$(GREEN)AI引擎测试完成$(NC)"

test-client: ## 运行Flutter客户端测试
	@echo "$(BLUE)运行Flutter客户端测试...$(NC)"
	@cd client && flutter test
	@echo "$(GREEN)Flutter客户端测试完成$(NC)"

# =============================================================================
# 日志查看
# =============================================================================
logs: ## 查看所有服务日志
	@$(DC_BASE) logs -f --tail=100

logs-infra: ## 查看基础设施日志
	@$(DC_DEV) logs -f --tail=100 postgres redis milvus influxdb mongodb minio emqx

logs-app: ## 查看应用服务日志
	@$(DC_BASE) logs -f --tail=100 gateway user-service planner map-service notification ai-engine

logs-gateway: ## 查看网关日志
	@$(DC_BASE) logs -f --tail=100 gateway

logs-user: ## 查看用户服务日志
	@$(DC_BASE) logs -f --tail=100 user-service

logs-planner: ## 查看规划服务日志
	@$(DC_BASE) logs -f --tail=100 planner

logs-map: ## 查看地图服务日志
	@$(DC_BASE) logs -f --tail=100 map-service

logs-notification: ## 查看通知服务日志
	@$(DC_BASE) logs -f --tail=100 notification

logs-ai: ## 查看AI引擎日志
	@$(DC_BASE) logs -f --tail=100 ai-engine

# =============================================================================
# 数据库迁移
# =============================================================================
migrate: ## 运行数据库迁移
	@echo "$(BLUE)运行数据库迁移...$(NC)"
	@cd server && bash scripts/migrate.sh
	@echo "$(GREEN)数据库迁移完成$(NC)"

# =============================================================================
# MinIO 初始化
# =============================================================================
minio-init: ## 初始化MinIO Bucket
	@echo "$(BLUE)初始化MinIO Bucket...$(NC)"
	@docker exec wanderp-minio mc alias set local http://localhost:9000 ${MINIO_ROOT_USER:-wanderp_admin} ${MINIO_ROOT_PASSWORD:-wanderp_minio_2024} || true
	@docker exec wanderp-minio mc mb local/wanderp --ignore-existing || true
	@echo "$(GREEN)MinIO Bucket初始化完成$(NC)"

# =============================================================================
# 清理
# =============================================================================
clean: ## 清理所有容器、镜像和数据卷
	@echo "$(RED)警告: 此操作将删除所有容器、镜像和数据卷！$(NC)"
	@read -p "确认清理? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@echo "$(BLUE)停止并删除所有容器...$(NC)"
	@$(DC_BASE) down -v --rmi local 2>/dev/null || true
	@$(DC_DEV) down -v --rmi local 2>/dev/null || true
	@echo "$(BLUE)清理悬空镜像...$(NC)"
	@docker image prune -f
	@echo "$(BLUE)清理悬空数据卷...$(NC)"
	@docker volume prune -f
	@echo "$(GREEN)清理完成$(NC)"

# =============================================================================
# 便捷命令
# =============================================================================
ps: ## 查看服务状态
	@$(DC_BASE) ps

restart: ## 重启所有服务
	@echo "$(BLUE)重启所有服务...$(NC)"
	@$(DC_BASE) restart
	@echo "$(GREEN)所有服务已重启$(NC)"

shell-postgres: ## 进入PostgreSQL Shell
	@docker exec -it wanderp-postgres psql -U ${POSTGRES_USER:-wanderp} -d ${POSTGRES_DB:-wanderp}

shell-redis: ## 进入Redis Shell
	@docker exec -it wanderp-redis redis-cli -a ${REDIS_PASSWORD:-wanderp_redis_2024}
