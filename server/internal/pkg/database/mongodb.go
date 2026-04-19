package database

import (
	"context"
	"fmt"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"github.com/wanderp/server/internal/pkg/config"
)

var MongoClient *mongo.Database

// InitMongoDB 初始化MongoDB连接
func InitMongoDB(cfg *config.MongoDBConfig) (*mongo.Database, error) {
	clientOptions := options.Client().ApplyURI(cfg.URI)
	client, err := mongo.Connect(context.Background(), clientOptions)
	if err != nil {
		return nil, fmt.Errorf("连接MongoDB失败: %w", err)
	}

	// 测试连接
	if err := client.Ping(context.Background(), nil); err != nil {
		return nil, fmt.Errorf("MongoDB连接测试失败: %w", err)
	}

	db := client.Database(cfg.Database)
	MongoClient = db
	return db, nil
}

// GetMongoDB 获取MongoDB实例
func GetMongoDB() *mongo.Database {
	return MongoClient
}
