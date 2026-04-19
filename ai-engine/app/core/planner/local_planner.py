"""
本地行程规划器

使用规则+启发式算法替代 LLM 生成行程方案。
基于真实 Mock 数据（景区、餐厅、演出、天气、交通），
通过地理聚类、偏好匹配、预算约束等策略生成合理的旅行行程。

核心设计理念 —— P人友好：
- 每个活动提供 2-3 个选项（Plan B），让行程灵活可变
- 每天安排 2-3 个景区 + 3 餐 + 1-2 个备选
- 同一天的活动在地理上相近，减少交通时间
- 根据用户偏好（文化/美食/自然等）排序推荐
"""

import logging
import math
import uuid
from datetime import date, datetime, time, timedelta
from typing import Optional

from app.core.mock_data_loader import (
    get_events,
    get_restaurants,
    get_scenic_spots,
    get_transport,
    get_weather,
    search_poi,
)
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

logger = logging.getLogger(__name__)


# ============================================================
# 地理区域定义 —— 用于同一天活动的地理聚类
# ============================================================

# 杭州区域划分（基于经纬度粗略划分）
HANGZHOU_REGIONS = {
    "西湖核心区": {
        "lat_range": (30.230, 30.260),
        "lng_range": (120.135, 120.155),
        "description": "西湖十景、断桥、白堤、孤山一带",
    },
    "灵隐景区": {
        "lat_range": (30.235, 30.245),
        "lng_range": (120.090, 120.110),
        "description": "灵隐寺、法喜寺、飞来峰一带",
    },
    "西溪湿地": {
        "lat_range": (30.260, 30.275),
        "lng_range": (120.060, 120.080),
        "description": "西溪湿地及周边",
    },
    "上城区/河坊街": {
        "lat_range": (30.240, 30.255),
        "lng_range": (120.160, 120.175),
        "description": "河坊街、南宋御街、吴山广场",
    },
    "之江/宋城": {
        "lat_range": (30.175, 30.195),
        "lng_range": (120.110, 120.130),
        "description": "宋城景区、之江路沿线",
    },
}

# 北京区域划分
BEIJING_REGIONS = {
    "天安门-故宫": {
        "lat_range": (39.900, 39.920),
        "lng_range": (116.390, 116.410),
        "description": "天安门广场、故宫、国家博物馆",
    },
    "什刹海-南锣鼓巷": {
        "lat_range": (39.930, 39.950),
        "lng_range": (116.375, 116.405),
        "description": "什刹海、南锣鼓巷、鼓楼",
    },
    "颐和园-圆明园": {
        "lat_range": (39.990, 40.015),
        "lng_range": (116.270, 116.310),
        "description": "颐和园、圆明园、清华北大",
    },
    "天坛-前门": {
        "lat_range": (39.870, 39.900),
        "lng_range": (116.390, 116.430),
        "description": "天坛、前门大街、大栅栏",
    },
    "奥林匹克公园": {
        "lat_range": (39.980, 40.010),
        "lng_range": (116.370, 116.400),
        "description": "鸟巢、水立方",
    },
}

# 城市到区域映射
_CITY_REGIONS = {
    "杭州": HANGZHOU_REGIONS,
    "北京": BEIJING_REGIONS,
}

# 每日主题模板（根据天数和城市自动分配）
_DAY_THEMES = {
    "杭州": [
        "西湖经典漫步",
        "灵隐禅意之旅",
        "文化深度探索",
        "自然生态休闲",
        "市井烟火体验",
    ],
    "北京": [
        "皇城经典巡礼",
        "长城壮志之旅",
        "胡同文化漫步",
        "皇家园林探秘",
        "现代艺术之旅",
    ],
}


class LocalPlanner:
    """
    本地行程规划器

    使用规则+启发式算法，基于 Mock 数据生成合理的旅行行程。
    无需任何外部 API 调用。
    """

    def __init__(self):
        """初始化规划器"""
        self._plan_id = str(uuid.uuid4())

    def generate_itinerary(self, request: PlanRequest) -> Itinerary:
        """
        生成完整行程方案

        Args:
            request: 行程规划请求

        Returns:
            符合 Itinerary 模型的完整行程方案
        """
        logger.info(
            f"[LocalPlanner] 开始生成行程: 目的地={request.destination}, "
            f"天数={request.days}, 偏好={request.preferences}"
        )

        self._plan_id = str(uuid.uuid4())
        destination = request.destination
        days = request.days
        preferences = request.preferences or []
        budget_max = request.budget_max
        food_preferences = request.food_preferences

        # 1. 加载城市数据
        spots = get_scenic_spots(destination)
        restaurants = get_restaurants(destination)
        events = get_events(destination)
        weather = get_weather(destination)

        if not spots:
            logger.warning(f"未找到 {destination} 的景区数据，尝试模糊搜索")
            # 尝试从关键词搜索
            search_results = search_poi(destination, "")
            if not search_results:
                raise ValueError(f"暂不支持目的地: {destination}，当前支持: 杭州、北京")

        # 2. 根据偏好对景区排序
        ranked_spots = self._rank_by_preferences(spots, preferences)

        # 3. 根据预算筛选餐厅
        budget_per_meal = None
        if budget_max:
            # 预算分配：约 40% 用于餐饮（每天3餐）
            budget_per_meal = (budget_max * 0.4) / (days * 3)

        filtered_restaurants = restaurants
        if budget_per_meal:
            filtered_restaurants = [
                r for r in restaurants
                if r.get("avg_price", 0) <= budget_per_meal * 1.5  # 留一些弹性
            ]
            # 如果筛选后太少，放宽限制
            if len(filtered_restaurants) < 3:
                filtered_restaurants = sorted(
                    restaurants, key=lambda x: x.get("avg_price", 999)
                )[:len(restaurants)]

        # 4. 按地理区域分组景区
        regions = _CITY_REGIONS.get(destination, {})
        region_spots = self._group_spots_by_region(ranked_spots, regions)

        # 5. 获取每日主题
        themes = _DAY_THEMES.get(destination, [f"第{i+1}天探索" for i in range(days)])

        # 6. 生成每日行程
        day_plans = []
        used_spot_indices = set()

        for day_idx in range(days):
            day_plan = self._generate_day_plan(
                day_index=day_idx + 1,
                theme=themes[day_idx % len(themes)],
                all_spots=ranked_spots,
                used_indices=used_spot_indices,
                restaurants=filtered_restaurants,
                events=events,
                preferences=preferences,
                food_preferences=food_preferences,
                regions=regions,
                region_spots=region_spots,
                weather=weather,
                start_date=request.start_date,
            )
            day_plans.append(day_plan)

        # 7. 计算总费用
        total_cost = sum(dp.total_cost for dp in day_plans)

        # 8. 生成旅行贴士
        tips = self._generate_tips(destination, weather, preferences, budget_max)

        # 9. 生成注意事项
        warnings = self._generate_warnings(destination, weather)

        # 10. 计算日期范围
        start_date = request.start_date or date.today()
        end_date = start_date + timedelta(days=days - 1)

        itinerary = Itinerary(
            plan_id=self._plan_id,
            destination=destination,
            days=days,
            start_date=start_date,
            end_date=end_date,
            day_plans=day_plans,
            total_budget=budget_max or total_cost * 1.2,
            total_cost=total_cost,
            travelers_count=max(len(request.travelers), 1),
            tags=preferences[:5] if preferences else ["精选推荐"],
            tips=tips,
            warnings=warnings,
        )

        logger.info(f"[LocalPlanner] 行程生成完成: plan_id={self._plan_id}, 总费用={total_cost:.0f}元")
        return itinerary

    def _generate_day_plan(
        self,
        day_index: int,
        theme: str,
        all_spots: list[dict],
        used_indices: set[int],
        restaurants: list[dict],
        events: list[dict],
        preferences: list[str],
        food_preferences: Optional[str],
        regions: dict,
        region_spots: dict[str, list[dict]],
        weather: dict,
        start_date: Optional[date],
    ) -> DayPlan:
        """
        生成单日行程计划

        Args:
            day_index: 第几天（从1开始）
            theme: 当日主题
            all_spots: 所有景区列表
            used_indices: 已使用的景区索引集合
            restaurants: 餐厅列表
            events: 演出列表
            preferences: 用户偏好
            food_preferences: 饮食偏好
            regions: 区域定义
            region_spots: 按区域分组的景区
            weather: 天气信息
            start_date: 行程开始日期

        Returns:
            单日行程计划
        """
        activities = []
        transport_segments = []
        total_cost = 0.0
        notes = []

        # 计算当日日期
        day_date = None
        if start_date:
            day_date = start_date + timedelta(days=day_index - 1)

        # ---- 选择当天的主景区（2-3个，同一区域） ----
        # 优先选择同一区域的景区，减少交通时间
        day_spots = self._select_day_spots(
            all_spots, used_indices, region_spots, preferences, count=3
        )

        # ---- 上午活动 (09:00 - 12:00) ----
        if day_spots:
            spot_a = day_spots[0]
            act_a = self._spot_to_activity(spot_a, TimeSlot(
                start=time(9, 0), end=time(11, 30)
            ))
            activities.append(act_a)
            total_cost += act_a.cost
            used_indices.add(all_spots.index(spot_a) if spot_a in all_spots else -1)

            # 上午备选方案（Plan B）
            if len(day_spots) > 1:
                alt_spot = day_spots[1]
                alt_act = self._spot_to_activity(alt_spot, TimeSlot(
                    start=time(9, 0), end=time(11, 30)
                ))
                notes.append(
                    f"上午备选: 可替换为「{alt_spot.get('name', '')}」"
                    f"（{alt_spot.get('type', '')}，门票{alt_spot.get('ticket_price_num', alt_spot.get('ticket_price', 0))}元）"
                )

        # ---- 午餐 (12:00 - 13:30) ----
        lunch_restaurants = self._select_restaurants(
            restaurants, food_preferences, price_range="mid", count=3
        )
        if lunch_restaurants:
            lunch = lunch_restaurants[0]
            lunch_act = self._restaurant_to_activity(
                lunch, TimeSlot(start=time(12, 0), end=time(13, 30)), meal_type="午餐"
            )
            activities.append(lunch_act)
            total_cost += lunch_act.cost

            # 午餐备选
            if len(lunch_restaurants) > 1:
                notes.append(
                    f"午餐备选: 「{lunch_restaurants[1].get('name', '')}」"
                    f"（人均{lunch_restaurants[1].get('avg_price', 0)}元，"
                    f"{lunch_restaurants[1].get('cuisine', lunch_restaurants[1].get('cuisine_type', ''))}）"
                )
            if len(lunch_restaurants) > 2:
                notes.append(
                    f"午餐备选: 「{lunch_restaurants[2].get('name', '')}」"
                    f"（人均{lunch_restaurants[2].get('avg_price', 0)}元）"
                )

        # ---- 下午活动 (14:00 - 17:00) ----
        if len(day_spots) > 1:
            spot_b = day_spots[1]
            act_b = self._spot_to_activity(spot_b, TimeSlot(
                start=time(14, 0), end=time(16, 30)
            ))
            activities.append(act_b)
            total_cost += act_b.cost
            used_indices.add(all_spots.index(spot_b) if spot_b in all_spots else -1)

            # 下午备选
            if len(day_spots) > 2:
                alt_spot_b = day_spots[2]
                notes.append(
                    f"下午备选: 可替换为「{alt_spot_b.get('name', '')}」"
                    f"（{alt_spot_b.get('type', '')}，"
                    f"建议游览{alt_spot_b.get('suggested_duration', '2小时')}）"
                )
        elif day_spots:
            # 只有一个景区时，下午安排自由活动或周边探索
            notes.append("下午建议: 在景区周边自由探索，或找一家咖啡馆休息")

        # ---- 晚餐 (18:00 - 19:30) ----
        dinner_restaurants = self._select_restaurants(
            restaurants, food_preferences, price_range="high", count=3
        )
        if dinner_restaurants:
            dinner = dinner_restaurants[0]
            dinner_act = self._restaurant_to_activity(
                dinner, TimeSlot(start=time(18, 0), end=time(19, 30)), meal_type="晚餐"
            )
            activities.append(dinner_act)
            total_cost += dinner_act.cost

            # 晚餐备选
            if len(dinner_restaurants) > 1:
                notes.append(
                    f"晚餐备选: 「{dinner_restaurants[1].get('name', '')}」"
                    f"（人均{dinner_restaurants[1].get('avg_price', 0)}元，"
                    f"{dinner_restaurants[1].get('cuisine', dinner_restaurants[1].get('cuisine_type', ''))}）"
                )

        # ---- 晚间活动 (20:00 - 21:30) ----
        evening_events = self._select_evening_events(events, preferences)
        if evening_events:
            event = evening_events[0]
            event_act = self._event_to_activity(event, TimeSlot(
                start=time(20, 0), end=time(21, 30)
            ))
            activities.append(event_act)
            total_cost += event_act.cost

            if len(evening_events) > 1:
                notes.append(
                    f"晚间备选: 「{evening_events[1].get('name', '')}」"
                    f"（{evening_events[1].get('type', '')}，"
                    f"{evening_events[1].get('ticket_price_range', '')}）"
                )
        else:
            notes.append("晚间建议: 沿湖/沿河散步，或体验当地夜市小吃")

        # ---- 生成交通路段 ----
        transport_segments = self._generate_transport_segments(activities)

        # 计算当日总距离
        total_distance = sum(ts.distance_meters for ts in transport_segments)

        return DayPlan(
            day_index=day_index,
            date=day_date,
            theme=theme,
            activities=activities,
            transport_segments=transport_segments,
            total_cost=total_cost,
            total_distance_meters=total_distance,
            notes=notes,
        )

    def _select_day_spots(
        self,
        all_spots: list[dict],
        used_indices: set[int],
        region_spots: dict[str, list[dict]],
        preferences: list[str],
        count: int = 3,
    ) -> list[dict]:
        """
        选择当天的景区（同一区域优先）

        Args:
            all_spots: 所有景区
            used_indices: 已使用索引
            region_spots: 按区域分组的景区
            preferences: 用户偏好
            count: 需要选择的数量

        Returns:
            选中的景区列表
        """
        available = [
            (i, spot) for i, spot in enumerate(all_spots)
            if i not in used_indices
        ]

        if not available:
            return []

        # 尝试从同一区域选择
        for region_name, spots in region_spots.items():
            region_available = [
                (i, spot) for i, spot in enumerate(all_spots)
                if spot in spots and i not in used_indices
            ]
            if len(region_available) >= count:
                selected = [spot for _, spot in region_available[:count]]
                return selected

        # 如果同一区域不够，从可用列表中选择（按评分排序）
        available_sorted = sorted(available, key=lambda x: x[1].get("rating", 0), reverse=True)
        return [spot for _, spot in available_sorted[:count]]

    def _select_restaurants(
        self,
        restaurants: list[dict],
        food_preferences: Optional[str],
        price_range: str = "mid",
        count: int = 3,
    ) -> list[dict]:
        """
        选择餐厅推荐

        Args:
            restaurants: 餐厅列表
            food_preferences: 饮食偏好
            price_range: 价格档次 (low/mid/high)
            count: 需要选择的数量

        Returns:
            选中的餐厅列表
        """
        if not restaurants:
            return []

        # 按菜系偏好筛选
        filtered = restaurants
        if food_preferences:
            filtered = [
                r for r in restaurants
                if food_preferences in r.get("cuisine", "")
                or food_preferences in r.get("cuisine_type", "")
                or food_preferences in r.get("description", "")
            ]
            # 如果筛选后太少，使用全部
            if len(filtered) < count:
                filtered = restaurants

        # 按价格档次筛选
        if price_range == "low":
            filtered = sorted(filtered, key=lambda x: x.get("avg_price", 999))[:count]
        elif price_range == "high":
            filtered = sorted(filtered, key=lambda x: x.get("avg_price", 0), reverse=True)[:count]
        else:
            # mid: 取中间价位
            filtered = sorted(filtered, key=lambda x: x.get("rating", 0), reverse=True)[:count]

        return filtered[:count]

    def _select_evening_events(
        self,
        events: list[dict],
        preferences: list[str],
    ) -> list[dict]:
        """
        选择晚间活动/演出

        Args:
            events: 演出列表
            preferences: 用户偏好

        Returns:
            匹配的演出列表
        """
        if not events:
            return []

        # 优先选择免费或低价演出
        free_events = [
            e for e in events
            if e.get("ticket_price_min", 0) == 0 or e.get("ticket_price_range", "") == "免费"
        ]
        if free_events:
            return free_events[:2]

        # 按价格排序，优先低价
        sorted_events = sorted(events, key=lambda x: x.get("ticket_price_min", 999))
        return sorted_events[:2]

    def _rank_by_preferences(
        self,
        spots: list[dict],
        preferences: list[str],
    ) -> list[dict]:
        """
        根据用户偏好对景区排序

        Args:
            spots: 景区列表
            preferences: 用户偏好列表

        Returns:
            排序后的景区列表
        """
        if not preferences:
            return sorted(spots, key=lambda x: x.get("rating", 0), reverse=True)

        def preference_score(spot: dict) -> float:
            """计算景区与偏好的匹配分数"""
            score = spot.get("rating", 4.0)  # 基础分：评分
            spot_type = spot.get("type", "")
            desc = spot.get("description", "") or ""
            name = spot.get("name", "")

            # 偏好关键词匹配加分
            for pref in preferences:
                if pref in spot_type or pref in desc or pref in name:
                    score += 1.5
                # 模糊匹配
                pref_keywords = {
                    "文化": ["博物馆", "历史", "文化", "古迹", "遗址", "故居"],
                    "美食": ["小吃", "美食", "餐厅", "老字号"],
                    "自然": ["自然", "公园", "湿地", "山", "湖", "溪"],
                    "历史": ["历史", "古迹", "故宫", "长城", "寺庙", "遗址"],
                    "亲子": ["动物园", "乐园", "亲子", "博物馆"],
                    "浪漫": ["西湖", "夜游", "灯光", "游船"],
                    "摄影": ["风景", "日出", "日落", "樱花", "花"],
                    "休闲": ["茶", "温泉", "公园", "湿地"],
                }
                for keyword in pref_keywords.get(pref, []):
                    if keyword in spot_type or keyword in desc or keyword in name:
                        score += 0.8

            return score

        return sorted(spots, key=preference_score, reverse=True)

    def _group_spots_by_region(
        self,
        spots: list[dict],
        regions: dict[str, dict],
    ) -> dict[str, list[dict]]:
        """
        将景区按地理区域分组

        Args:
            spots: 景区列表
            regions: 区域定义

        Returns:
            按区域分组的景区字典
        """
        grouped = {name: [] for name in regions}

        for spot in spots:
            lat = spot.get("latitude", 0)
            lng = spot.get("longitude", 0)

            for region_name, region_info in regions.items():
                lat_min, lat_max = region_info["lat_range"]
                lng_min, lng_max = region_info["lng_range"]
                if lat_min <= lat <= lat_max and lng_min <= lng <= lng_max:
                    grouped[region_name].append(spot)
                    break

        return grouped

    def _spot_to_activity(
        self,
        spot: dict,
        time_slot: TimeSlot,
    ) -> ActivityNode:
        """
        将景区字典转换为 ActivityNode

        Args:
            spot: 景区数据字典
            time_slot: 时间段

        Returns:
            ActivityNode 对象
        """
        # 解析门票价格
        ticket_price = spot.get("ticket_price_num", 0)
        if ticket_price is None:
            price_str = str(spot.get("ticket_price", "0"))
            # 尝试从字符串中提取数字
            import re
            numbers = re.findall(r'(\d+)', price_str)
            ticket_price = int(numbers[0]) if numbers else 0

        # 解析建议游览时长
        duration_str = spot.get("suggested_duration", "2小时")
        import re
        hour_match = re.search(r'(\d+)', duration_str)
        duration_minutes = int(hour_match.group(1)) * 60 if hour_match else 120

        # 确定活动类型
        spot_type = spot.get("type", "")
        if "自然" in spot_type or "湖" in spot_type or "湿地" in spot_type or "溪" in spot_type:
            activity_type = ActivityType.SCENIC
        elif "博物馆" in spot_type or "文化" in spot_type:
            activity_type = ActivityType.CULTURE
        elif "历史" in spot_type or "古迹" in spot_type or "遗址" in spot_type:
            activity_type = ActivityType.CULTURE
        elif "乐园" in spot_type or "娱乐" in spot_type:
            activity_type = ActivityType.ENTERTAINMENT
        else:
            activity_type = ActivityType.SCENIC

        # 确定体力等级
        if "公园" in spot_type or "湿地" in spot_type or "山" in spot_type:
            energy = EnergyLevel.HIGH
        elif "博物馆" in spot_type or "故居" in spot_type:
            energy = EnergyLevel.LOW
        else:
            energy = EnergyLevel.MEDIUM

        # 提取区域
        address = spot.get("address", "")
        district = ""
        for d in ["西湖区", "上城区", "余杭区", "萧山区", "东城区", "西城区", "海淀区", "朝阳区", "延庆区", "通州区"]:
            if d in address:
                district = d
                break

        # 生成贴士
        tips = []
        if spot.get("tips"):
            tips.append(spot["tips"])
        if spot.get("ticket_note"):
            tips.append(spot["ticket_note"])
        if ticket_price == 0:
            tips.append("免费景点，无需购票")

        return ActivityNode(
            activity_id=f"spot_{hash(spot.get('name', '')) % 100000}",
            name=spot.get("name", "未知景点"),
            activity_type=activity_type,
            location=Location(
                name=spot.get("name", ""),
                address=address,
                lat=spot.get("latitude", 0),
                lng=spot.get("longitude", 0),
                district=district,
            ),
            time_slot=time_slot,
            duration_minutes=min(duration_minutes, int(time_slot.duration_hours * 60)),
            cost=ticket_price,
            description=spot.get("description", ""),
            tips=tips,
            energy_required=energy,
            rating=spot.get("rating"),
            booking_required="预约" in str(spot.get("ticket_price", "")) or "预约" in str(spot.get("tips", "")),
        )

    def _restaurant_to_activity(
        self,
        restaurant: dict,
        time_slot: TimeSlot,
        meal_type: str = "午餐",
    ) -> ActivityNode:
        """
        将餐厅字典转换为 ActivityNode

        Args:
            restaurant: 餐厅数据字典
            time_slot: 时间段
            meal_type: 餐次类型

        Returns:
            ActivityNode 对象
        """
        avg_price = restaurant.get("avg_price", 0)

        # 提取区域
        address = restaurant.get("address", "")
        district = ""
        for d in ["西湖区", "上城区", "余杭区", "萧山区", "东城区", "西城区", "海淀区", "朝阳区", "延庆区", "通州区"]:
            if d in address:
                district = d
                break

        # 生成描述
        cuisine = restaurant.get("cuisine", restaurant.get("cuisine_type", ""))
        description = f"{meal_type}推荐：{restaurant.get('name', '')}（{cuisine}）"
        if restaurant.get("description"):
            description += f" - {restaurant['description']}"

        # 生成贴士
        tips = []
        signature = restaurant.get("signature_dishes", "")
        if isinstance(signature, list):
            signature = "、".join(signature)
        if signature:
            tips.append(f"推荐菜品: {signature}")
        if restaurant.get("need_queue"):
            tips.append(f"注意: {restaurant.get('queue_note', '可能需要排队')}")
        if restaurant.get("open_hours"):
            tips.append(f"营业时间: {restaurant['open_hours']}")

        return ActivityNode(
            activity_id=f"food_{hash(restaurant.get('name', '')) % 100000}",
            name=f"{meal_type} - {restaurant.get('name', '')}",
            activity_type=ActivityType.FOOD,
            location=Location(
                name=restaurant.get("name", ""),
                address=address,
                lat=restaurant.get("latitude", 0),
                lng=restaurant.get("longitude", 0),
                district=district,
            ),
            time_slot=time_slot,
            duration_minutes=90,
            cost=avg_price,
            description=description,
            tips=tips,
            energy_required=EnergyLevel.LOW,
            rating=restaurant.get("rating"),
        )

    def _event_to_activity(
        self,
        event: dict,
        time_slot: TimeSlot,
    ) -> ActivityNode:
        """
        将演出字典转换为 ActivityNode

        Args:
            event: 演出数据字典
            time_slot: 时间段

        Returns:
            ActivityNode 对象
        """
        # 解析票价
        price_min = event.get("ticket_price_min", 0)
        price_max = event.get("ticket_price_max", 0)
        if price_max and price_max > 0:
            cost = (price_min + price_max) / 2
        else:
            cost = 0

        venue = event.get("venue", "")
        venue_address = event.get("venue_address", "")

        # 提取区域
        district = ""
        for d in ["西湖区", "上城区", "东城区", "西城区", "海淀区", "朝阳区", "通州区"]:
            if d in venue_address:
                district = d
                break

        tips = []
        show_time = event.get("show_time", "")
        if show_time:
            tips.append(f"演出时间: {show_time}")
        price_range = event.get("ticket_price_range", "")
        if price_range:
            tips.append(f"票价: {price_range}")

        return ActivityNode(
            activity_id=f"event_{hash(event.get('name', '')) % 100000}",
            name=event.get("name", ""),
            activity_type=ActivityType.ENTERTAINMENT,
            location=Location(
                name=venue,
                address=venue_address,
                lat=0,  # 演出场馆坐标暂不精确
                lng=0,
                district=district,
            ),
            time_slot=time_slot,
            duration_minutes=90,
            cost=cost,
            description=event.get("description", ""),
            tips=tips,
            energy_required=EnergyLevel.LOW,
            booking_required=True,
        )

    def _generate_transport_segments(
        self,
        activities: list[ActivityNode],
    ) -> list[TransportSegment]:
        """
        根据活动列表生成交通路段

        Args:
            activities: 活动列表

        Returns:
            交通路段列表
        """
        segments = []
        for i in range(len(activities) - 1):
            from_loc = activities[i].location
            to_loc = activities[i + 1].location

            # 计算两点间距离（简化：使用 Haversine 公式）
            distance = self._haversine_distance(
                from_loc.lat, from_loc.lng, to_loc.lat, to_loc.lng
            )

            # 根据距离选择交通方式
            if distance < 1000:
                mode = TransportMode.WALKING
                duration = max(10, int(distance / 80))  # 步行约80米/分钟
                cost = 0
            elif distance < 3000:
                mode = TransportMode.CYCLING
                duration = max(10, int(distance / 200))  # 骑行约200米/分钟
                cost = 3
            elif distance < 10000:
                mode = TransportMode.SUBWAY
                duration = max(15, int(distance / 500) + 10)  # 地铁含等车时间
                cost = 5
            else:
                mode = TransportMode.TAXI
                duration = max(20, int(distance / 400))  # 打车约400米/分钟
                cost = max(15, int(distance / 1000 * 3))

            segments.append(TransportSegment(
                from_location=from_loc,
                to_location=to_loc,
                mode=mode,
                duration_minutes=duration,
                cost=cost,
                distance_meters=distance,
                description=f"{from_loc.name} → {to_loc.name}（{mode.value}，约{duration}分钟）",
            ))

        return segments

    def _haversine_distance(
        self,
        lat1: float,
        lng1: float,
        lat2: float,
        lng2: float,
    ) -> float:
        """
        使用 Haversine 公式计算两点间距离（米）

        Args:
            lat1: 起点纬度
            lng1: 起点经度
            lat2: 终点纬度
            lng2: 终点经度

        Returns:
            距离（米）
        """
        if lat1 == 0 and lng1 == 0:
            return 2000  # 默认距离
        if lat2 == 0 and lng2 == 0:
            return 2000

        R = 6371000  # 地球半径（米）
        phi1 = math.radians(lat1)
        phi2 = math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lng2 - lng1)

        a = (
            math.sin(delta_phi / 2) ** 2
            + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
        )
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

        return R * c

    def _generate_tips(
        self,
        destination: str,
        weather: dict,
        preferences: list[str],
        budget_max: Optional[float],
    ) -> list[str]:
        """
        生成旅行贴士

        Args:
            destination: 目的地
            weather: 天气信息
            preferences: 用户偏好
            budget_max: 预算上限

        Returns:
            贴士列表
        """
        tips = []

        # 天气相关贴士
        if weather:
            travel_tips = weather.get("travel_tips", [])
            tips.extend(travel_tips[:3])

            clothing = weather.get("clothing_advice", {})
            if isinstance(clothing, dict):
                essential = clothing.get("essential", "")
                if essential:
                    tips.append(f"穿衣建议: {essential}")

        # 通用贴士
        tips.append("建议提前在官方平台预约热门景区门票，避免现场排队")
        tips.append("支付宝/微信可扫码乘坐地铁和公交，无需准备零钱")

        if budget_max and budget_max < 2000:
            tips.append(f"预算较紧凑，推荐选择免费景区和性价比高的本地餐厅")

        if preferences:
            pref_tips = {
                "文化": "杭州/北京博物馆资源丰富，建议安排半天参观浙江省博物馆/国家博物馆",
                "美食": "推荐体验本地特色小吃，河坊街/南锣鼓巷是觅食好去处",
                "自然": "西湖/颐和园建议清晨或傍晚前往，避开人流高峰",
                "摄影": "日出日落时分光线最佳，断桥/故宫角楼是经典机位",
            }
            for pref in preferences:
                if pref in pref_tips:
                    tips.append(pref_tips[pref])

        return tips[:8]  # 最多8条贴士

    def _generate_warnings(
        self,
        destination: str,
        weather: dict,
    ) -> list[str]:
        """
        生成注意事项/警告

        Args:
            destination: 目的地
            weather: 天气信息

        Returns:
            警告列表
        """
        warnings = []

        warnings.append("热门景区（故宫、灵隐寺等）需提前预约，请关注官方放票时间")
        warnings.append("景区周边周末和节假日交通拥堵，建议错峰出行")

        if weather:
            features = weather.get("weather_features", "") or weather.get("typical_weather", "")
            if "雨" in features:
                warnings.append("近期可能有雨，建议携带雨具，雨中游览别有韵味")
            if "沙尘" in features or "浮尘" in features:
                warnings.append("近期可能有沙尘天气，建议佩戴口罩")
            if "温差" in features or "温差" in str(weather.get("temperature_range", {})):
                warnings.append("昼夜温差较大，注意增减衣物")

        return warnings[:5]
