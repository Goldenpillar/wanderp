package model

import (
	"time"

	"gorm.io/datatypes"
	"gorm.io/gorm"
)

// Activity 活动模型
type Activity struct {
	ID          uint           `json:"id" gorm:"primaryKey;autoIncrement"`
	TripID      uint           `json:"trip_id" gorm:"not null;index;comment:行程ID"`
	Title       string         `json:"title" gorm:"type:varchar(200);not null;comment:活动标题"`
	Description string         `json:"description" gorm:"type:text;comment:活动描述"`
	Category    string         `json:"category" gorm:"type:varchar(50);comment:分类(sightseeing/food/transport/accommodation/shopping/entertainment)"`
	StartTime   *time.Time     `json:"start_time" gorm:"type:timestamp;comment:开始时间"`
	EndTime     *time.Time     `json:"end_time" gorm:"type:timestamp;comment:结束时间"`
	Latitude    float64        `json:"latitude" gorm:"type:double;comment:纬度"`
	Longitude   float64        `json:"longitude" gorm:"type:double;comment:经度"`
	Address     string         `json:"address" gorm:"type:varchar(500);comment:地址"`
	Cost        float64        `json:"cost" gorm:"type:decimal(10,2);default:0;comment:预估费用"`
	SortOrder   int            `json:"sort_order" gorm:"default:0;comment:排序序号"`
	DayIndex    int            `json:"day_index" gorm:"default:1;comment:第几天"`
	Votes       []Vote         `json:"votes" gorm:"foreignKey:ActivityID"`
	Options     datatypes.JSON `json:"options" gorm:"type:jsonb;comment:活动选项(JSON数组)"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// TableName 指定表名
func (Activity) TableName() string {
	return "activities"
}

// Vote 投票模型
type Vote struct {
	ID         uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	ActivityID uint      `json:"activity_id" gorm:"not null;index;comment:活动ID"`
	UserID     uint      `json:"user_id" gorm:"not null;index;comment:用户ID"`
	Type       string    `json:"type" gorm:"type:varchar(10);default:up;comment:投票类型(up/down)"`
	CreatedAt  time.Time `json:"created_at"`
}

// TableName 指定表名
func (Vote) TableName() string {
	return "votes"
}
