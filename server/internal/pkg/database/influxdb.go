package database

import (
	"context"
	"fmt"

	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"github.com/influxdata/influxdb-client-go/v2/api"
	"github.com/wanderp/server/internal/pkg/config"
)

var (
	InfluxClient influxdb2.Client
	InfluxAPI    api.QueryAPI
	InfluxWriteAPI api.WriteAPI
)

// InitInfluxDB 初始化InfluxDB连接
func InitInfluxDB(cfg *config.InfluxDBConfig) (influxdb2.Client, error) {
	client := influxdb2.NewClient(cfg.URL, cfg.Token)

	// 测试连接
	_, err := client.Ping(context.Background())
	if err != nil {
		return nil, fmt.Errorf("连接InfluxDB失败: %w", err)
	}

	InfluxClient = client
	InfluxAPI = client.QueryAPI(cfg.Org)
	InfluxWriteAPI = client.WriteAPI(cfg.Org, cfg.Bucket)

	return client, nil
}

// GetInfluxClient 获取InfluxDB客户端
func GetInfluxClient() influxdb2.Client {
	return InfluxClient
}

// GetInfluxQueryAPI 获取InfluxDB查询API
func GetInfluxQueryAPI() api.QueryAPI {
	return InfluxAPI
}

// CloseInfluxDB 关闭InfluxDB连接
func CloseInfluxDB() {
	if InfluxClient != nil {
		InfluxClient.Close()
	}
}
