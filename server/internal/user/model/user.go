package model

import (
	"time"

	"gorm.io/gorm"
)

// User 用户模型
type User struct {
	ID        uint           `json:"id" gorm:"primaryKey;autoIncrement"`
	Username  string         `json:"username" gorm:"type:varchar(50);uniqueIndex;not null;comment:用户名"`
	Email     string         `json:"email" gorm:"type:varchar(100);uniqueIndex;not null;comment:邮箱"`
	Phone     string         `json:"phone" gorm:"type:varchar(20);uniqueIndex;comment:手机号"`
	Password  string         `json:"-" gorm:"type:varchar(255);not null;comment:密码哈希"`
	Avatar    string         `json:"avatar" gorm:"type:varchar(500);comment:头像URL"`
	Nickname  string         `json:"nickname" gorm:"type:varchar(50);comment:昵称"`
	Bio       string         `json:"bio" gorm:"type:varchar(200);comment:个人简介"`
	Gender    string         `json:"gender" gorm:"type:varchar(10);default:unknown;comment:性别(male/female/unknown)"`
	Birthday  *time.Time     `json:"birthday" gorm:"type:date;comment:生日"`
	Location  string         `json:"location" gorm:"type:varchar(200);comment:所在地"`
	Status    string         `json:"status" gorm:"type:varchar(20);default:active;comment:状态(active/disabled/banned)"`
	LastLogin *time.Time     `json:"last_login" gorm:"type:timestamp;comment:最后登录时间"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// TableName 指定表名
func (User) TableName() string {
	return "users"
}

// UserProfile 用户公开信息（不包含敏感字段）
type UserProfile struct {
	ID       uint   `json:"id"`
	Username string `json:"username"`
	Nickname string `json:"nickname"`
	Avatar   string `json:"avatar"`
	Bio      string `json:"bio"`
	Gender   string `json:"gender"`
	Location string `json:"location"`
}

// RegisterRequest 注册请求
type RegisterRequest struct {
	Username string `json:"username" binding:"required,min=3,max=50" example:"wanderer"`
	Email    string `json:"email" binding:"required,email" example:"user@example.com"`
	Phone    string `json:"phone" binding:"omitempty" example:"13800138000"`
	Password string `json:"password" binding:"required,min=8" example:"password123"`
}

// LoginRequest 登录请求
type LoginRequest struct {
	Username string `json:"username" binding:"required" example:"wanderer"`
	Password string `json:"password" binding:"required" example:"password123"`
}

// LoginResponse 登录响应
type LoginResponse struct {
	Token     string       `json:"token"`
	ExpiresAt int64        `json:"expires_at"`
	User      UserProfile  `json:"user"`
}
