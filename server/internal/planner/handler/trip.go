package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/response"
	"github.com/wanderp/server/internal/planner/model"
)

// TripHandler 行程处理器
type TripHandler struct {
	// tripSvc service.TripService
}

// NewTripHandler 创建行程处理器
func NewTripHandler() *TripHandler {
	return &TripHandler{}
}

// CreateTrip 创建行程
// @Summary 创建行程
// @Description 创建一个新的旅行行程
// @Tags 行程
// @Accept json
// @Produce json
// @Param trip body model.Trip true "行程信息"
// @Success 200 {object} response.Response
// @Router /trips [post]
func (h *TripHandler) CreateTrip(c *gin.Context) {
	// TODO: 解析请求参数并调用服务层创建行程
	var trip model.Trip
	if err := c.ShouldBindJSON(&trip); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	userID, _ := c.Get("user_id")
	// TODO: 调用 tripSvc.CreateTrip(ctx, userID.(uint), &trip)
	_ = userID

	response.Success(c, trip)
}

// GetTrip 获取行程详情
// @Summary 获取行程详情
// @Description 根据ID获取行程详细信息
// @Tags 行程
// @Produce json
// @Param id path int true "行程ID"
// @Success 200 {object} response.Response
// @Router /trips/{id} [get]
func (h *TripHandler) GetTrip(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	// TODO: 调用 tripSvc.GetTrip(ctx, uint(id))
	_ = id

	response.Success(c, gin.H{"id": id})
}

// UpdateTrip 更新行程
// @Summary 更新行程
// @Description 更新行程信息
// @Tags 行程
// @Accept json
// @Produce json
// @Param id path int true "行程ID"
// @Param trip body model.Trip true "行程信息"
// @Success 200 {object} response.Response
// @Router /trips/{id} [put]
func (h *TripHandler) UpdateTrip(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	var trip model.Trip
	if err := c.ShouldBindJSON(&trip); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	// TODO: 调用 tripSvc.UpdateTrip(ctx, uint(id), &trip)
	_ = id

	response.Success(c, trip)
}

// DeleteTrip 删除行程
// @Summary 删除行程
// @Description 删除指定行程
// @Tags 行程
// @Produce json
// @Param id path int true "行程ID"
// @Success 200 {object} response.Response
// @Router /trips/{id} [delete]
func (h *TripHandler) DeleteTrip(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	// TODO: 调用 tripSvc.DeleteTrip(ctx, uint(id))
	_ = id

	response.SuccessWithMessage(c, "删除成功", nil)
}

// ListTrips 列出行程
// @Summary 列出行程
// @Description 获取当前用户的所有行程
// @Tags 行程
// @Produce json
// @Param page query int false "页码" default(1)
// @Param size query int false "每页数量" default(20)
// @Success 200 {object} response.Response
// @Router /trips [get]
func (h *TripHandler) ListTrips(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	size, _ := strconv.Atoi(c.DefaultQuery("size", "20"))

	userID, _ := c.Get("user_id")
	// TODO: 调用 tripSvc.ListTrips(ctx, userID.(uint), page, size)
	_ = userID

	response.SuccessPage(c, 0, page, size, []model.Trip{})
}

// AddMember 添加行程成员
// @Summary 添加行程成员
// @Description 邀请用户加入行程
// @Tags 行程
// @Accept json
// @Produce json
// @Param id path int true "行程ID"
// @Param member body map[string]interface{} true "成员信息"
// @Success 200 {object} response.Response
// @Router /trips/{id}/members [post]
func (h *TripHandler) AddMember(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	// TODO: 解析成员信息并调用服务层
	_ = id

	response.SuccessWithMessage(c, "添加成员成功", nil)
}

// ListMembers 列出行程成员
// @Summary 列出行程成员
// @Description 获取行程的所有成员
// @Tags 行程
// @Produce json
// @Param id path int true "行程ID"
// @Success 200 {object} response.Response
// @Router /trips/{id}/members [get]
func (h *TripHandler) ListMembers(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	// TODO: 调用服务层获取成员列表
	_ = id

	response.Success(c, []interface{}{})
}

// RemoveMember 移除行程成员
// @Summary 移除行程成员
// @Description 从行程中移除指定成员
// @Tags 行程
// @Produce json
// @Param id path int true "行程ID"
// @Param userId path int true "用户ID"
// @Success 200 {object} response.Response
// @Router /trips/{id}/members/{userId} [delete]
func (h *TripHandler) RemoveMember(c *gin.Context) {
	idStr := c.Param("id")
	_, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	userIDStr := c.Param("userId")
	_, err = strconv.ParseUint(userIDStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "用户ID格式错误")
		return
	}

	// TODO: 调用服务层移除成员
	response.SuccessWithMessage(c, "移除成员成功", nil)
}

// RegisterTripRoutes 注册行程相关路由
func RegisterTripRoutes(r *gin.Engine) {
	h := NewTripHandler()
	trips := r.Group("/trips")
	{
		trips.GET("", h.ListTrips)
		trips.POST("", h.CreateTrip)
		trips.GET("/:id", h.GetTrip)
		trips.PUT("/:id", h.UpdateTrip)
		trips.DELETE("/:id", h.DeleteTrip)
		trips.GET("/:id/members", h.ListMembers)
		trips.POST("/:id/members", h.AddMember)
		trips.DELETE("/:id/members/:userId", h.RemoveMember)
	}
}
