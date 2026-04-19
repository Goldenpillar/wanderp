package handler

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/wanderp/server/internal/pkg/response"
	"github.com/wanderp/server/internal/user/model"
)

// ExpenseHandler 消费处理器
type ExpenseHandler struct {
	// expenseSvc service.ExpenseService
}

// NewExpenseHandler 创建消费处理器
func NewExpenseHandler() *ExpenseHandler {
	return &ExpenseHandler{}
}

// CreateExpense 创建消费记录
// @Summary 创建消费记录
// @Description 记录一笔消费
// @Tags 消费
// @Accept json
// @Produce json
// @Param expense body model.ExpenseCreateRequest true "消费信息"
// @Success 200 {object} response.Response
// @Router /expenses [post]
func (h *ExpenseHandler) CreateExpense(c *gin.Context) {
	var req model.ExpenseCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.BadRequest(c, "参数格式错误: "+err.Error())
		return
	}

	userID, _ := c.Get("user_id")
	// TODO: 调用 expenseSvc.CreateExpense
	_ = userID

	response.Success(c, gin.H{
		"trip_id":  req.TripID,
		"category": req.Category,
		"amount":   req.Amount,
	})
}

// GetExpense 获取消费记录
// @Summary 获取消费记录
// @Description 根据ID获取消费记录详情
// @Tags 消费
// @Produce json
// @Param id path int true "消费记录ID"
// @Success 200 {object} response.Response
// @Router /expenses/{id} [get]
func (h *ExpenseHandler) GetExpense(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "消费记录ID格式错误")
		return
	}

	// TODO: 调用 expenseSvc.GetExpense
	_ = id

	response.Success(c, &model.Expense{})
}

// UpdateExpense 更新消费记录
// @Summary 更新消费记录
// @Description 更新消费记录信息
// @Tags 消费
// @Accept json
// @Produce json
// @Param id path int true "消费记录ID"
// @Param expense body model.Expense true "消费信息"
// @Success 200 {object} response.Response
// @Router /expenses/{id} [put]
func (h *ExpenseHandler) UpdateExpense(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "消费记录ID格式错误")
		return
	}

	var expense model.Expense
	if err := c.ShouldBindJSON(&expense); err != nil {
		response.BadRequest(c, "参数格式错误")
		return
	}

	// TODO: 调用 expenseSvc.UpdateExpense
	_ = id

	response.Success(c, expense)
}

// DeleteExpense 删除消费记录
// @Summary 删除消费记录
// @Description 删除指定消费记录
// @Tags 消费
// @Produce json
// @Param id path int true "消费记录ID"
// @Success 200 {object} response.Response
// @Router /expenses/{id} [delete]
func (h *ExpenseHandler) DeleteExpense(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "消费记录ID格式错误")
		return
	}

	// TODO: 调用 expenseSvc.DeleteExpense
	_ = id

	response.SuccessWithMessage(c, "删除成功", nil)
}

// ListExpenses 获取消费列表
// @Summary 获取消费列表
// @Description 获取行程的消费记录列表
// @Tags 消费
// @Produce json
// @Param tripId query int true "行程ID"
// @Param page query int false "页码" default(1)
// @Param size query int false "每页数量" default(20)
// @Success 200 {object} response.Response
// @Router /expenses [get]
func (h *ExpenseHandler) ListExpenses(c *gin.Context) {
	tripIDStr := c.Query("tripId")
	tripID, err := strconv.ParseUint(tripIDStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	size, _ := strconv.Atoi(c.DefaultQuery("size", "20"))

	// TODO: 调用 expenseSvc.ListByTripID
	_ = tripID

	response.SuccessPage(c, 0, page, size, []model.Expense{})
}

// GetExpenseSummary 获取消费汇总
// @Summary 获取消费汇总
// @Description 获取行程的消费汇总统计
// @Tags 消费
// @Produce json
// @Param tripId path int true "行程ID"
// @Success 200 {object} response.Response
// @Router /expenses/summary/{tripId} [get]
func (h *ExpenseHandler) GetExpenseSummary(c *gin.Context) {
	tripIDStr := c.Param("tripId")
	tripID, err := strconv.ParseUint(tripIDStr, 10, 64)
	if err != nil {
		response.BadRequest(c, "行程ID格式错误")
		return
	}

	// TODO: 调用 expenseSvc.GetSummary
	_ = tripID

	response.Success(c, &model.ExpenseSummary{})
}

// RegisterExpenseRoutes 注册消费路由
func RegisterExpenseRoutes(r *gin.Engine) {
	h := NewExpenseHandler()
	expenses := r.Group("/expenses")
	{
		expenses.GET("", h.ListExpenses)
		expenses.POST("", h.CreateExpense)
		expenses.GET("/summary/:tripId", h.GetExpenseSummary)
		expenses.GET("/:id", h.GetExpense)
		expenses.PUT("/:id", h.UpdateExpense)
		expenses.DELETE("/:id", h.DeleteExpense)
	}
}
