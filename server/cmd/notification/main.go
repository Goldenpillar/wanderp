package main

import (
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/notification"
	"github.com/wanderp/server/internal/notification/handler"
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
	r.Use(gin.Recovery())

	// 初始化WebSocket Hub
	hub := notification.NewHub(log)
	go hub.Run()

	// 注册路由
	handler.RegisterPushRoutes(r)
	handler.RegisterWebSocketRoutes(r, hub)

	// 启动服务（通知服务端口8004）
	addr := ":8004"
	log.Info("通知服务启动", zap.String("addr", addr))

	if err := r.Run(addr); err != nil {
		log.Fatal("通知服务启动失败", zap.Error(err))
	}
}
