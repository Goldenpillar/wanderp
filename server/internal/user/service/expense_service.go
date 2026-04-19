package service

import (
	"context"

	"github.com/wanderp/server/internal/user/model"
)

// ExpenseService 消费服务接口
type ExpenseService interface {
	// CreateExpense 创建消费记录
	CreateExpense(ctx context.Context, expense *model.Expense) (*model.Expense, error)
	// GetExpense 获取消费记录
	GetExpense(ctx context.Context, id uint) (*model.Expense, error)
	// UpdateExpense 更新消费记录
	UpdateExpense(ctx context.Context, id uint, expense *model.Expense) (*model.Expense, error)
	// DeleteExpense 删除消费记录
	DeleteExpense(ctx context.Context, id uint) error
	// ListByTripID 获取行程消费列表
	ListByTripID(ctx context.Context, tripID uint, page, size int) ([]model.Expense, int64, error)
	// GetSummary 获取消费汇总
	GetSummary(ctx context.Context, tripID uint) (*model.ExpenseSummary, error)
}

// expenseService 消费服务实现
type expenseService struct {
	expenseRepo repository.ExpenseRepository
}

// NewExpenseService 创建消费服务实例
func NewExpenseService(expenseRepo repository.ExpenseRepository) ExpenseService {
	return &expenseService{expenseRepo: expenseRepo}
}

// CreateExpense 创建消费记录
func (s *expenseService) CreateExpense(ctx context.Context, expense *model.Expense) (*model.Expense, error) {
	// TODO: 实现创建消费记录逻辑
	err := s.expenseRepo.Create(ctx, expense)
	if err != nil {
		return nil, err
	}
	return expense, nil
}

// GetExpense 获取消费记录
func (s *expenseService) GetExpense(ctx context.Context, id uint) (*model.Expense, error) {
	// TODO: 实现获取消费记录逻辑
	return s.expenseRepo.GetByID(ctx, id)
}

// UpdateExpense 更新消费记录
func (s *expenseService) UpdateExpense(ctx context.Context, id uint, expense *model.Expense) (*model.Expense, error) {
	// TODO: 实现更新消费记录逻辑
	expense.ID = id
	err := s.expenseRepo.Update(ctx, expense)
	if err != nil {
		return nil, err
	}
	return expense, nil
}

// DeleteExpense 删除消费记录
func (s *expenseService) DeleteExpense(ctx context.Context, id uint) error {
	// TODO: 实现删除消费记录逻辑
	return s.expenseRepo.Delete(ctx, id)
}

// ListByTripID 获取行程消费列表
func (s *expenseService) ListByTripID(ctx context.Context, tripID uint, page, size int) ([]model.Expense, int64, error) {
	// TODO: 实现获取消费列表逻辑
	return s.expenseRepo.ListByTripID(ctx, tripID, page, size)
}

// GetSummary 获取消费汇总
func (s *expenseService) GetSummary(ctx context.Context, tripID uint) (*model.ExpenseSummary, error) {
	// TODO: 实现获取消费汇总逻辑
	return s.expenseRepo.GetSummaryByTripID(ctx, tripID)
}
