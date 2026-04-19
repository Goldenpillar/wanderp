package service

import (
	"context"

	"github.com/wanderp/server/internal/user/model"
)

// AuthService 认证服务接口
type AuthService interface {
	// Register 用户注册
	Register(ctx context.Context, req *model.RegisterRequest) (*model.User, error)
	// Login 用户登录
	Login(ctx context.Context, req *model.LoginRequest) (*model.LoginResponse, error)
	// RefreshToken 刷新令牌
	RefreshToken(ctx context.Context, token string) (*model.LoginResponse, error)
	// ChangePassword 修改密码
	ChangePassword(ctx context.Context, userID uint, oldPassword, newPassword string) error
	// Logout 用户登出
	Logout(ctx context.Context, token string) error
}

// authService 认证服务实现
type authService struct {
	userRepo repository.UserRepository
	jwtSecret string
	jwtExpire int64
}

// NewAuthService 创建认证服务实例
func NewAuthService(userRepo repository.UserRepository, jwtSecret string, jwtExpire int64) AuthService {
	return &authService{
		userRepo:  userRepo,
		jwtSecret: jwtSecret,
		jwtExpire: jwtExpire,
	}
}

// Register 用户注册
func (s *authService) Register(ctx context.Context, req *model.RegisterRequest) (*model.User, error) {
	// TODO: 实现注册逻辑
	// 1. 检查用户名/邮箱/手机号是否已存在
	// 2. 密码加密（bcrypt）
	// 3. 创建用户记录
	return nil, nil
}

// Login 用户登录
func (s *authService) Login(ctx context.Context, req *model.LoginRequest) (*model.LoginResponse, error) {
	// TODO: 实现登录逻辑
	// 1. 查询用户
	// 2. 验证密码
	// 3. 生成JWT令牌
	// 4. 更新最后登录时间
	return nil, nil
}

// RefreshToken 刷新令牌
func (s *authService) RefreshToken(ctx context.Context, token string) (*model.LoginResponse, error) {
	// TODO: 实现令牌刷新逻辑
	return nil, nil
}

// ChangePassword 修改密码
func (s *authService) ChangePassword(ctx context.Context, userID uint, oldPassword, newPassword string) error {
	// TODO: 实现密码修改逻辑
	return nil
}

// Logout 用户登出
func (s *authService) Logout(ctx context.Context, token string) error {
	// TODO: 将令牌加入黑名单（Redis）
	return nil
}
