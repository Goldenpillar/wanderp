package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/time/rate"
)

// RateLimiter 限流器
type RateLimiter struct {
	limiters map[string]*rate.Limiter
	mu       sync.Mutex
	rate     rate.Limit
	burst    int
}

// NewRateLimiter 创建限流器实例
func NewRateLimiter(r rate.Limit, burst int) *RateLimiter {
	return &RateLimiter{
		limiters: make(map[string]*rate.Limiter),
		rate:     r,
		burst:    burst,
	}
}

// getLimiter 获取指定IP的限流器
func (rl *RateLimiter) getLimiter(ip string) *rate.Limiter {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	limiter, exists := rl.limiters[ip]
	if !exists {
		limiter = rate.NewLimiter(rl.rate, rl.burst)
		rl.limiters[ip] = limiter
	}

	return limiter
}

// RateLimit 限流中间件（基于IP）
func RateLimit(r rate.Limit, burst int) gin.HandlerFunc {
	limiter := NewRateLimiter(r, burst)

	return func(c *gin.Context) {
		ip := c.ClientIP()

		if !limiter.getLimiter(ip).Allow() {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"code":    429,
				"message": "请求过于频繁，请稍后再试",
			})
			c.Abort()
			return
		}

		c.Next()
	}
}

// RateLimitByToken 基于Token的限流中间件
func RateLimitByToken(r rate.Limit, burst int) gin.HandlerFunc {
	limiter := NewRateLimiter(r, burst)

	return func(c *gin.Context) {
		// 优先使用token，没有则使用IP
		key := c.GetHeader("Authorization")
		if key == "" {
			key = c.ClientIP()
		}

		if !limiter.getLimiter(key).Allow() {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"code":    429,
				"message": "请求过于频繁，请稍后再试",
			})
			c.Abort()
			return
		}

		c.Next()
	}
}
