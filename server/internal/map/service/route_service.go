package service

import (
	"context"

	"github.com/wanderp/server/internal/map/model"
)

// RouteService 路线规划服务接口
type RouteService interface {
	// PlanRoute 规划路线
	PlanRoute(ctx context.Context, req *model.RouteRequest) (*model.Route, error)
	// GetMultipleRoutes 获取多条备选路线
	GetMultipleRoutes(ctx context.Context, req *model.RouteRequest) ([]*model.Route, error)
	// GetTransitRoute 获取公共交通路线
	GetTransitRoute(ctx context.Context, origin, destination model.Location, city string) ([]*model.Route, error)
}

// routeService 路线规划服务实现
type routeService struct {
	amapSvc AMapService
}

// NewRouteService 创建路线规划服务实例
func NewRouteService(amapSvc AMapService) RouteService {
	return &routeService{amapSvc: amapSvc}
}

// PlanRoute 规划路线
func (s *routeService) PlanRoute(ctx context.Context, req *model.RouteRequest) (*model.Route, error) {
	// TODO: 调用高德地图路线规划API
	// 根据mode选择不同的API:
	// - driving: https://restapi.amap.com/v3/direction/driving
	// - walking: https://restapi.amap.com/v3/direction/walking
	// - cycling: https://restapi.amap.com/v4/direction/bicycling
	// - transit: https://restapi.amap.com/v3/direction/transit/integrated
	return nil, nil
}

// GetMultipleRoutes 获取多条备选路线
func (s *routeService) GetMultipleRoutes(ctx context.Context, req *model.RouteRequest) ([]*model.Route, error) {
	// TODO: 使用不同策略获取多条备选路线
	strategies := []string{"fastest", "shortest", "most_economic"}
	var routes []*model.Route

	for _, strategy := range strategies {
		req.Strategy = strategy
		route, err := s.PlanRoute(ctx, req)
		if err != nil {
			continue
		}
		routes = append(routes, route)
	}

	return routes, nil
}

// GetTransitRoute 获取公共交通路线
func (s *routeService) GetTransitRoute(ctx context.Context, origin, destination model.Location, city string) ([]*model.Route, error) {
	// TODO: 调用高德地图公交路线规划API
	_ = origin
	_ = destination
	_ = city
	return nil, nil
}
