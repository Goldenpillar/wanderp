package main

import (
	"fmt"

	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/config"
	"github.com/wanderp/server/internal/pkg/logger"
	"github.com/wanderp/server/internal/planner/handler"
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
	handler.RegisterTripRoutes(r)
	handler.RegisterPlanRoutes(r)
	handler.RegisterPreferenceRoutes(r)

	// 启动服务（规划服务端口8002）
	addr := ":8002"
	log.Info("规划服务启动", zap.String("addr", addr))

	if err := r.Run(addr); err != nil {
		log.Fatal("规划服务启动失败", zap.Error(err))
	}
}
