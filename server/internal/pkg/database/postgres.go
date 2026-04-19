package database

import (
	"fmt"

	"github.com/wanderp/server/internal/pkg/config"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var PostgresDB *gorm.DB

// InitPostgres 初始化PostgreSQL连接
func InitPostgres(cfg *config.DatabaseConfig, logLevel logger.LogLevel) (*gorm.DB, error) {
	dsn := cfg.DSN()
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logLevel),
	})
	if err != nil {
		return nil, fmt.Errorf("连接PostgreSQL失败: %w", err)
	}

	// 测试连接
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("获取底层SQL DB失败: %w", err)
	}
	if err := sqlDB.Ping(); err != nil {
		return nil, fmt.Errorf("PostgreSQL连接测试失败: %w", err)
	}

	// 设置连接池
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetMaxOpenConns(100)

	PostgresDB = db
	return db, nil
}

// GetPostgres 获取PostgreSQL实例
func GetPostgres() *gorm.DB {
	return PostgresDB
}
