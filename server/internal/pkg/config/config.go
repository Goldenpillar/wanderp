package config

import (
	"fmt"
	"time"

	"github.com/spf13/viper"
)

// Config 全局配置结构
type Config struct {
	Server   ServerConfig   `mapstructure:"server"`
	Database DatabaseConfig `mapstructure:"database"`
	Redis    RedisConfig    `mapstructure:"redis"`
	InfluxDB InfluxDBConfig `mapstructure:"influxdb"`
	MongoDB  MongoDBConfig  `mapstructure:"mongodb"`
	JWT      JWTConfig      `mapstructure:"jwt"`
	AMap     AMapConfig     `mapstructure:"amap"`
	MQTT     MQTTConfig     `mapstructure:"mqtt"`
	Log      LogConfig      `mapstructure:"log"`
}

// ServerConfig HTTP服务配置
type ServerConfig struct {
	Port int    `mapstructure:"port"`
	Mode string `mapstructure:"mode"` // debug / release / test
}

// DatabaseConfig 数据库配置
type DatabaseConfig struct {
	Host     string `mapstructure:"host"`
	Port     int    `mapstructure:"port"`
	User     string `mapstructure:"user"`
	Password string `mapstructure:"password"`
	DBName   string `mapstructure:"dbname"`
	SSLMode  string `mapstructure:"sslmode"`
	TimeZone string `mapstructure:"timezone"`
}

// DSN 生成PostgreSQL连接字符串
func (d *DatabaseConfig) DSN() string {
	return fmt.Sprintf(
		"host=%s port=%d user=%s password=%s dbname=%s sslmode=%s TimeZone=%s",
		d.Host, d.Port, d.User, d.Password, d.DBName, d.SSLMode, d.TimeZone,
	)
}

// RedisConfig Redis配置
type RedisConfig struct {
	Addr     string `mapstructure:"addr"`
	Password string `mapstructure:"password"`
	DB       int    `mapstructure:"db"`
}

// InfluxDBConfig InfluxDB配置
type InfluxDBConfig struct {
	URL    string `mapstructure:"url"`
	Token  string `mapstructure:"token"`
	Org    string `mapstructure:"org"`
	Bucket string `mapstructure:"bucket"`
}

// MongoDBConfig MongoDB配置
type MongoDBConfig struct {
	URI      string `mapstructure:"uri"`
	Database string `mapstructure:"database"`
}

// JWTConfig JWT配置
type JWTConfig struct {
	Secret     string        `mapstructure:"secret"`
	ExpireHour time.Duration `mapstructure:"expire_hour"`
}

// AMapConfig 高德地图API配置
type AMapConfig struct {
	Key      string `mapstructure:"key"`
	BaseURL  string `mapstructure:"base_url"`
}

// MQTTConfig MQTT配置
type MQTTConfig struct {
	Broker   string `mapstructure:"broker"`
	ClientID string `mapstructure:"client_id"`
	Username string `mapstructure:"username"`
	Password string `mapstructure:"password"`
}

// LogConfig 日志配置
type LogConfig struct {
	Level  string `mapstructure:"level"`  // debug / info / warn / error
	Format string `mapstructure:"format"` // json / console
}

var globalConfig *Config

// Load 加载配置文件
func Load(configPath string) (*Config, error) {
	viper.SetConfigFile(configPath)
	viper.SetConfigType("yaml")

	// 设置默认值
	viper.SetDefault("server.port", 8080)
	viper.SetDefault("server.mode", "debug")
	viper.SetDefault("database.host", "localhost")
	viper.SetDefault("database.port", 5432)
	viper.SetDefault("database.sslmode", "disable")
	viper.SetDefault("database.timezone", "Asia/Shanghai")
	viper.SetDefault("redis.addr", "localhost:6379")
	viper.SetDefault("redis.db", 0)
	viper.SetDefault("jwt.expire_hour", 72)
	viper.SetDefault("log.level", "debug")
	viper.SetDefault("log.format", "console")

	// 支持环境变量覆盖
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		return nil, fmt.Errorf("读取配置文件失败: %w", err)
	}

	var cfg Config
	if err := viper.Unmarshal(&cfg); err != nil {
		return nil, fmt.Errorf("解析配置文件失败: %w", err)
	}

	globalConfig = &cfg
	return &cfg, nil
}

// Get 获取全局配置
func Get() *Config {
	return globalConfig
}
