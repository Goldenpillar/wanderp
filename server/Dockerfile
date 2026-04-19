# =============================================================================
# WanderP Server - Go服务多阶段构建 Dockerfile
# =============================================================================
# 支持构建不同服务: gateway, user, planner, map, notification
# 使用方式:
#   docker build --build-arg SERVICE=gateway -t wanderp-gateway .
#   docker build --build-arg SERVICE=user -t wanderp-user .
# =============================================================================

# ---------------------------------------------------------------------------
# 阶段1: 构建阶段 (builder)
# ---------------------------------------------------------------------------
FROM golang:1.22-alpine AS builder

# 构建参数
ARG SERVICE=gateway
ARG CGO_ENABLED=0
ARG GOOS=linux
ARG GOARCH=amd64

# 安装构建依赖
RUN apk add --no-cache git ca-certificates tzdata

# 设置工作目录
WORKDIR /build

# 先复制依赖文件，利用Docker缓存层
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码
COPY . .

# 构建指定服务
RUN CGO_ENABLED=${CGO_ENABLED} GOOS=${GOOS} GOARCH=${GOARCH} \
    go build -ldflags="-w -s \
    -X main.version=$(git describe --tags --always --dirty 2>/dev/null || echo dev) \
    -X main.buildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
    -X main.service=${SERVICE}" \
    -o /build/bin/${SERVICE} ./cmd/${SERVICE}

# ---------------------------------------------------------------------------
# 阶段2: 运行阶段 (runtime)
# ---------------------------------------------------------------------------
FROM alpine:3.19 AS runtime

# 安装运行时依赖
RUN apk add --no-cache ca-certificates tzdata curl && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    apk del curl

# 创建非root用户
RUN addgroup -g 1000 wanderp && \
    adduser -u 1000 -G wanderp -s /bin/sh -D wanderp

# 设置工作目录
WORKDIR /app

# 从构建阶段复制二进制文件
ARG SERVICE=gateway
COPY --from=builder /build/bin/${SERVICE} /app/${SERVICE}
COPY --from=builder /build/configs /app/configs

# 创建日志和数据目录
RUN mkdir -p /app/logs /app/data && \
    chown -R wanderp:wanderp /app

# 切换到非root用户
USER wanderp

# 暴露服务端口（各服务端口不同，在docker-compose中映射）
EXPOSE 8001 8002 8003 8004 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8000/health || exit 1

# 启动服务
ENTRYPOINT ["/app/${SERVICE}"]
