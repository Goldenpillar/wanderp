"""
用户模型

定义用户相关的数据结构。
"""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class User(BaseModel):
    """用户模型"""
    user_id: str = Field(..., description="用户唯一标识")
    username: Optional[str] = Field(None, description="用户名")
    nickname: Optional[str] = Field(None, description="昵称")
    avatar_url: Optional[str] = Field(None, description="头像URL")
    phone: Optional[str] = Field(None, description="手机号")
    email: Optional[str] = Field(None, description="邮箱")
    gender: Optional[str] = Field(None, description="性别(male/female/other)")
    birthday: Optional[str] = Field(None, description="生日")
    city: Optional[str] = Field(None, description="所在城市")
    travel_count: int = Field(0, description="旅行次数")
    created_at: datetime = Field(default_factory=datetime.now, description="注册时间")
    updated_at: datetime = Field(default_factory=datetime.now, description="更新时间")


class UserProfile(BaseModel):
    """用户公开信息"""
    user_id: str = Field(..., description="用户ID")
    nickname: Optional[str] = Field(None, description="昵称")
    avatar_url: Optional[str] = Field(None, description="头像URL")
    city: Optional[str] = Field(None, description="所在城市")
    travel_count: int = Field(0, description="旅行次数")
