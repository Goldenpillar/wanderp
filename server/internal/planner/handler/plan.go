package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/response"
	"github.com/wanderp/server/internal/planner/model"
)

// PlanHandler AI规划处理器
type PlanHandler struct {
	// planSvc service.PlanService
}

// NewPlanHandler 创建AI规划处理器
func NewPlanHandler() *PlanHandler {
	return &PlanHandler{}
}

// GeneratePlanRequest 生成规划请求
type GeneratePlanRequest struct {
	Destination string              `json:"destination" binding:"required" example:"东京"`
	Days       int                 `json:"days" binding:"required,min=1,max=30" example:"5"`
	Preferences *model.Preference  `json:"preferences"`
}

// GeneratePlan 生成行程规划
// @Summary AI生成行程规划
// @Description 根据目的地和偏好自动生成行程规划
// @Tags AI规划
// @Accept json
// @Produce json
// @Param request body GeneratePlanRequest true "规划请求"
// @Success 200 {object} response.Response
// @Router /plan/generate [post]
func (h *PlanHandler) GeneratePlan(c *gin.Context) {
	var req GeneratePlanRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "参数格式错误: "+err.Error())
		return
	}

	// TODO: 调用 planSvc.GeneratePlan 生成规划
	response.SuccessWithMessage(c, "行程规划生成中，请稍候", gin.H{
		"destination": req.Destination,
		"days":        req.Days,
	})
}

// OptimizePlan 优化行程规划
// @Summary 优化行程规划
// @Description 根据用户反馈优化现有行程
// @Tags AI规划
// @Accept json
// @Produce json
// @Param id path int true "行程ID"
// @Param feedback body map[string]interface{} true "优化反馈"
// @Success 200 {object} response.Response
// @Router /plan/{id}/optimize [post]
func (h *PlanHandler) OptimizePlan(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	// TODO: 调用 planSvc.OptimizePlan 优化规划
	_ = id

	response.SuccessWithMessage(c, "行程优化中，请稍候", nil)
}

// AddActivity 添加活动
// @Summary 添加活动
// @Description 手动添加活动到行程
// @Tags AI规划
// @Accept json
// @Produce json
// @Param id path int true "行程ID"
// @Param activity body model.Activity true "活动信息"
// @Success 200 {object} response.Response
// @Router /plan/{id}/activities [post]
func (h *PlanHandler) AddActivity(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	var activity model.Activity
	if err := c.ShouldBindJSON(&activity); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	// TODO: 调用 planSvc.AddActivity
	_ = id

	response.Success(c, activity)
}

// RemoveActivity 移除活动
// @Summary 移除活动
// @Description 从行程中移除指定活动
// @Tags AI规划
// @Produce json
// @Param id path int true "行程ID"
// @Param activityId path int true "活动ID"
// @Success 200 {object} response.Response
// @Router /plan/{id}/activities/{activityId} [delete]
func (h *PlanHandler) RemoveActivity(c *gin.Context) {
	idStr := c.Param("id")
	_, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	activityIDStr := c.Param("activityId")
	_, err = strconv.ParseUint(activityIDStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "活动ID格式错误")
		return
	}

	// TODO: 调用 planSvc.RemoveActivity
	response.SuccessWithMessage(c, "活动已移除", nil)
}

// VoteActivity 对活动投票
// @Summary 活动投票
// @Description 对行程中的活动进行投票（赞成/反对）
// @Tags AI规划
// @Accept json
// @Produce json
// @Param activityId path int true "活动ID"
// @Param vote body map[string]string true "投票信息 {type: up/down}"
// @Success 200 {object} response.Response
// @Router /plan/activities/{activityId}/vote [post]
func (h *PlanHandler) VoteActivity(c *gin.Context) {
	activityIDStr := c.Param("activityId")
	activityID, err := strconv.ParseUint(activityIDStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "活动ID格式错误")
		return
	}

	var req struct {
		Type string `json:"type" binding:"required,oneof=up down"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "投票类型必须为up或down")
		return
	}

	userID, _ := c.Get("user_id")
	// TODO: 调用 planSvc.VoteActivity(ctx, uint(activityID), userID.(uint), req.Type)
	_ = activityID
	_ = userID

	response.SuccessWithMessage(c, "投票成功", nil)
}

// GetRecommendations 获取推荐
// @Summary 获取推荐活动
// @Description 根据目的地和分类获取推荐活动
// @Tags AI规划
// @Produce json
// @Param destination query string true "目的地"
// @Param category query string false "分类"
// @Success 200 {object} response.Response
// @Router /plan/recommendations [get]
func (h *PlanHandler) GetRecommendations(c *gin.Context) {
	destination := c.Query("destination")
	category := c.Query("category")

	if destination == "" {
		response.BadRequest(c, "目的地不能为空")
		return
	}

	// TODO: 调用 planSvc.GetRecommendations
	_ = category

	response.Success(c, []interface{}{})
}

// RegisterPlanRoutes 注册AI规划相关路由
func RegisterPlanRoutes(r *gin.Engine) {
	h := NewPlanHandler()
	plan := r.Group("/plan")
	{
		plan.POST("/generate", h.GeneratePlan)
		plan.GET("/recommendations", h.GetRecommendations)
		plan.POST("/:id/optimize", h.OptimizePlan)
		plan.POST("/:id/activities", h.AddActivity)
		plan.DELETE("/:id/activities/:activityId", h.RemoveActivity)
		plan.POST("/activities/:activityId/vote", h.VoteActivity)
	}
}
