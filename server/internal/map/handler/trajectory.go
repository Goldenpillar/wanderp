package handler

import (
	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/response"
	"github.com/wanderp/server/internal/map/model"
)

// TrajectoryHandler 轨迹处理器
type TrajectoryHandler struct {
	// trajectorySvc service.TrajectoryService
}

// NewTrajectoryHandler 创建轨迹处理器
func NewTrajectoryHandler() *TrajectoryHandler {
	return &TrajectoryHandler{}
}

// UploadTrajectory 上传轨迹
// @Summary 上传轨迹
// @Description 上传行程轨迹数据
// @Tags 轨迹
// @Accept json
// @Produce json
// @Param trajectory body model.Trajectory true "轨迹数据"
// @Success 200 {object} response.Response
// @Router /trajectory/upload [post]
func (h *TrajectoryHandler) UploadTrajectory(c *gin.Context) {
	var trajectory model.Trajectory
	if err := c.ShouldBindJSON(&trajectory); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	// TODO: 调用 trajectorySvc.UploadTrajectory
	response.SuccessWithMessage(c, "轨迹上传成功", nil)
}

// GetTrajectory 获取轨迹
// @Summary 获取轨迹
// @Description 获取行程轨迹数据
// @Tags 轨迹
// @Produce json
// @Param tripId query int true "行程ID"
// @Param userId query int false "用户ID"
// @Success 200 {object} response.Response
// @Router /trajectory [get]
func (h *TrajectoryHandler) GetTrajectory(c *gin.Context) {
	// TODO: 调用 trajectorySvc.GetTrajectory
	response.Success(c, &model.Trajectory{})
}

// ShareLocation 分享位置
// @Summary 分享位置
// @Description 分享当前位置给同行成员
// @Tags 轨迹
// @Accept json
// @Produce json
// @Param location body model.TrajectoryPoint true "位置信息"
// @Success 200 {object} response.Response
// @Router /trajectory/share [post]
func (h *TrajectoryHandler) ShareLocation(c *gin.Context) {
	var point model.TrajectoryPoint
	if err := c.ShouldBindJSON(&point); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	userID, _ := c.Get("user_id")
	// TODO: 调用 trajectorySvc.ShareLocation
	_ = userID

	response.SuccessWithMessage(c, "位置已分享", nil)
}

// RegisterTrajectoryRoutes 注册轨迹路由
func RegisterTrajectoryRoutes(r *gin.Engine) {
	h := NewTrajectoryHandler()
	trajectory := r.Group("/trajectory")
	{
		trajectory.POST("/upload", h.UploadTrajectory)
		trajectory.GET("", h.GetTrajectory)
		trajectory.POST("/share", h.ShareLocation)
	}
}
