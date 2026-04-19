package handler

import (
	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/response"
	"github.com/wanderp/server/internal/map/model"
)

// POIHandler POI搜索处理器
type POIHandler struct {
	// amapSvc service.AMapService
}

// NewPOIHandler 创建POI搜索处理器
func NewPOIHandler() *POIHandler {
	return &POIHandler{}
}

// SearchPOI 搜索POI
// @Summary 搜索兴趣点
// @Description 根据关键词搜索附近的兴趣点
// @Tags POI搜索
// @Produce json
// @Param keyword query string true "搜索关键词"
// @Param city query string false "城市"
// @Param category query string false "分类"
// @Param latitude query number false "纬度"
// @Param longitude query number false "经度"
// @Param radius query int false "搜索半径(米)" default(3000)
// @Param page query int false "页码" default(1)
// @Param page_size query int false "每页数量" default(20)
// @Success 200 {object} response.Response
// @Router /poi/search [get]
func (h *POIHandler) SearchPOI(c *gin.Context) {
	var req model.POISearchRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	// TODO: 调用 amapSvc.SearchPOI
	response.Success(c, []model.POI{})
}

// GetPOIDetail 获取POI详情
// @Summary 获取POI详情
// @Description 根据ID获取兴趣点详细信息
// @Tags POI搜索
// @Produce json
// @Param id path string true "POI ID"
// @Success 200 {object} response.Response
// @Router /poi/{id} [get]
func (h *POIHandler) GetPOIDetail(c *gin.Context) {
	poiID := c.Param("id")
	if poiID == "" {
		response.BadRequest(c, "POI ID不能为空")
		return
	}

	// TODO: 调用 amapSvc.GetPOIDetail
	_ = poiID

	response.Success(c, &model.POI{})
}

// SearchNearby 搜索附近
// @Summary 搜索附近POI
// @Description 搜索指定位置附近的兴趣点
// @Tags POI搜索
// @Produce json
// @Param latitude query number true "纬度"
// @Param longitude query number true "经度"
// @Param radius query int false "搜索半径(米)" default(3000)
// @Param types query string false "POI类型"
// @Success 200 {object} response.Response
// @Router /poi/nearby [get]
func (h *POIHandler) SearchNearby(c *gin.Context) {
	// TODO: 调用高德地图周边搜索API
	response.Success(c, []model.POI{})
}

// SearchFood 搜索美食
// @Summary 搜索美食
// @Description 搜索目的地附近的美食推荐
// @Tags POI搜索
// @Produce json
// @Param keyword query string false "关键词"
// @Param city query string true "城市"
// @Param latitude query number false "纬度"
// @Param longitude query number false "经度"
// @Success 200 {object} response.Response
// @Router /poi/food [get]
func (h *POIHandler) SearchFood(c *gin.Context) {
	// TODO: 调用高德地图美食搜索API
	response.Success(c, []model.POI{})
}

// RegisterPOIRoutes 注册POI搜索路由
func RegisterPOIRoutes(r *gin.Engine) {
	h := NewPOIHandler()
	poi := r.Group("/poi")
	{
		poi.GET("/search", h.SearchPOI)
		poi.GET("/nearby", h.SearchNearby)
		poi.GET("/food", h.SearchFood)
		poi.GET("/:id", h.GetPOIDetail)
	}
}
