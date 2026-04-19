package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/middleware"
)

// Auth JWT鉴权中间件
func Auth(secret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString := middleware.GetTokenFromHeader(c)
		if tokenString == "" {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":    401,
				"message": "缺少认证令牌",
			})
			c.Abort()
			return
		}

		claims, err := middleware.ParseToken(tokenString, secret)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{
				"code":    401,
				"message": "认证令牌无效或已过期",
			})
			c.Abort()
			return
		}

		// 将用户信息存入上下文
		c.Set("user_id", claims.UserID)
		c.Set("username", claims.Username)
		c.Set("role", claims.Role)

		c.Next()
	}
}

// OptionalAuth 可选鉴权中间件（有token则解析，无token则跳过）
func OptionalAuth(secret string) gin.HandlerFunc {
	return func(c *gin.Context) {
		tokenString := middleware.GetTokenFromHeader(c)
		if tokenString != "" {
			claims, err := middleware.ParseToken(tokenString, secret)
			if err == nil {
				c.Set("user_id", claims.UserID)
				c.Set("username", claims.Username)
				c.Set("role", claims.Role)
			}
		}
		c.Next()
	}
}

// RequireRole 角色权限中间件
func RequireRole(roles ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		userRole, exists := c.Get("role")
		if !exists {
			c.JSON(http.StatusForbidden, gin.H{
				"code":    403,
				"message": "无权限访问",
			})
			c.Abort()
			return
		}

		roleStr, ok := userRole.(string)
		if !ok {
			c.JSON(http.StatusForbidden, gin.H{
				"code":    403,
				"message": "权限信息格式错误",
			})
			c.Abort()
			return
		}

		for _, role := range roles {
			if strings.EqualFold(roleStr, role) {
				c.Next()
				return
			}
		}

		c.JSON(http.StatusForbidden, gin.H{
			"code":    403,
			"message": "权限不足",
		})
		c.Abort()
	}
}
