"""
混合推荐框架

整合协同过滤和内容推荐的混合推荐引擎。
支持多种推荐策略的组合和权重调整。
"""

import logging
from typing import Optional

from app.models.activity import ActivityRecommendation
from app.models.restaurant import RestaurantRecommendation

logger = logging.getLogger(__name__)


class HybridRecommender:
    """
    混合推荐框架

    组合多种推荐策略：
    1. 基于内容的推荐（CB）：根据物品特征和用户偏好匹配
    2. 协同过滤推荐（CF）：根据相似用户的行为推荐
    3. 知识图谱推荐（KG）：基于领域知识的推理推荐
    4. 上下文感知推荐（CA）：根据时间、天气、位置等上下文调整

    混合策略：
    - 加权混合：对多种推荐结果加权融合
    - 级联过滤：先用一种策略粗筛，再用另一种精排
    - 特征组合：将多种策略的特征输入统一模型
    """

    # 推荐策略权重
    STRATEGY_WEIGHTS = {
        "content_based": 0.40,    # 基于内容
        "collaborative": 0.25,    # 协同过滤
        "knowledge_based": 0.20,  # 知识图谱
        "context_aware": 0.15,    # 上下文感知
    }

    def __init__(self):
        """初始化混合推荐引擎"""
        self._food_recommender = None
        self._scenic_recommender = None

    async def recommend(
        self,
        city: str,
        lat: Optional[float] = None,
        lng: Optional[float] = None,
        time_slot: str = "afternoon",
        energy_level: int = 5,
        limit: int = 10,
    ) -> dict:
        """
        综合推荐

        根据时间段、体力等级等上下文信息，
        综合推荐适合的美食和景区。

        Args:
            city: 城市名称
            lat: 纬度
            lng: 经度
            time_slot: 时间段 (morning/afternoon/evening)
            energy_level: 体力等级 (1-10)
            limit: 返回数量

        Returns:
            包含美食和景区的综合推荐结果
        """
        logger.info(
            f"综合推荐: city={city}, time_slot={time_slot}, energy={energy_level}"
        )

        # 根据时间段确定推荐类型
        recommendations = {
            "food": [],
            "scenic": [],
            "suggestions": [],
        }

        # 根据时间段和体力等级调整推荐策略
        context = self._build_context(time_slot, energy_level)

        # 1. 美食推荐
        food_results = await self._recommend_food(
            city=city,
            lat=lat,
            lng=lng,
            time_slot=time_slot,
            energy_level=energy_level,
            limit=limit,
        )
        recommendations["food"] = [
            r.model_dump() for r in food_results
        ]

        # 2. 景区推荐
        scenic_results = await self._recommend_scenic(
            city=city,
            lat=lat,
            lng=lng,
            time_slot=time_slot,
            energy_level=energy_level,
            limit=limit,
        )
        recommendations["scenic"] = [
            r.model_dump() for r in scenic_results
        ]

        # 3. 生成综合建议
        recommendations["suggestions"] = self._generate_suggestions(
            time_slot, energy_level, food_results, scenic_results
        )

        return recommendations

    async def _recommend_food(
        self,
        city: str,
        lat: Optional[float],
        lng: Optional[float],
        time_slot: str,
        energy_level: int,
        limit: int,
    ) -> list[RestaurantRecommendation]:
        """
        上下文感知的美食推荐

        Args:
            city: 城市
            lat: 纬度
            lng: 经度
            time_slot: 时间段
            energy_level: 体力等级
            limit: 数量

        Returns:
            美食推荐列表
        """
        from app.core.recommender.food_recommender import FoodRecommender

        recommender = FoodRecommender()

        # 根据时间段调整口味偏好
        taste_map = {
            "morning": "清淡,早餐",
            "afternoon": "特色,小吃",
            "evening": "正餐,特色",
        }
        taste = taste_map.get(time_slot)

        # 根据体力等级调整预算
        budget_map = {
            "low_energy": (20, 80),     # 体力低时选择舒适餐厅
            "medium_energy": (30, 150),
            "high_energy": (10, 100),   # 体力高时随意
        }
        if energy_level <= 3:
            budget_range = budget_map["low_energy"]
        elif energy_level <= 7:
            budget_range = budget_map["medium_energy"]
        else:
            budget_range = budget_map["high_energy"]

        return await recommender.recommend(
            city=city,
            lat=lat,
            lng=lng,
            taste_preference=taste,
            budget_min=budget_range[0],
            budget_max=budget_range[1],
            limit=limit,
        )

    async def _recommend_scenic(
        self,
        city: str,
        lat: Optional[float],
        lng: Optional[float],
        time_slot: str,
        energy_level: int,
        limit: int,
    ) -> list[ActivityRecommendation]:
        """
        上下文感知的景区推荐

        Args:
            city: 城市
            lat: 纬度
            lng: 经度
            time_slot: 时间段
            energy_level: 体力等级
            limit: 数量

        Returns:
            景区推荐列表
        """
        from app.core.recommender.scenic_recommender import ScenicRecommender

        recommender = ScenicRecommender()

        # 根据时间段调整心情
        mood_map = {
            "morning": "文化",
            "afternoon": "放松",
            "evening": "浪漫",
        }
        mood = mood_map.get(time_slot)

        # 根据体力等级过滤景区类型
        if energy_level <= 3:
            category = "博物馆,商业街,美食街"  # 低体力选择轻松的
        elif energy_level <= 7:
            category = None  # 中等体力不限制
        else:
            category = "户外运动,徒步,探险"  # 高体力选择挑战性的

        return await recommender.recommend(
            city=city,
            lat=lat,
            lng=lng,
            category=category,
            mood=mood,
            limit=limit,
        )

    def _build_context(self, time_slot: str, energy_level: int) -> dict:
        """
        构建推荐上下文

        Args:
            time_slot: 时间段
            energy_level: 体力等级

        Returns:
            上下文字典
        """
        return {
            "time_slot": time_slot,
            "energy_level": energy_level,
            "energy_category": (
                "low" if energy_level <= 3
                else "medium" if energy_level <= 7
                else "high"
            ),
        }

    def _generate_suggestions(
        self,
        time_slot: str,
        energy_level: int,
        food_results: list,
        scenic_results: list,
    ) -> list[str]:
        """
        生成综合建议

        Args:
            time_slot: 时间段
            energy_level: 体力等级
            food_results: 美食推荐结果
            scenic_results: 景区推荐结果

        Returns:
            建议列表
        """
        suggestions = []

        # 基于时间段的建议
        if time_slot == "morning":
            suggestions.append("上午适合安排文化类景点，避开人流高峰")
        elif time_slot == "afternoon":
            suggestions.append("下午可以选择户外活动或休闲体验")
        elif time_slot == "evening":
            suggestions.append("傍晚推荐夜景、美食街或文化演出")

        # 基于体力等级的建议
        if energy_level <= 3:
            suggestions.append("当前体力较低，建议安排轻松的室内活动")
            suggestions.append("推荐选择交通便利的餐厅，减少步行距离")
        elif energy_level >= 8:
            suggestions.append("体力充沛，可以安排更多户外探索活动")

        # 基于推荐结果的建议
        if food_results:
            top_food = food_results[0]
            if top_food.get("match_score", 0) > 0.8:
                suggestions.append(f"强烈推荐: {top_food['restaurant']['name']}")

        if scenic_results:
            top_scenic = scenic_results[0]
            if top_scenic.get("match_score", 0) > 0.8:
                suggestions.append(f"热门景点: {top_scenic['activity']['name']}")

        return suggestions
