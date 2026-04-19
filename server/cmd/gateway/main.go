package main

import (
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/gateway/handler"
	gatewayMiddleware "github.com/wanderp/server/internal/gateway/middleware"
	"github.com/wanderp/server/internal/pkg/config"
	"github.com/wanderp/server/internal/pkg/logger"
)

func main() {
	// 加载配置
	cfg, err := config.Load("configs/dev.yaml")
	if err != nil {
		panic(fmt.Sprintf("加载配置失败: %v", err))
	}

	// 初始化日志
	log := logger.InitLogger(cfg.Log.Level, cfg.Log.Format)
	defer logger.Sync()

	// 设置Gin模式
	gin.SetMode(cfg.Server.Mode)

	// 创建Gin引擎
	r := gin.New()

	// 注册全局中间件
	r.Use(gatewayMiddleware.Logger(log))
	r.Use(gatewayMiddleware.Recovery(log))
	r.Use(gatewayMiddleware.CORS())
	r.Use(gatewayMiddleware.RateLimit(100, 200))

	// 注册路由
	handler.RegisterRoutes(r)

	// 启动服务
	addr := fmt.Sprintf(":%d", cfg.Server.Port)
	log.Info("API网关服务启动", zap.String("addr", addr))

	if err := r.Run(addr); err != nil {
		log.Fatal("API网关服务启动失败", zap.Error(err))
	}
}
