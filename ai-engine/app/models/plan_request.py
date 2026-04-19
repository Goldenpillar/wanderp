"""
规划请求/响应模型

定义行程规划API的请求和响应数据结构。
"""

from datetime import date
from typing import Optional

from pydantic import BaseModel, Field

from app.models.preference import TravelerInfo


class TravelerRequest(BaseModel):
    """请求中的旅行者信息"""
    age: Optional[int] = Field(None, description="年龄")
    role: Optional[str] = Field(None, description="角色(如: 父母/孩子/朋友/情侣)")
    special_needs: Optional[str] = Field(None, description="特殊需求")


class PlanRequest(BaseModel):
    """行程规划请求"""
    destination: str = Field(..., min_length=1, description="目的地城市/地区")
    days: int = Field(..., ge=1, le=30, description="行程天数")
    start_date: Optional[date] = Field(None, description="出发日期")
    travelers: list[TravelerRequest] = Field(default_factory=list, description="旅行者列表")
    preferences: Optional[list[str]] = Field(None, description="偏好列表(如: 文化,美食,自然)")
    budget_min: Optional[float] = Field(None, ge=0, description="最低预算(元/人)")
    budget_max: Optional[float] = Field(None, ge=0, description="最高预算(元/人)")
    food_preferences: Optional[str] = Field(None, description="饮食偏好描述")
    transport_preferences: Optional[str] = Field(None, description="交通偏好描述")
    special_requirements: Optional[str] = Field(None, description="特殊需求描述")


class PlanResponse(BaseModel):
    """行程规划响应"""
    plan_id: str = Field(..., description="规划任务ID")
    status: str = Field(..., description="规划状态(pending/generating/validating/optimizing/completed/failed)")
    destination: str = Field(..., description="目的地")
    days: int = Field(..., description="行程天数")
    itinerary: list = Field(default_factory=list, description="每日行程列表")
    total_budget: float = Field(0, description="总预算(元)")
    total_cost: float = Field(0, description="预计总花费(元)")
    travelers_count: int = Field(1, description="旅行人数")
    tags: list[str] = Field(default_factory=list, description="行程标签")
    warnings: list[str] = Field(default_factory=list, description="注意事项/警告")
    tips: list[str] = Field(default_factory=list, description="旅行小贴士")


class PlanStatusResponse(BaseModel):
    """规划状态响应"""
    plan_id: str = Field(..., description="规划任务ID")
    status: str = Field(..., description="规划状态")
    progress: int = Field(0, ge=0, le=100, description="进度百分比")
    message: str = Field("", description="状态消息")


class PlanOptimizeRequest(BaseModel):
    """行程优化请求"""
    preferences: Optional[list[str]] = Field(None, description="调整后的偏好")
    budget_max: Optional[float] = Field(None, ge=0, description="调整后的预算上限")
    feedback: Optional[str] = Field(None, description="用户反馈")
    adjust_days: Optional[int] = Field(None, ge=1, le=30, description="调整天数")
