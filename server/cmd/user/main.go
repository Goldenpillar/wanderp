package main

import (
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/config"
	"github.com/wanderp/server/internal/pkg/logger"
	"github.com/wanderp/server/internal/user/handler"
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
	r.Use(gin.Recovery())

	// 注册路由
	handler.RegisterAuthRoutes(r)
	handler.RegisterUserRoutes(r)
	handler.RegisterExpenseRoutes(r)

	// 启动服务（用户服务端口8001）
	addr := ":8001"
	log.Info("用户服务启动", zap.String("addr", addr))

	if err := r.Run(addr); err != nil {
		log.Fatal("用户服务启动失败", zap.Error(err))
	}
}
