"""
行程规划数据模型

定义行程规划过程中使用的所有数据结构，
包括行程方案、日程安排、活动节点等。
"""

from datetime import date, datetime, time
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class TransportMode(str, Enum):
    """交通方式枚举"""
    WALKING = "walking"
    CYCLING = "cycling"
    DRIVING = "driving"
    TAXI = "taxi"
    BUS = "bus"
    SUBWAY = "subway"
    TRAIN = "train"
    FLIGHT = "flight"


class ActivityType(str, Enum):
    """活动类型枚举"""
    SCENIC = "scenic"          # 景区游览
    FOOD = "food"              # 美食体验
    SHOPPING = "shopping"      # 购物
    ENTERTAINMENT = "entertainment"  # 娱乐
    CULTURE = "culture"        # 文化体验
    SPORT = "sport"            # 运动户外
    REST = "rest"              # 休息
    TRANSPORT = "transport"    # 交通中转


class EnergyLevel(str, Enum):
    """体力等级枚举"""
    LOW = "low"          # 低（适合休闲）
    MEDIUM = "medium"    # 中等
    HIGH = "high"        # 高（适合高强度活动）


class TimeSlot(BaseModel):
    """时间段"""
    start: time = Field(..., description="开始时间")
    end: time = Field(..., description="结束时间")

    @property
    def duration_hours(self) -> float:
        """计算持续时间（小时）"""
        start_minutes = self.start.hour * 60 + self.start.minute
        end_minutes = self.end.hour * 60 + self.end.minute
        return max(0, (end_minutes - start_minutes) / 60)


class Location(BaseModel):
    """地理位置"""
    name: str = Field(..., description="地点名称")
    address: str = Field("", description="详细地址")
    lat: float = Field(..., description="纬度")
    lng: float = Field(..., description="经度")
    district: str = Field("", description="所属区域")


class ActivityNode(BaseModel):
    """活动节点 - 行程中的单个活动"""
    activity_id: str = Field(..., description="活动唯一标识")
    name: str = Field(..., description="活动名称")
    activity_type: ActivityType = Field(..., description="活动类型")
    location: Location = Field(..., description="活动地点")
    time_slot: TimeSlot = Field(..., description="时间段")
    duration_minutes: int = Field(..., ge=15, description="建议时长(分钟)")
    cost: float = Field(0.0, ge=0, description="预估费用(元)")
    description: str = Field("", description="活动描述")
    tips: list[str] = Field(default_factory=list, description="小贴士")
    energy_required: EnergyLevel = Field(EnergyLevel.MEDIUM, description="所需体力等级")
    rating: Optional[float] = Field(None, ge=0, le=5, description="评分")
    image_url: Optional[str] = Field(None, description="封面图片URL")
    booking_required: bool = Field(False, description="是否需要预约")
    booking_url: Optional[str] = Field(None, description="预约链接")


class TransportSegment(BaseModel):
    """交通路段"""
    from_location: Location = Field(..., description="出发地")
    to_location: Location = Field(..., description="目的地")
    mode: TransportMode = Field(..., description="交通方式")
    duration_minutes: int = Field(..., ge=0, description="预计时长(分钟)")
    cost: float = Field(0.0, ge=0, description="预计费用(元)")
    distance_meters: float = Field(0.0, ge=0, description="距离(米)")
    description: str = Field("", description="交通描述")


class DayPlan(BaseModel):
    """单日行程计划"""
    day_index: int = Field(..., ge=1, description="第几天")
    date: Optional[date] = Field(None, description="具体日期")
    theme: str = Field("", description="当日主题")
    activities: list[ActivityNode] = Field(default_factory=list, description="活动列表")
    transport_segments: list[TransportSegment] = Field(
        default_factory=list, description="交通路段列表"
    )
    total_cost: float = Field(0.0, ge=0, description="当日总费用")
    total_distance_meters: float = Field(0.0, ge=0, description="当日总距离(米)")
    notes: list[str] = Field(default_factory=list, description="当日备注")

    @property
    def start_time(self) -> Optional[time]:
        """当日开始时间"""
        if self.activities:
            return self.activities[0].time_slot.start
        return None

    @property
    def end_time(self) -> Optional[time]:
        """当日结束时间"""
        if self.activities:
            return self.activities[-1].time_slot.end
        return None


class Itinerary(BaseModel):
    """完整行程方案"""
    plan_id: str = Field(..., description="方案ID")
    destination: str = Field(..., description="目的地")
    days: int = Field(..., ge=1, description="行程天数")
    start_date: Optional[date] = Field(None, description="开始日期")
    end_date: Optional[date] = Field(None, description="结束日期")
    day_plans: list[DayPlan] = Field(default_factory=list, description="每日行程")
    total_budget: float = Field(0.0, ge=0, description="总预算(元)")
    total_cost: float = Field(0.0, ge=0, description="预估总费用(元)")
    travelers_count: int = Field(1, ge=1, description="出行人数")
    tags: list[str] = Field(default_factory=list, description="行程标签")
    tips: list[str] = Field(default_factory=list, description="行程小贴士")
    warnings: list[str] = Field(default_factory=list, description="注意事项")


class ConstraintConfig(BaseModel):
    """约束配置"""
    daily_budget_max: Optional[float] = Field(None, description="每日最大预算")
    total_budget_max: Optional[float] = Field(None, description="总预算上限")
    daily_activity_hours_max: float = Field(12.0, ge=1, le=16, description="每日最大活动时长(小时)")
    daily_activity_hours_min: float = Field(4.0, ge=1, le=12, description="每日最小活动时长(小时)")
    max_walking_distance_meters: float = Field(15000.0, ge=0, description="每日最大步行距离(米)")
    meal_times: list[TimeSlot] = Field(
        default_factory=lambda: [
            TimeSlot(start=time(7, 0), end=time(9, 0)),    # 早餐
            TimeSlot(start=time(11, 30), end=time(13, 30)),  # 午餐
            TimeSlot(start=time(17, 30), end=time(19, 30)),  # 晚餐
        ],
        description="用餐时间段",
    )
    rest_required: bool = Field(True, description="是否需要安排休息时间")
    transport_preference: list[TransportMode] = Field(
        default_factory=lambda: [TransportMode.SUBWAY, TransportMode.TAXI, TransportMode.WALKING],
        description="偏好的交通方式",
    )
