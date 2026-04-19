package handler

import (
	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/gateway"
)

// RegisterRoutes 注册所有路由
func RegisterRoutes(r *gin.Engine) {
	// 健康检查
	r.GET("/health", HealthCheck)

	// 注册下游服务路由转发
	for _, service := range gateway.Services {
		r.Any(service.Prefix+"/*path", NewReverseProxy(service))
	}
}
