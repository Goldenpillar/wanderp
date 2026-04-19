package service

import (
	"context"

	"github.com/wanderp/server/internal/notification"
)

// PushService 推送服务接口
type PushService interface {
	// SendPush 发送推送通知
	SendPush(ctx context.Context, userID uint, title, body string, data map[string]interface{}) error
	// SendBatchPush 批量发送推送
	SendBatchPush(ctx context.Context, userIDs []uint, title, body string, data map[string]interface{}) error
	// SendTripNotification 发送行程通知
	SendTripNotification(ctx context.Context, tripID uint, title, body string) error
	// SubscribePush 订阅推送
	SubscribePush(ctx context.Context, userID uint, deviceToken string, platform string) error
	// UnsubscribePush 取消订阅推送
	UnsubscribePush(ctx context.Context, userID uint, deviceToken string) error
}

// pushService 推送服务实现
type pushService struct {
	hub *notification.Hub
}

// NewPushService 创建推送服务实例
func NewPushService(hub *notification.Hub) PushService {
	return &pushService{hub: hub}
}

// SendPush 发送推送通知
func (s *pushService) SendPush(ctx context.Context, userID uint, title, body string, data map[string]interface{}) error {
	// TODO: 实现推送通知
	// 1. 通过WebSocket发送实时通知
	// 2. 通过APNs/FCM发送离线推送
	_ = ctx
	_ = title
	_ = body
	_ = data
	return nil
}

// SendBatchPush 批量发送推送
func (s *pushService) SendBatchPush(ctx context.Context, userIDs []uint, title, body string, data map[string]interface{}) error {
	// TODO: 实现批量推送
	return nil
}

// SendTripNotification 发送行程通知
func (s *pushService) SendTripNotification(ctx context.Context, tripID uint, title, body string) error {
	// TODO: 向行程所有成员发送通知
	return nil
}

// SubscribePush 订阅推送
func (s *pushService) SubscribePush(ctx context.Context, userID uint, deviceToken string, platform string) error {
	// TODO: 保存设备推送令牌
	return nil
}

// UnsubscribePush 取消订阅推送
func (s *pushService) UnsubscribePush(ctx context.Context, userID uint, deviceToken string) error {
	// TODO: 移除设备推送令牌
	return nil
}
