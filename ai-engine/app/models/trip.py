"""
行程模型

定义行程相关的数据结构。
"""

from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, Field


class Trip(BaseModel):
    """行程模型"""
    trip_id: str = Field(..., description="行程唯一标识")
    user_id: str = Field(..., description="用户ID")
    title: str = Field(..., description="行程标题")
    destination: str = Field(..., description="目的地")
    start_date: date = Field(..., description="开始日期")
    end_date: date = Field(..., description="结束日期")
    days: int = Field(..., ge=1, description="行程天数")
    travelers_count: int = Field(1, ge=1, description="出行人数")
    total_budget: Optional[float] = Field(None, description="总预算(元)")
    total_cost: Optional[float] = Field(None, description="实际总费用(元)")
    status: str = Field("draft", description="行程状态(draft/confirmed/completed/cancelled)")
    cover_image: Optional[str] = Field(None, description="封面图片URL")
    tags: list[str] = Field(default_factory=list, description="标签")
    notes: Optional[str] = Field(None, description="备注")
    created_at: datetime = Field(default_factory=datetime.now, description="创建时间")
    updated_at: datetime = Field(default_factory=datetime.now, description="更新时间")


class TripSummary(BaseModel):
    """行程摘要"""
    trip_id: str = Field(..., description="行程ID")
    title: str = Field(..., description="行程标题")
    destination: str = Field(..., description="目的地")
    start_date: date = Field(..., description="开始日期")
    end_date: date = Field(..., description="结束日期")
    days: int = Field(..., description="行程天数")
    status: str = Field(..., description="行程状态")
    cover_image: Optional[str] = Field(None, description="封面图片")
    tags: list[str] = Field(default_factory=list, description="标签")
