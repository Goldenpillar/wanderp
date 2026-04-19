package model

import (
	"time"

	"gorm.io/gorm"
)

// Expense 消费记录模型
type Expense struct {
	ID          uint           `json:"id" gorm:"primaryKey;autoIncrement"`
	TripID      uint           `json:"trip_id" gorm:"not null;index;comment:行程ID"`
	UserID      uint           `json:"user_id" gorm:"not null;index;comment:消费用户ID"`
	Category    string         `json:"category" gorm:"type:varchar(50);not null;comment:分类(food/transport/accommodation/ticket/shopping/other)"`
	Amount      float64        `json:"amount" gorm:"type:decimal(10,2);not null;comment:金额"`
	Currency    string         `json:"currency" gorm:"type:varchar(10);default:CNY;comment:货币"`
	Description string         `json:"description" gorm:"type:varchar(500);comment:描述"`
	PayMethod   string         `json:"pay_method" gorm:"type:varchar(50);comment:支付方式(cash/card/wechat/alipay)"`
	PayerID     uint           `json:"payer_id" gorm:"not null;comment:付款人ID"`
	Latitude    float64        `json:"latitude" gorm:"type:double;comment:消费地点纬度"`
	Longitude   float64        `json:"longitude" gorm:"type:double;comment:消费地点经度"`
	PhotoURL    string         `json:"photo_url" gorm:"type:varchar(500);comment:消费凭证图片"`
	ExpenseTime time.Time      `json:"expense_time" gorm:"type:timestamp;comment:消费时间"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// TableName 指定表名
func (Expense) TableName() string {
	return "expenses"
}

// ExpenseSummary 消费汇总
type ExpenseSummary struct {
	TripID       uint              `json:"trip_id"`
	TotalAmount  float64           `json:"total_amount"`
	CategoryList []CategorySummary `json:"category_list"`
	MemberList   []MemberSummary   `json:"member_list"`
}

// CategorySummary 分类汇总
type CategorySummary struct {
	Category string  `json:"category"`
	Amount   float64 `json:"amount"`
	Count    int     `json:"count"`
}

// MemberSummary 成员消费汇总
type MemberSummary struct {
	UserID  uint    `json:"user_id"`
	Amount  float64 `json:"amount"`
	Count   int     `json:"count"`
}

// ExpenseCreateRequest 创建消费请求
type ExpenseCreateRequest struct {
	TripID      uint    `json:"trip_id" binding:"required" example:"1"`
	Category    string  `json:"category" binding:"required" example:"food"`
	Amount      float64 `json:"amount" binding:"required,gt=0" example:"128.50"`
	Currency    string  `json:"currency" example:"CNY"`
	Description string  `json:"description" example:"午餐-烤鸭"`
	PayMethod   string  `json:"pay_method" example:"wechat"`
	PayerID     uint    `json:"payer_id" binding:"required" example:"1"`
	Latitude    float64 `json:"latitude" example:"39.9042"`
	Longitude   float64 `json:"longitude" example:"116.4074"`
	PhotoURL    string  `json:"photo_url"`
	ExpenseTime string  `json:"expense_time" example:"2025-01-15T12:30:00Z"`
}
