package repository

import (
	"context"

	"github.com/wanderp/server/internal/user/model"
	"gorm.io/gorm"
)

// ExpenseRepository 消费数据访问接口
type ExpenseRepository interface {
	Create(ctx context.Context, expense *model.Expense) error
	GetByID(ctx context.Context, id uint) (*model.Expense, error)
	Update(ctx context.Context, expense *model.Expense) error
	Delete(ctx context.Context, id uint) error
	ListByTripID(ctx context.Context, tripID uint, page, size int) ([]model.Expense, int64, error)
	ListByUserID(ctx context.Context, userID uint, page, size int) ([]model.Expense, int64, error)
	GetSummaryByTripID(ctx context.Context, tripID uint) (*model.ExpenseSummary, error)
}

// expenseRepository 消费数据访问实现
type expenseRepository struct {
	db *gorm.DB
}

// NewExpenseRepository 创建消费数据访问实例
func NewExpenseRepository(db *gorm.DB) ExpenseRepository {
	return &expenseRepository{db: db}
}

// Create 创建消费记录
func (r *expenseRepository) Create(ctx context.Context, expense *model.Expense) error {
	return r.db.WithContext(ctx).Create(expense).Error
}

// GetByID 根据ID获取消费记录
func (r *expenseRepository) GetByID(ctx context.Context, id uint) (*model.Expense, error) {
	var expense model.Expense
	err := r.db.WithContext(ctx).First(&expense, id).Error
	if err != nil {
		return nil, err
	}
	return &expense, nil
}

// Update 更新消费记录
func (r *expenseRepository) Update(ctx context.Context, expense *model.Expense) error {
	return r.db.WithContext(ctx).Save(expense).Error
}

// Delete 删除消费记录
func (r *expenseRepository) Delete(ctx context.Context, id uint) error {
	return r.db.WithContext(ctx).Delete(&model.Expense{}, id).Error
}

// ListByTripID 根据行程ID列出消费记录
func (r *expenseRepository) ListByTripID(ctx context.Context, tripID uint, page, size int) ([]model.Expense, int64, error) {
	var expenses []model.Expense
	var total int64

	db := r.db.WithContext(ctx).Model(&model.Expense{}).Where("trip_id = ?", tripID)
	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * size
	if err := db.Order("expense_time DESC").Offset(offset).Limit(size).Find(&expenses).Error; err != nil {
		return nil, 0, err
	}

	return expenses, total, nil
}

// ListByUserID 根据用户ID列出消费记录
func (r *expenseRepository) ListByUserID(ctx context.Context, userID uint, page, size int) ([]model.Expense, int64, error) {
	var expenses []model.Expense
	var total int64

	db := r.db.WithContext(ctx).Model(&model.Expense{}).Where("user_id = ?", userID)
	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * size
	if err := db.Order("expense_time DESC").Offset(offset).Limit(size).Find(&expenses).Error; err != nil {
		return nil, 0, err
	}

	return expenses, total, nil
}

// GetSummaryByTripID 获取行程消费汇总
func (r *expenseRepository) GetSummaryByTripID(ctx context.Context, tripID uint) (*model.ExpenseSummary, error) {
	// TODO: 实现消费汇总查询（按分类、按成员分组统计）
	var summary model.ExpenseSummary
	summary.TripID = tripID

	// 查询总金额
	var totalAmount float64
	r.db.WithContext(ctx).Model(&model.Expense{}).
		Where("trip_id = ?", tripID).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&totalAmount)
	summary.TotalAmount = totalAmount

	return &summary, nil
}
