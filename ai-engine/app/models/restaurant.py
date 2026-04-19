"""
餐厅模型

定义餐厅相关的数据结构。
"""

from typing import Optional

from pydantic import BaseModel, Field


class Restaurant(BaseModel):
    """餐厅模型"""
    restaurant_id: Optional[str] = Field(None, description="餐厅唯一标识")
    name: str = Field(..., description="餐厅名称")
    cuisine: str = Field("", description="菜系类型")
    description: Optional[str] = Field(None, description="餐厅描述")
    address: Optional[str] = Field(None, description="详细地址")
    lat: Optional[float] = Field(None, description="纬度")
    lng: Optional[float] = Field(None, description="经度")
    avg_price: float = Field(0.0, ge=0, description="人均消费(元)")
    rating: Optional[float] = Field(None, ge=0, le=5, description="评分(1-5)")
    review_count: Optional[int] = Field(None, ge=0, description="评论数量")
    tags: list[str] = Field(default_factory=list, description="标签")
    phone: str = Field("", description="联系电话")
    open_hours: str = Field("", description="营业时间")
    image_url: Optional[str] = Field(None, description="封面图片URL")
    recommend_dishes: list[str] = Field(default_factory=list, description="推荐菜品")


class RestaurantRecommendation(BaseModel):
    """餐厅推荐结果"""
    restaurant: Restaurant = Field(..., description="餐厅信息")
    match_score: float = Field(..., ge=0, le=1, description="匹配度评分")
    match_details: dict = Field(default_factory=dict, description="各维度匹配详情")
    reason: str = Field("", description="推荐理由")
