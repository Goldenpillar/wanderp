package repository

import (
	"context"

	"github.com/wanderp/server/internal/planner/model"
	"gorm.io/gorm"
)

// TripRepository 行程数据访问接口
type TripRepository interface {
	Create(ctx context.Context, trip *model.Trip) error
	GetByID(ctx context.Context, id uint) (*model.Trip, error)
	Update(ctx context.Context, trip *model.Trip) error
	Delete(ctx context.Context, id uint) error
	ListByUserID(ctx context.Context, userID uint, page, size int) ([]model.Trip, int64, error)
	ListMembers(ctx context.Context, tripID uint) ([]model.TripMember, error)
	AddMember(ctx context.Context, member *model.TripMember) error
	RemoveMember(ctx context.Context, tripID, userID uint) error
}

// tripRepository 行程数据访问实现
type tripRepository struct {
	db *gorm.DB
}

// NewTripRepository 创建行程数据访问实例
func NewTripRepository(db *gorm.DB) TripRepository {
	return &tripRepository{db: db}
}

// Create 创建行程
func (r *tripRepository) Create(ctx context.Context, trip *model.Trip) error {
	return r.db.WithContext(ctx).Create(trip).Error
}

// GetByID 根据ID获取行程
func (r *tripRepository) GetByID(ctx context.Context, id uint) (*model.Trip, error) {
	var trip model.Trip
	err := r.db.WithContext(ctx).
		Preload("Activities").
		Preload("Members").
		First(&trip, id).Error
	if err != nil {
		return nil, err
	}
	return &trip, nil
}

// Update 更新行程
func (r *tripRepository) Update(ctx context.Context, trip *model.Trip) error {
	return r.db.WithContext(ctx).Save(trip).Error
}

// Delete 删除行程（软删除）
func (r *tripRepository) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Delete(&model.Trip{}, id).Error
}

// ListByUserID 根据用户ID列出行程
func (r *tripRepository) ListByUserID(ctx context.Context, userID uint, page, size int) ([]model.Trip, int64, error) {
	var trips []model.Trip
	var total int64

	db := r.db.WithContext(ctx).Model(&model.Trip{})

	// 查询创建者或成员的行程
	err := db.Joins("LEFT JOIN trip_members ON trip_members.trip_id = trips.id").
		Where("trips.creator_id = ? OR trip_members.user_id = ?", userID, userID).
		Count(&total).Error
	if err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * size
	err = db.Joins("LEFT JOIN trip_members ON trip_members.trip_id = trips.id").
		Where("trips.creator_id = ? OR trip_members.user_id = ?", userID, userID).
		Preload("Activities").
		Order("trips.created_at DESC").
		Offset(offset).Limit(size).
		Find(&trips).Error
	if err != nil {
		return nil, 0, err
	}

	return trips, total, nil
}

// ListMembers 列出行程成员
func (r *tripRepository) ListMembers(ctx context.Context, tripID uint) ([]model.TripMember, error) {
	var members []model.TripMember
	err := r.db.WithContext(ctx).
		Where("trip_id = ?", tripID).
		Find(&members).Error
	if err != nil {
		return nil, err
	}
	return members, nil
}

// AddMember 添加行程成员
func (r *tripRepository) AddMember(ctx context.Context, member *model.TripMember) error {
	return r.db.WithContext(ctx).Create(member).Error
}

// RemoveMember 移除行程成员
func (r *tripRepository) RemoveMember(ctx context.Context, tripID, userID uint) error {
	return r.db.WithContext(ctx).
		Where("trip_id = ? AND user_id = ?", tripID, userID).
		Delete(&model.TripMember{}).Error
}
