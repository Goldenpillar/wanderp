package handler

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/response"
	"github.com/wanderp/server/internal/user/model"
)

// UserHandler 用户处理器
type UserHandler struct {
	// userSvc service.UserService
}

// NewUserHandler 创建用户处理器
func NewUserHandler() *UserHandler {
	return &UserHandler{}
}

// GetProfile 获取用户资料
// @Summary 获取用户资料
// @Description 获取当前登录用户的资料
// @Tags 用户
// @Produce json
// @Success 200 {object} response.Response
// @Router /user/profile [get]
func (h *UserHandler) GetProfile(c *gin.Context) {
	userID, _ := c.Get("user_id")
	// TODO: 调用 userSvc.GetProfile
	_ = userID

	response.Success(c, &model.UserProfile{})
}

// UpdateProfile 更新用户资料
// @Summary 更新用户资料
// @Description 更新当前登录用户的资料
// @Tags 用户
// @Accept json
// @Produce json
// @Param profile body model.UserProfile true "用户资料"
// @Success 200 {object} response.Response
// @Router /user/profile [put]
func (h *UserHandler) UpdateProfile(c *gin.Context) {
	var profile model.UserProfile
	if err := c.ShouldBindJSON(&profile); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	userID, _ := c.Get("user_id")
	// TODO: 调用 userSvc.UpdateProfile
	_ = userID

	response.Success(c, profile)
}

// GetUser 获取指定用户信息
// @Summary 获取用户信息
// @Description 根据ID获取用户公开信息
// @Tags 用户
// @Produce json
// @Param id path int true "用户ID"
// @Success 200 {object} response.Response
// @Router /user/{id} [get]
func (h *UserHandler) GetUser(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "用户ID格式错误")
		return
	}

	// TODO: 调用 userSvc.GetByID
	_ = id

	response.Success(c, &model.UserProfile{})
}

// SearchUsers 搜索用户
// @Summary 搜索用户
// @Description 根据关键词搜索用户
// @Tags 用户
// @Produce json
// @Param keyword query string true "搜索关键词"
// @Param page query int false "页码" default(1)
// @Param size query int false "每页数量" default(20)
// @Success 200 {object} response.Response
// @Router /user/search [get]
func (h *UserHandler) SearchUsers(c *gin.Context) {
	keyword := c.Query("keyword")
	if keyword == "" {
		response.BadRequest(c, "搜索关键词不能为空")
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	size, _ := strconv.Atoi(c.DefaultQuery("size", "20"))

	// TODO: 调用 userSvc.SearchUsers
	_ = page
	_ = size

	response.Success(c, []model.UserProfile{})
}

// RegisterUserRoutes 注册用户路由
func RegisterUserRoutes(r *gin.Engine) {
	h := NewUserHandler()
	user := r.Group("/user")
	{
		user.GET("/profile", h.GetProfile)
		user.PUT("/profile", h.UpdateProfile)
		user.GET("/search", h.SearchUsers)
		user.GET("/:id", h.GetUser)
	}
}
