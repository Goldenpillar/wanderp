package service

import (
	"context"

	"github.com/wanderp/server/internal/planner/model"
)

// TripService 行程服务接口
type TripService interface {
	// CreateTrip 创建行程
	CreateTrip(ctx context.Context, userID uint, trip *model.Trip) (*model.Trip, error)
	// GetTrip 获取行程详情
	GetTrip(ctx context.Context, id uint) (*model.Trip, error)
	// UpdateTrip 更新行程
	UpdateTrip(ctx context.Context, id uint, trip *model.Trip) (*model.Trip, error)
	// DeleteTrip 删除行程
	DeleteTrip(ctx context.Context, id uint) error
	// ListTrips 列出用户的行程
	ListTrips(ctx context.Context, userID uint, page, size int) ([]model.Trip, int64, error)
	// AddMember 添加行程成员
	AddMember(ctx context.Context, tripID, userID uint, role string) error
	// RemoveMember 移除行程成员
	RemoveMember(ctx context.Context, tripID, userID uint) error
}

// tripService 行程服务实现
type tripService struct {
	repo repository.TripRepository
}

// NewTripService 创建行程服务实例
func NewTripService(repo repository.TripRepository) TripService {
	return &tripService{repo: repo}
}

// CreateTrip 创建行程
func (s *tripService) CreateTrip(ctx context.Context, userID uint, trip *model.Trip) (*model.Trip, error) {
	// TODO: 实现创建行程逻辑
	trip.CreatorID = userID
	err := s.repo.Create(ctx, trip)
	if err != nil {
		return nil, err
	}
	return trip, nil
}

// GetTrip 获取行程详情
func (s *tripService) GetTrip(ctx context.Context, id uint) (*model.Trip, error) {
	// TODO: 实现获取行程详情逻辑
	return s.repo.GetByID(ctx, id)
}

// UpdateTrip 更新行程
func (s *tripService) UpdateTrip(ctx context.Context, id uint, trip *model.Trip) (*model.Trip, error) {
	// TODO: 实现更新行程逻辑
	trip.ID = id
	err := s.repo.Update(ctx, trip)
	if err != nil {
		return nil, err
	}
	return trip, nil
}

// DeleteTrip 删除行程
func (s *tripService) DeleteTrip(ctx context.Context, id uint) error {
	// TODO: 实现删除行程逻辑
	return s.repo.Delete(ctx, id)
}

// ListTrips 列出用户的行程
func (s *tripService) ListTrips(ctx context.Context, userID uint, page, size int) ([]model.Trip, int64, error) {
	// TODO: 实现列出行程逻辑
	return s.repo.ListByUserID(ctx, userID, page, size)
}

// AddMember 添加行程成员
func (s *tripService) AddMember(ctx context.Context, tripID, userID uint, role string) error {
	// TODO: 实现添加成员逻辑
	return s.repo.AddMember(ctx, &model.TripMember{
		TripID:   tripID,
		UserID:   userID,
		Role:     role,
	})
}

// RemoveMember 移除行程成员
func (s *tripService) RemoveMember(ctx context.Context, tripID, userID uint) error {
	// TODO: 实现移除成员逻辑
	return s.repo.RemoveMember(ctx, tripID, userID)
}
