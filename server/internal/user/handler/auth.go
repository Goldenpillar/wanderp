package handler

import (
	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/response"
	"github.com/wanderp/server/internal/user/model"
)

// AuthHandler 认证处理器
type AuthHandler struct {
	// authSvc service.AuthService
}

// NewAuthHandler 创建认证处理器
func NewAuthHandler() *AuthHandler {
	return &AuthHandler{}
}

// Register 用户注册
// @Summary 用户注册
// @Description 注册新用户
// @Tags 认证
// @Accept json
// @Produce json
// @Param request body model.RegisterRequest true "注册信息"
// @Success 200 {object} response.Response
// @Router /auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
	var req model.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "参数格式错误: "+err.Error())
		return
	}

	// TODO: 调用 authSvc.Register
	response.SuccessWithMessage(c, "注册成功", gin.H{
		"username": req.Username,
		"email":    req.Email,
	})
}

// Login 用户登录
// @Summary 用户登录
// @Description 用户登录获取令牌
// @Tags 认证
// @Accept json
// @Produce json
// @Param request body model.LoginRequest true "登录信息"
// @Success 200 {object} response.Response
// @Router /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req model.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	// TODO: 调用 authSvc.Login
	response.Success(c, &model.LoginResponse{
		Token: "jwt_token_placeholder",
	})
}

// RefreshToken 刷新令牌
// @Summary 刷新令牌
// @Description 使用当前令牌刷新获取新令牌
// @Tags 认证
// @Produce json
// @Success 200 {object} response.Response
// @Router /auth/refresh [post]
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	// TODO: 调用 authSvc.RefreshToken
	response.Success(c, gin.H{
		"token": "new_jwt_token_placeholder",
	})
}

// ChangePassword 修改密码
// @Summary 修改密码
// @Description 修改用户密码
// @Tags 认证
// @Accept json
// @Produce json
// @Param request body map[string]string true "密码信息 {old_password, new_password}"
// @Success 200 {object} response.Response
// @Router /auth/password [put]
func (h *AuthHandler) ChangePassword(c *gin.Context) {
	var req struct {
		OldPassword string `json:"old_password" binding:"required"`
		NewPassword string `json:"new_password" binding:"required,min=8"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	userID, _ := c.Get("user_id")
	// TODO: 调用 authSvc.ChangePassword
	_ = userID

	response.SuccessWithMessage(c, "密码修改成功", nil)
}

// RegisterAuthRoutes 注册认证路由
func RegisterAuthRoutes(r *gin.Engine) {
	h := NewAuthHandler()
	auth := r.Group("/auth")
	{
		auth.POST("/register", h.Register)
		auth.POST("/login", h.Login)
		auth.POST("/refresh", h.RefreshToken)
		auth.PUT("/password", h.ChangePassword)
	}
}
