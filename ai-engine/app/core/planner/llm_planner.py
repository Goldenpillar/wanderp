"""
LLM 行程生成器

封装通义千问API调用，使用精心设计的Prompt模板生成初始行程方案。
支持流式输出和结构化结果解析。
"""

import json
import logging
import uuid
from typing import AsyncGenerator, Optional

from app.config import get_settings
from app.core.planner.plan_models import (
    ActivityNode,
    ActivityType,
    DayPlan,
    EnergyLevel,
    Itinerary,
    Location,
    TimeSlot,
    TransportMode,
    TransportSegment,
)
from app.models.plan_request import PlanRequest
from app.services.llm_service import LLMService

logger = logging.getLogger(__name__)

# ============================================================
# Prompt 模板
# ============================================================

SYSTEM_PROMPT = """你是一位资深的旅行规划师，擅长为用户量身定制旅行行程方案。
你需要根据用户的需求和约束条件，生成详细、合理、可执行的行程安排。

你的规划原则：
1. 合理安排时间：避免行程过于紧凑或松散，留出交通和休息时间
2. 地理位置优化：同一天的活动尽量安排在相近区域，减少往返时间
3. 体验多样性：每天安排不同类型的活动，保持新鲜感
4. 预算控制：在用户预算范围内推荐性价比最高的方案
5. 实用性优先：推荐真实的、可预订的餐厅和景点
6. 考虑体力因素：根据出行人员情况合理安排活动强度

你必须严格按照JSON格式输出行程方案，不要输出任何其他内容。"""

PLAN_GENERATION_PROMPT = """请为以下旅行需求生成一份详细的行程方案：

## 旅行基本信息
- 目的地：{destination}
- 行程天数：{days}天
- 出发日期：{start_date}
- 出行人数：{travelers_count}人
- 旅行者构成：{travelers_description}

## 偏好与约束
- 兴趣偏好：{preferences}
- 预算范围：{budget_range}
- 饮食偏好：{food_preferences}
- 交通偏好：{transport_preferences}
- 特殊需求：{special_requirements}

## 输出要求
请生成JSON格式的行程方案，结构如下：
{{
    "destination": "目的地名称",
    "days": 天数,
    "day_plans": [
        {{
            "day_index": 1,
            "theme": "当日主题（如：古城文化探索）",
            "activities": [
                {{
                    "name": "活动名称",
                    "activity_type": "scenic|food|shopping|entertainment|culture|sport|rest",
                    "location": {{
                        "name": "地点名称",
                        "address": "详细地址",
                        "lat": 纬度,
                        "lng": 经度,
                        "district": "所属区域"
                    }},
                    "start_time": "HH:MM",
                    "end_time": "HH:MM",
                    "duration_minutes": 时长分钟数,
                    "cost": 费用(元),
                    "description": "活动描述",
                    "tips": ["小贴士1", "小贴士2"],
                    "energy_required": "low|medium|high",
                    "rating": 评分(1-5),
                    "booking_required": 是否需要预约(true/false)
                }}
            ],
            "transport_segments": [
                {{
                    "from": "出发地名称",
                    "to": "目的地名称",
                    "mode": "walking|cycling|driving|taxi|bus|subway|train",
                    "duration_minutes": 时长分钟数,
                    "cost": 费用(元),
                    "distance_meters": 距离(米)
                }}
            ],
            "notes": ["当日注意事项"]
        }}
    ],
    "total_budget": 总预算(元),
    "total_cost": 预估总费用(元),
    "tags": ["标签1", "标签2"],
    "tips": ["总体小贴士"],
    "warnings": ["注意事项"]
}}

请确保：
1. 每天至少安排3餐（早餐、午餐、晚餐）
2. 活动之间留出合理的交通时间
3. 每天活动时长控制在合理范围内
4. 推荐的地点和餐厅是真实存在的
5. 费用估算合理
6. 地理位置信息准确"""

PLAN_REFINE_PROMPT = """请根据以下反馈优化行程方案：

## 原始行程
{original_plan}

## 优化要求
{optimization_feedback}

## 约束条件
- 每日预算上限：{daily_budget_max}元
- 每日最大活动时长：{daily_max_hours}小时
- 每日最大步行距离：{max_walking_distance}米

请输出优化后的完整行程JSON方案，格式与原始方案相同。"""


class LLMPlanner:
    """
    LLM 行程生成器

    使用通义千问大模型生成旅行行程方案，
    支持初始生成和迭代优化两种模式。
    """

    def __init__(self):
        """初始化LLM行程生成器"""
        self.settings = get_settings()
        self.llm_service = LLMService()

    async def generate_plan(self, request: PlanRequest) -> Itinerary:
        """
        生成初始行程方案

        Args:
            request: 行程规划请求

        Returns:
            生成的行程方案

        Raises:
            ValueError: 输入参数不合法
            RuntimeError: LLM调用失败
        """
        logger.info(f"开始生成行程: 目的地={request.destination}, 天数={request.days}")

        # 构建提示词
        prompt = self._build_plan_prompt(request)

        try:
            # 调用LLM生成行程
            response = await self.llm_service.chat(
                system_prompt=SYSTEM_PROMPT,
                user_prompt=prompt,
                temperature=0.7,
                max_tokens=4096,
            )

            # 解析LLM返回的JSON
            plan_data = self._parse_llm_response(response)

            # 转换为行程模型
            itinerary = self._to_itinerary(plan_data, request)

            logger.info(f"行程生成成功: plan_id={itinerary.plan_id}")
            return itinerary

        except json.JSONDecodeError as e:
            logger.error(f"LLM返回的JSON格式错误: {e}")
            raise RuntimeError(f"行程生成失败：AI返回格式异常，请重试") from e
        except Exception as e:
            logger.error(f"行程生成失败: {e}", exc_info=True)
            raise RuntimeError(f"行程生成失败：{e}") from e

    async def generate_plan_stream(
        self, request: PlanRequest
    ) -> AsyncGenerator[dict, None]:
        """
        流式生成行程方案

        Args:
            request: 行程规划请求

        Yields:
            流式事件字典
        """
        logger.info(f"开始流式生成行程: 目的地={request.destination}")

        prompt = self._build_plan_prompt(request)
        plan_id = str(uuid.uuid4())

        # 发送开始事件
        yield {"type": "start", "plan_id": plan_id, "message": "正在分析您的需求..."}

        try:
            # 流式调用LLM
            full_response = ""
            async for chunk in self.llm_service.chat_stream(
                system_prompt=SYSTEM_PROMPT,
                user_prompt=prompt,
                temperature=0.7,
            ):
                full_response += chunk
                yield {"type": "chunk", "content": chunk}

            # 解析完整响应
            yield {"type": "parsing", "message": "正在解析行程方案..."}
            plan_data = self._parse_llm_response(full_response)
            itinerary = self._to_itinerary(plan_data, request)

            yield {
                "type": "complete",
                "plan_id": itinerary.plan_id,
                "itinerary": itinerary.model_dump(),
            }

        except Exception as e:
            logger.error(f"流式行程生成失败: {e}", exc_info=True)
            yield {"type": "error", "message": str(e)}

    async def refine_plan(
        self,
        original_itinerary: Itinerary,
        feedback: str,
        constraint_config: Optional[dict] = None,
    ) -> Itinerary:
        """
        根据反馈优化行程方案

        Args:
            original_itinerary: 原始行程方案
            feedback: 优化反馈
            constraint_config: 约束配置

        Returns:
            优化后的行程方案
        """
        logger.info(f"开始优化行程: plan_id={original_itinerary.plan_id}")

        constraint_config = constraint_config or {}
        prompt = PLAN_REFINE_PROMPT.format(
            original_plan=original_itinerary.model_dump_json(indent=2),
            optimization_feedback=feedback,
            daily_budget_max=constraint_config.get("daily_budget_max", "不限"),
            daily_max_hours=constraint_config.get("daily_max_hours", 12),
            max_walking_distance=constraint_config.get("max_walking_distance", 15000),
        )

        try:
            response = await self.llm_service.chat(
                system_prompt=SYSTEM_PROMPT,
                user_prompt=prompt,
                temperature=0.5,
                max_tokens=4096,
            )

            plan_data = self._parse_llm_response(response)
            refined = self._to_itinerary(plan_data, PlanRequest(
                destination=original_itinerary.destination,
                days=original_itinerary.days,
                start_date=original_itinerary.start_date,
                travelers=[],
            ))
            refined.plan_id = original_itinerary.plan_id

            logger.info(f"行程优化成功: plan_id={refined.plan_id}")
            return refined

        except Exception as e:
            logger.error(f"行程优化失败: {e}", exc_info=True)
            raise RuntimeError(f"行程优化失败：{e}") from e

    def _build_plan_prompt(self, request: PlanRequest) -> str:
        """
        构建行程生成提示词

        Args:
            request: 行程规划请求

        Returns:
            格式化后的提示词
        """
        # 构建旅行者描述
        travelers_desc = []
        for t in request.travelers:
            desc = f"{t.age}岁"
            if t.role:
                desc += t.role
            travelers_desc.append(desc)
        travelers_description = "、".join(travelers_desc) if travelers_desc else "未指定"

        # 构建偏好描述
        preferences = []
        if request.preferences:
            preferences.extend(request.preferences)
        preferences_str = "、".join(preferences) if preferences else "无特殊偏好"

        # 构建预算描述
        budget_range = f"{request.budget_min or '不限'}-{request.budget_max or '不限'}元/人"

        # 构建饮食偏好
        food_preferences = request.food_preferences or "无特殊饮食偏好"

        # 构建交通偏好
        transport_preferences = request.transport_preferences or "无特殊交通偏好"

        # 构建特殊需求
        special_requirements = request.special_requirements or "无"

        return PLAN_GENERATION_PROMPT.format(
            destination=request.destination,
            days=request.days,
            start_date=request.start_date or "待定",
            travelers_count=len(request.travelers) or 1,
            travelers_description=travelers_description,
            preferences=preferences_str,
            budget_range=budget_range,
            food_preferences=food_preferences,
            transport_preferences=transport_preferences,
            special_requirements=special_requirements,
        )

    def _parse_llm_response(self, response: str) -> dict:
        """
        解析LLM返回的JSON响应

        Args:
            response: LLM原始响应文本

        Returns:
            解析后的字典

        Raises:
            json.JSONDecodeError: JSON格式错误
        """
        # 尝试直接解析
        try:
            return json.loads(response)
        except json.JSONDecodeError:
            pass

        # 尝试提取JSON代码块
        import re

        json_match = re.search(r"```(?:json)?\s*([\s\S]*?)```", response)
        if json_match:
            return json.loads(json_match.group(1).strip())

        # 尝试提取花括号内容
        brace_match = re.search(r"\{[\s\S]*\}", response)
        if brace_match:
            return json.loads(brace_match.group(0))

        raise json.JSONDecodeError("无法从LLM响应中提取JSON", response, 0)

    def _to_itinerary(self, plan_data: dict, request: PlanRequest) -> Itinerary:
        """
        将LLM返回的字典转换为行程模型

        Args:
            plan_data: LLM返回的行程数据
            request: 原始请求

        Returns:
            行程方案对象
        """
        day_plans = []

        for day_data in plan_data.get("day_plans", []):
            activities = []
            for act_data in day_data.get("activities", []):
                loc_data = act_data.get("location", {})
                location = Location(
                    name=loc_data.get("name", ""),
                    address=loc_data.get("address", ""),
                    lat=loc_data.get("lat", 0.0),
                    lng=loc_data.get("lng", 0.0),
                    district=loc_data.get("district", ""),
                )

                start_time_parts = act_data.get("start_time", "09:00").split(":")
                end_time_parts = act_data.get("end_time", "10:00").split(":")

                activity = ActivityNode(
                    activity_id=str(uuid.uuid4()),
                    name=act_data.get("name", ""),
                    activity_type=ActivityType(act_data.get("activity_type", "scenic")),
                    location=location,
                    time_slot=TimeSlot(
                        start=time(int(start_time_parts[0]), int(start_time_parts[1])),
                        end=time(int(end_time_parts[0]), int(end_time_parts[1])),
                    ),
                    duration_minutes=act_data.get("duration_minutes", 60),
                    cost=act_data.get("cost", 0.0),
                    description=act_data.get("description", ""),
                    tips=act_data.get("tips", []),
                    energy_required=EnergyLevel(act_data.get("energy_required", "medium")),
                    rating=act_data.get("rating"),
                    booking_required=act_data.get("booking_required", False),
                )
                activities.append(activity)

            transport_segments = []
            for trans_data in day_data.get("transport_segments", []):
                segment = TransportSegment(
                    from_location=Location(
                        name=trans_data.get("from", ""),
                        lat=0.0, lng=0.0,
                    ),
                    to_location=Location(
                        name=trans_data.get("to", ""),
                        lat=0.0, lng=0.0,
                    ),
                    mode=TransportMode(trans_data.get("mode", "taxi")),
                    duration_minutes=trans_data.get("duration_minutes", 0),
                    cost=trans_data.get("cost", 0.0),
                    distance_meters=trans_data.get("distance_meters", 0.0),
                )
                transport_segments.append(segment)

            day_plan = DayPlan(
                day_index=day_data.get("day_index", 1),
                theme=day_data.get("theme", ""),
                activities=activities,
                transport_segments=transport_segments,
                notes=day_data.get("notes", []),
            )
            day_plans.append(day_plan)

        return Itinerary(
            plan_id=str(uuid.uuid4()),
            destination=plan_data.get("destination", request.destination),
            days=plan_data.get("days", request.days),
            start_date=request.start_date,
            day_plans=day_plans,
            total_budget=plan_data.get("total_budget", 0.0),
            total_cost=plan_data.get("total_cost", 0.0),
            travelers_count=len(request.travelers) or 1,
            tags=plan_data.get("tags", []),
            tips=plan_data.get("tips", []),
            warnings=plan_data.get("warnings", []),
        )
