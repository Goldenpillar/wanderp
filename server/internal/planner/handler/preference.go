package handler

import (
	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/response"
	"github.com/wanderp/server/internal/planner/model"
)

// PreferenceHandler 偏好处理器
type PreferenceHandler struct {
	// TODO: 注入偏好服务
}

// NewPreferenceHandler 创建偏好处理器
func NewPreferenceHandler() *PreferenceHandler {
	return &PreferenceHandler{}
}

// GetPreference 获取用户偏好
// @Summary 获取用户偏好
// @Description 获取当前用户的旅行偏好设置
// @Tags 偏好
// @Produce json
// @Success 200 {object} response.Response
// @Router /preferences [get]
func (h *PreferenceHandler) GetPreference(c *gin.Context) {
	userID, _ := c.Get("user_id")
	// TODO: 调用服务层获取偏好
	_ = userID

	response.Success(c, &model.Preference{})
}

// UpdatePreference 更新用户偏好
// @Summary 更新用户偏好
// @Description 更新当前用户的旅行偏好设置
// @Tags 偏好
// @Accept json
// @Produce json
// @Param preference body model.Preference true "偏好信息"
// @Success 200 {object} response.Response
// @Router /preferences [put]
func (h *PreferenceHandler) UpdatePreference(c *gin.Context) {
	var pref model.Preference
	if err := c.ShouldBindJSON(&pref); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	userID, _ := c.Get("user_id")
	// TODO: 调用服务层更新偏好
	pref.UserID = userID.(uint)
	_ = userID

	response.Success(c, pref)
}

// RegisterPreferenceRoutes 注册偏好相关路由
func RegisterPreferenceRoutes(r *gin.Engine) {
	h := NewPreferenceHandler()
	pref := r.Group("/preferences")
	{
		pref.GET("", h.GetPreference)
		pref.PUT("", h.UpdatePreference)
	}
}
