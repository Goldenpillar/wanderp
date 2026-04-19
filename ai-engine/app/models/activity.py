"""
活动模型

定义活动、景区相关的数据结构。
"""

from typing import Optional

from pydantic import BaseModel, Field


class Activity(BaseModel):
    """活动/景区模型"""
    activity_id: Optional[str] = Field(None, description="活动唯一标识")
    name: str = Field(..., description="活动名称")
    activity_type: str = Field("scenic", description="活动类型(scenic/food/shopping/entertainment/culture/sport/rest)")
    categories: list[str] = Field(default_factory=list, description="分类标签")
    description: Optional[str] = Field(None, description="活动描述")
    address: Optional[str] = Field(None, description="详细地址")
    lat: Optional[float] = Field(None, description="纬度")
    lng: Optional[float] = Field(None, description="经度")
    rating: Optional[float] = Field(None, ge=0, le=5, description="评分(1-5)")
    ticket_price: Optional[float] = Field(None, ge=0, description="门票价格(元)")
    open_hours: str = Field("", description="开放时间")
    duration_minutes: Optional[int] = Field(None, description="建议游览时长(分钟)")
    tags: list[str] = Field(default_factory=list, description="标签")
    image_url: Optional[str] = Field(None, description="封面图片URL")
    booking_required: bool = Field(False, description="是否需要预约")
    booking_url: Optional[str] = Field(None, description="预约链接")
    tips: list[str] = Field(default_factory=list, description="小贴士")


class ActivityRecommendation(BaseModel):
    """活动推荐结果"""
    activity: Activity = Field(..., description="活动信息")
    match_score: float = Field(..., ge=0, le=1, description="匹配度评分")
    match_details: dict = Field(default_factory=dict, description="各维度匹配详情")
    reason: str = Field("", description="推荐理由")
