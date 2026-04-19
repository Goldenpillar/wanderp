package handler

import (
	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/response"
	"github.com/wanderp/server/internal/map/model"
)

// RouteHandler 路线规划处理器
type RouteHandler struct {
	// routeSvc service.RouteService
}

// NewRouteHandler 创建路线规划处理器
func NewRouteHandler() *RouteHandler {
	return &RouteHandler{}
}

// PlanRoute 规划路线
// @Summary 规划路线
// @Description 根据起点和终点规划路线
// @Tags 路线规划
// @Accept json
// @Produce json
// @Param request body model.RouteRequest true "路线规划请求"
// @Success 200 {object} response.Response
// @Router /route/plan [post]
func (h *RouteHandler) PlanRoute(c *gin.Context) {
	var req model.RouteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "参数格式错误: "+err.Error())
		return
	}

	// TODO: 调用 routeSvc.PlanRoute
	response.Success(c, gin.H{
		"origin":      req.Origin,
		"destination": req.Destination,
		"mode":        req.Mode,
	})
}

// GetMultipleRoutes 获取备选路线
// @Summary 获取备选路线
// @Description 获取多条备选路线方案
// @Tags 路线规划
// @Accept json
// @Produce json
// @Param request body model.RouteRequest true "路线规划请求"
// @Success 200 {object} response.Response
// @Router /route/multiple [post]
func (h *RouteHandler) GetMultipleRoutes(c *gin.Context) {
	var req model.RouteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	// TODO: 调用 routeSvc.GetMultipleRoutes
	response.Success(c, []interface{}{})
}

// GetTransitRoute 获取公交路线
// @Summary 获取公交路线
// @Description 获取公共交通路线方案
// @Tags 路线规划
// @Accept json
// @Produce json
// @Param request body object true "公交路线请求"
// @Success 200 {object} response.Response
// @Router /route/transit [post]
func (h *RouteHandler) GetTransitRoute(c *gin.Context) {
	// TODO: 调用 routeSvc.GetTransitRoute
	response.Success(c, []interface{}{})
}

// RegisterRouteRoutes 注册路线规划路由
func RegisterRouteRoutes(r *gin.Engine) {
	h := NewRouteHandler()
	route := r.Group("/route")
	{
		route.POST("/plan", h.PlanRoute)
		route.POST("/multiple", h.GetMultipleRoutes)
		route.POST("/transit", h.GetTransitRoute)
	}
}
