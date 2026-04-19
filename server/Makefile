# WanderP Server Makefile
# 构建和管理命令

.PHONY: all build run test clean docker migrate help

# 变量定义
BINARY_NAME=wanderp-server
GO=go
GOFLAGS=-v
MAIN_PATH=./cmd

# 服务名称
SERVICES=gateway planner map user notification

# Docker相关
DOCKER_IMAGE=wanderp/server
DOCKER_TAG=latest

# 默认目标
all: build

## help: 显示帮助信息
help:
	@echo "WanderP Server 可用命令:"
	@echo ""
	@echo "  make build          - 编译所有服务"
	@echo "  make build-gateway  - 编译网关服务"
	@echo "  make build-planner  - 编译规划服务"
	@echo "  make build-map      - 编译地图服务"
	@echo "  make build-user     - 编译用户服务"
	@echo "  make build-notif    - 编译通知服务"
	@echo "  make run            - 运行网关服务"
	@echo "  make run-all        - 运行所有服务"
	@echo "  make test           - 运行测试"
	@echo "  make test-coverage  - 运行测试并生成覆盖率报告"
	@echo "  make lint           - 代码检查"
	@echo "  make clean          - 清理构建产物"
	@echo "  make docker-build   - 构建Docker镜像"
	@echo "  make docker-run     - 运行Docker容器"
	@echo "  make migrate-up     - 执行数据库迁移"
	@echo "  make migrate-down   - 回滚数据库迁移"
	@echo "  make deps           - 下载依赖"
	@echo "  make tidy           - 整理依赖"
	@echo ""

## deps: 下载依赖
deps:
	$(GO) mod download

## tidy: 整理依赖
tidy:
	$(GO) mod tidy

## build: 编译所有服务
build: build-gateway build-planner build-map build-user build-notif

## build-gateway: 编译网关服务
build-gateway:
	@echo "编译网关服务..."
	$(GO) build $(GOFLAGS) -o bin/gateway $(MAIN_PATH)/gateway/

## build-planner: 编译规划服务
build-planner:
	@echo "编译规划服务..."
	$(GO) build $(GOFLAGS) -o bin/planner $(MAIN_PATH)/planner/

## build-map: 编译地图服务
build-map:
	@echo "编译地图服务..."
	$(GO) build $(GOFLAGS) -o bin/map $(MAIN_PATH)/map/

## build-user: 编译用户服务
build-user:
	@echo "编译用户服务..."
	$(GO) build $(GOFLAGS) -o bin/user $(MAIN_PATH)/user/

## build-notif: 编译通知服务
build-notif:
	@echo "编译通知服务..."
	$(GO) build $(GOFLAGS) -o bin/notification $(MAIN_PATH)/notification/

## run: 运行网关服务
run:
	$(GO) run $(MAIN_PATH)/gateway/main.go

## run-all: 运行所有服务
run-all:
	@echo "启动所有服务..."
	@for service in $(SERVICES); do \
		echo "启动 $$service 服务..."; \
		$(GO) run $(MAIN_PATH)/$$service/main.go & \
	done
	@echo "所有服务已启动"
	@wait

## test: 运行测试
test:
	$(GO) test ./... -v -count=1

## test-coverage: 运行测试并生成覆盖率报告
test-coverage:
	$(GO) test ./... -v -coverprofile=coverage.out
	$(GO) tool cover -html=coverage.out -o coverage.html
	@echo "覆盖率报告已生成: coverage.html"

## lint: 代码检查
lint:
	@which golangci-lint > /dev/null || (echo "请安装golangci-lint: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest" && exit 1)
	golangci-lint run ./...

## clean: 清理构建产物
clean:
	@echo "清理构建产物..."
	rm -rf bin/
	rm -f coverage.out coverage.html

## docker-build: 构建Docker镜像
docker-build:
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

## docker-run: 运行Docker容器
docker-run:
	docker run -d --name wanderp-server \
		-p 8080:8080 \
		-e CONFIG_PATH=/app/configs/prod.yaml \
		$(DOCKER_IMAGE):$(DOCKER_TAG)

## migrate-up: 执行数据库迁移
migrate-up:
	chmod +x scripts/migrate.sh
	./scripts/migrate.sh up dev

## migrate-down: 回滚数据库迁移
migrate-down:
	chmod +x scripts/migrate.sh
	./scripts/migrate.sh down dev

## swagger: 生成Swagger文档
swagger:
	@which swag > /dev/null || (echo "请安装swag: go install github.com/swaggo/swag/cmd/swag@latest" && exit 1)
	swag init -g cmd/gateway/main.go -o api/swagger
