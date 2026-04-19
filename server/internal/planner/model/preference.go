package model

import "time"

// Preference 用户偏好模型
type Preference struct {
	ID            uint      `json:"id" gorm:"primaryKey;autoIncrement"`
	UserID        uint      `json:"user_id" gorm:"not null;uniqueIndex;comment:用户ID"`
	TravelStyle   string    `json:"travel_style" gorm:"type:varchar(50);comment:旅行风格(relax/adventure/culture/food/nature)"`
	TastePrefs     string    `json:"taste_prefs" gorm:"column:taste_prefs;type:varchar(100);comment:美食偏好"`
	BudgetLevel   string    `json:"budget_level" gorm:"type:varchar(20);comment:预算级别(low/medium/high)"`
	PaceLevel     string    `json:"pace_level" gorm:"type:varchar(20);comment:节奏偏好(slow/moderate/fast)"`
	Accommodation string    `json:"accommodation" gorm:"type:varchar(50);comment:住宿偏好(hotel/hostel/apartment/camping)"`
	Transport     string    `json:"transport" gorm:"type:varchar(50);comment:交通偏好(walking/driving/public/ride)"`
	Interests     string    `json:"interests" gorm:"type:text;comment:兴趣标签(JSON数组)"`
	Avoidances    string    `json:"avoidances" gorm:"type:text;comment:回避项(JSON数组)"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

// TableName 指定表名
func (Preference) TableName() string {
	return "preferences"
}
