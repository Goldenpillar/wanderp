package model

import (
	"time"

	"gorm.io/gorm"
)

// Trip 行程模型
type Trip struct {
	ID          uint           `json:"id" gorm:"primaryKey;autoIncrement"`
	Title       string         `json:"title" gorm:"type:varchar(200);not null;comment:行程标题"`
	Description string         `json:"description" gorm:"type:text;comment:行程描述"`
	Destination string         `json:"destination" gorm:"type:varchar(200);comment:目的地"`
	StartDate   *time.Time     `json:"start_date" gorm:"type:timestamp;comment:开始日期"`
	EndDate     *time.Time     `json:"end_date" gorm:"type:timestamp;comment:结束日期"`
	CoverImage  string         `json:"cover_image" gorm:"type:varchar(500);comment:封面图片URL"`
	Status      string         `json:"status" gorm:"type:varchar(20);default:draft;comment:状态(draft/planning/confirmed/completed/cancelled)"`
	CreatorID   uint           `json:"creator_id" gorm:"not null;index;comment:创建者ID"`
	Budget      float64        `json:"budget" gorm:"type:decimal(10,2);default:0;comment:预算"`
	Activities  []Activity     `json:"activities" gorm:"foreignKey:TripID"`
	Members     []TripMember   `json:"members" gorm:"foreignKey:TripID"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

// TableName 指定表名
func (Trip) TableName() string {
	return "trips"
}

// TripMember 行程成员模型
type TripMember struct {
	ID        uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	TripID    uint      `json:"trip_id" gorm:"not null;index;comment:行程ID"`
	UserID    uint      `json:"user_id" gorm:"not null;index;comment:用户ID"`
	Role      string    `json:"role" gorm:"type:varchar(20);default:member;comment:角色(owner/editor/viewer)"`
	JoinedAt  time.Time `json:"joined_at"`
	CreatedAt time.Time `json:"created_at"`
}

// TableName 指定表名
func (TripMember) TableName() string {
	return "trip_members"
}
