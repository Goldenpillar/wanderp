package database

import (
	"context"
	"fmt"

	"github.com/go-redis/redis/v8"
	"github.com/wanderp/server/internal/pkg/config"
)

var RedisClient *redis.Client

// InitRedis 初始化Redis连接
func InitRedis(cfg *config.RedisConfig) (*redis.Client, error) {
	client := redis.NewClient(&redis.Options{
		Addr:     cfg.Addr,
		Password: cfg.Password,
		DB:       cfg.DB,
	})

	// 测试连接
	_, err := client.Ping(context.Background()).Result()
	if err != nil {
		return nil, fmt.Errorf("连接Redis失败: %w", err)
	}

	RedisClient = client
	return client, nil
}

// GetRedis 获取Redis客户端实例
func GetRedis() *redis.Client {
	return RedisClient
}
