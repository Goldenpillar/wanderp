package handler

import (
	"net/http"
	"net/http/httputil"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/gateway"
)

// NewReverseProxy 创建反向代理处理器
func NewReverseProxy(service gateway.ServiceRoute) gin.HandlerFunc {
	return func(c *gin.Context) {
		// 创建反向代理
		proxy := httputil.NewSingleHostReverseProxy(nil)

		// 修改请求
		c.Request.URL.Scheme = "http"
		c.Request.URL.Host = strings.TrimPrefix(service.UpstreamURL, "http://")

		// 移除路由前缀，保留子路径
		c.Request.URL.Path = strings.TrimPrefix(c.Request.URL.Path, service.Prefix)
		if c.Request.URL.Path == "" {
			c.Request.URL.Path = "/"
		}

		// 设置代理头
		c.Request.Header.Set("X-Forwarded-Host", c.Request.Host)
		c.Request.Header.Set("X-Forwarded-For", c.ClientIP())
		c.Request.Header.Set("X-Real-IP", c.ClientIP())

		// 代理请求
		proxy.ServeHTTP(c.Writer, c.Request)
	}
}

// HealthCheck 健康检查接口
func HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "网关服务运行正常",
		"data": gin.H{
			"services": []string{"user", "planner", "map", "notification"},
		},
	})
}
