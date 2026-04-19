package service

import (
	"context"

	"github.com/wanderp/server/internal/user/model"
)

// UserService 用户服务接口
type UserService interface {
	// GetProfile 获取用户资料
	GetProfile(ctx context.Context, userID uint) (*model.UserProfile, error)
	// UpdateProfile 更新用户资料
	UpdateProfile(ctx context.Context, userID uint, profile *model.UserProfile) error
	// GetByID 根据ID获取用户
	GetByID(ctx context.Context, userID uint) (*model.User, error)
	// SearchUsers 搜索用户
	SearchUsers(ctx context.Context, keyword string, page, size int) ([]model.UserProfile, int64, error)
	// UploadAvatar 上传头像
	UploadAvatar(ctx context.Context, userID uint, avatarURL string) error
}

// userService 用户服务实现
type userService struct {
	userRepo repository.UserRepository
}

// NewUserService 创建用户服务实例
func NewUserService(userRepo repository.UserRepository) UserService {
	return &userService{userRepo: userRepo}
}

// GetProfile 获取用户资料
func (s *userService) GetProfile(ctx context.Context, userID uint) (*model.UserProfile, error) {
	// TODO: 实现获取用户资料逻辑
	user, err := s.userRepo.GetByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	return &model.UserProfile{
		ID:       user.ID,
		Username: user.Username,
		Nickname: user.Nickname,
		Avatar:   user.Avatar,
		Bio:      user.Bio,
		Gender:   user.Gender,
		Location: user.Location,
	}, nil
}

// UpdateProfile 更新用户资料
func (s *userService) UpdateProfile(ctx context.Context, userID uint, profile *model.UserProfile) error {
	// TODO: 实现更新用户资料逻辑
	return nil
}

// GetByID 根据ID获取用户
func (s *userService) GetByID(ctx context.Context, userID uint) (*model.User, error) {
	// TODO: 实现获取用户逻辑
	return s.userRepo.GetByID(ctx, userID)
}

// SearchUsers 搜索用户
func (s *userService) SearchUsers(ctx context.Context, keyword string, page, size int) ([]model.UserProfile, int64, error) {
	// TODO: 实现用户搜索逻辑
	return nil, 0, nil
}

// UploadAvatar 上传头像
func (s *userService) UploadAvatar(ctx context.Context, userID uint, avatarURL string) error {
	// TODO: 实现头像上传逻辑
	return nil
}
