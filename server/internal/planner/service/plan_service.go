package service

import (
	"context"

	"github.com/wanderp/server/internal/planner/model"
)

// PlanService AI规划服务接口
type PlanService interface {
	// GeneratePlan 生成行程规划
	GeneratePlan(ctx context.Context, tripID uint, destination string, days int, preferences *model.Preference) (*model.Trip, error)
	// OptimizePlan 优化行程规划
	OptimizePlan(ctx context.Context, tripID uint) (*model.Trip, error)
	// AddActivity 添加活动到行程
	AddActivity(ctx context.Context, tripID uint, activity *model.Activity) (*model.Activity, error)
	// RemoveActivity 从行程移除活动
	RemoveActivity(ctx context.Context, tripID, activityID uint) error
	// VoteActivity 对活动投票
	VoteActivity(ctx context.Context, activityID, userID uint, voteType string) error
	// GetRecommendations 获取推荐活动
	GetRecommendations(ctx context.Context, destination string, category string) ([]model.Activity, error)
}

// planService AI规划服务实现
type planService struct {
	// TODO: 注入AI服务客户端和仓库
}

// NewPlanService 创建AI规划服务实例
func NewPlanService() PlanService {
	return &planService{}
}

// GeneratePlan 生成行程规划
func (s *planService) GeneratePlan(ctx context.Context, tripID uint, destination string, days int, preferences *model.Preference) (*model.Trip, error) {
	// TODO: 调用AI服务生成行程规划
	// 1. 根据目的地和偏好收集POI信息
	// 2. 调用AI模型生成每日行程安排
	// 3. 保存规划结果到数据库
	return nil, nil
}

// OptimizePlan 优化行程规划
func (s *planService) OptimizePlan(ctx context.Context, tripID uint) (*model.Trip, error) {
	// TODO: 根据用户反馈优化行程
	// 1. 获取当前行程和投票数据
	// 2. 调用AI模型重新规划
	// 3. 更新行程数据
	return nil, nil
}

// AddActivity 添加活动到行程
func (s *planService) AddActivity(ctx context.Context, tripID uint, activity *model.Activity) (*model.Activity, error) {
	// TODO: 实现添加活动逻辑
	activity.TripID = tripID
	return activity, nil
}

// RemoveActivity 从行程移除活动
func (s *planService) RemoveActivity(ctx context.Context, tripID, activityID uint) error {
	// TODO: 实现移除活动逻辑
	return nil
}

// VoteActivity 对活动投票
func (s *planService) VoteActivity(ctx context.Context, activityID, userID uint, voteType string) error {
	// TODO: 实现投票逻辑
	return nil
}

// GetRecommendations 获取推荐活动
func (s *planService) GetRecommendations(ctx context.Context, destination string, category string) ([]model.Activity, error) {
	// TODO: 调用地图服务获取推荐POI
	return nil, nil
}
