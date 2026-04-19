"""
偏好模型

定义用户偏好相关的数据结构。
"""

from typing import Optional

from pydantic import BaseModel, Field


class PreferenceProfile(BaseModel):
    """用户偏好画像"""
    user_id: str = Field(..., description="用户ID")
    food_preferences: list[str] = Field(default_factory=list, description="饮食偏好列表")
    activity_preferences: list[str] = Field(default_factory=list, description="活动偏好列表")
    budget_level: str = Field("medium", description="预算水平(low/medium/high/luxury)")
    pace_preference: str = Field("medium", description="节奏偏好(relaxed/medium/fast)")
    transport_preference: str = Field("balanced", description="交通偏好(economy/balanced/comfort)")
    accommodation_preference: str = Field("comfort", description="住宿偏好(budget/comfort/luxury)")
    special_requirements: list[str] = Field(default_factory=list, description="特殊需求")
    confidence: float = Field(0.5, ge=0, le=1, description="偏好置信度")


class PreferenceInput(BaseModel):
    """偏好分析输入"""
    user_id: str = Field(..., description="用户ID")
    food_preferences: Optional[list[str]] = Field(None, description="饮食偏好")
    activity_preferences: Optional[list[str]] = Field(None, description="活动偏好")
    budget_level: Optional[str] = Field(None, description="预算水平")
    pace_preference: Optional[str] = Field(None, description="节奏偏好")
    transport_preference: Optional[str] = Field(None, description="交通偏好")
    accommodation_preference: Optional[str] = Field(None, description="住宿偏好")
    special_requirements: Optional[list[str]] = Field(None, description="特殊需求")
    history_behaviors: Optional[list[dict]] = Field(None, description="历史行为数据")
    questionnaire_answers: Optional[list[dict]] = Field(None, description="问卷回答")


class TravelerInfo(BaseModel):
    """旅行者信息"""
    user_id: Optional[str] = Field(None, description="用户ID")
    name: Optional[str] = Field(None, description="姓名")
    age: Optional[int] = Field(None, description="年龄")
    role: Optional[str] = Field(None, description="角色(如: 父母/孩子/朋友)")
    food_preferences: Optional[list[str]] = Field(None, description="饮食偏好")
    activity_preferences: Optional[list[str]] = Field(None, description="活动偏好")
    budget_level: Optional[str] = Field(None, description="预算水平")
    pace_preference: Optional[str] = Field(None, description="节奏偏好")
    transport_preference: Optional[str] = Field(None, description="交通偏好")
    accommodation_preference: Optional[str] = Field(None, description="住宿偏好")
    special_requirements: Optional[list[str]] = Field(None, description="特殊需求")


class TravelerPreferencesRequest(BaseModel):
    """多人偏好请求"""
    travelers: list[TravelerInfo] = Field(..., min_length=1, description="旅行者列表")


class PreferenceAnalysisResponse(BaseModel):
    """偏好分析响应"""
    user_id: str = Field(..., description="用户ID")
    profile: PreferenceProfile = Field(..., description="偏好画像")
    confidence: float = Field(..., description="分析置信度")
    compromise_areas: list = Field(default_factory=list, description="妥协区域")
    consensus_areas: list[str] = Field(default_factory=list, description="共识区域")
