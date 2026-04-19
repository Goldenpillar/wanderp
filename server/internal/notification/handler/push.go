package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"github.com/wanderp/server/internal/notification"
	"github.com/wanderp/server/internal/pkg/response"
)

// PushHandler 推送处理器
type PushHandler struct {
	// pushSvc service.PushService
}

// NewPushHandler 创建推送处理器
func NewPushHandler() *PushHandler {
	return &PushHandler{}
}

// SendPush 发送推送
// @Summary 发送推送通知
// @Description 向指定用户发送推送通知
// @Tags 推送
// @Accept json
// @Produce json
// @Param request body map[string]interface{} true "推送信息"
// @Success 200 {object} response.Response
// @Router /push/send [post]
func (h *PushHandler) SendPush(c *gin.Context) {
	var req struct {
		UserID  uint                   `json:"user_id" binding:"required"`
		Title   string                 `json:"title" binding:"required"`
		Body    string                 `json:"body" binding:"required"`
		Data    map[string]interface{} `json:"data"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	// TODO: 调用 pushSvc.SendPush
	response.SuccessWithMessage(c, "推送已发送", nil)
}

// SubscribePush 订阅推送
// @Summary 订阅推送
// @Description 注册设备推送令牌
// @Tags 推送
// @Accept json
// @Produce json
// @Param request body map[string]string true "订阅信息 {device_token, platform}"
// @Success 200 {object} response.Response
// @Router /push/subscribe [post]
func (h *PushHandler) SubscribePush(c *gin.Context) {
	var req struct {
		DeviceToken string `json:"device_token" binding:"required"`
		Platform    string `json:"platform" binding:"required,oneof=ios android"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	userID, _ := c.Get("user_id")
	// TODO: 调用 pushSvc.SubscribePush
	_ = userID

	response.SuccessWithMessage(c, "订阅成功", nil)
}

// RegisterPushRoutes 注册推送路由
func RegisterPushRoutes(r *gin.Engine) {
	h := NewPushHandler()
	push := r.Group("/push")
	{
		push.POST("/send", h.SendPush)
		push.POST("/subscribe", h.SubscribePush)
	}
}
