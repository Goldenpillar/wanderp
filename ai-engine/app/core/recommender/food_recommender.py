"""
美食推荐引擎

基于口味匹配、预算适配、距离排序等多维度因素推荐餐厅。
支持基于用户历史偏好的个性化推荐。
"""

import logging
import math
from typing import Optional

from app.models.restaurant import Restaurant, RestaurantRecommendation

logger = logging.getLogger(__name__)


class FoodRecommender:
    """
    美食推荐引擎

    综合考虑以下因素进行餐厅推荐：
    1. 口味匹配度：用户口味偏好与餐厅菜系的匹配程度
    2. 预算适配度：餐厅人均消费与用户预算的匹配程度
    3. 距离排序：餐厅与用户当前位置的距离
    4. 评分权重：餐厅的用户评分
    5. 热度权重：餐厅的受欢迎程度
    """

    # 各维度权重
    WEIGHTS = {
        "taste_match": 0.30,     # 口味匹配权重
        "budget_fit": 0.20,      # 预算适配权重
        "distance": 0.20,        # 距离权重
        "rating": 0.20,          # 评分权重
        "popularity": 0.10,      # 热度权重
    }

    # 菜系到口味标签的映射
    CUISINE_TASTE_MAP = {
        "川菜": ["辣", "麻", "香"],
        "粤菜": ["清淡", "鲜", "甜"],
        "湘菜": ["辣", "酸", "香"],
        "鲁菜": ["咸", "鲜", "香"],
        "苏菜": ["甜", "鲜", "清淡"],
        "浙菜": ["鲜", "清淡", "甜"],
        "闽菜": ["鲜", "清淡", "甜"],
        "徽菜": ["咸", "鲜", "香"],
        "日料": ["清淡", "鲜", "精致"],
        "韩餐": ["辣", "甜", "烤"],
        "西餐": ["清淡", "精致", "奶油"],
        "火锅": ["辣", "麻", "热"],
        "烧烤": ["辣", "香", "烤"],
        "小吃": ["香", "地道", "实惠"],
        "甜品": ["甜", "精致"],
        "素食": ["清淡", "健康"],
    }

    def __init__(self):
        """初始化美食推荐引擎"""
        pass

    async def recommend(
        self,
        city: str,
        lat: Optional[float] = None,
        lng: Optional[float] = None,
        taste_preference: Optional[str] = None,
        budget_min: Optional[float] = None,
        budget_max: Optional[float] = None,
        radius: float = 5000,
        limit: int = 10,
    ) -> list[RestaurantRecommendation]:
        """
        推荐餐厅

        Args:
            city: 城市名称
            lat: 用户纬度
            lng: 用户经度
            taste_preference: 口味偏好
            budget_min: 最低人均预算
            budget_max: 最高人均预算
            radius: 搜索半径(米)
            limit: 返回数量

        Returns:
            推荐餐厅列表
        """
        logger.info(
            f"美食推荐: city={city}, taste={taste_preference}, "
            f"budget=[{budget_min}, {budget_max}], radius={radius}"
        )

        # 1. 获取候选餐厅（从知识库或外部API）
        candidates = await self._get_candidates(city, lat, lng, radius)

        if not candidates:
            logger.warning(f"未找到候选餐厅: city={city}")
            return []

        # 2. 计算各维度评分
        scored_restaurants = []
        for restaurant in candidates:
            scores = self._calculate_scores(
                restaurant=restaurant,
                taste_preference=taste_preference,
                budget_min=budget_min,
                budget_max=budget_max,
                user_lat=lat,
                user_lng=lng,
            )

            # 计算综合评分
            total_score = sum(
                score * self.WEIGHTS[dim]
                for dim, score in scores.items()
            )

            scored_restaurants.append((restaurant, scores, total_score))

        # 3. 按综合评分排序
        scored_restaurants.sort(key=lambda x: x[2], reverse=True)

        # 4. 构建推荐结果
        results = []
        for restaurant, scores, total_score in scored_restaurants[:limit]:
            recommendation = RestaurantRecommendation(
                restaurant=restaurant,
                match_score=round(total_score, 4),
                match_details=scores,
                reason=self._generate_reason(restaurant, scores),
            )
            results.append(recommendation)

        logger.info(f"美食推荐完成: 返回{len(results)}个结果")
        return results

    def _calculate_scores(
        self,
        restaurant: Restaurant,
        taste_preference: Optional[str],
        budget_min: Optional[float],
        budget_max: Optional[float],
        user_lat: Optional[float],
        user_lng: Optional[float],
    ) -> dict[str, float]:
        """
        计算餐厅在各维度的评分

        Args:
            restaurant: 餐厅信息
            taste_preference: 口味偏好
            budget_min: 最低预算
            budget_max: 最高预算
            user_lat: 用户纬度
            user_lng: 用户经度

        Returns:
            各维度评分字典（0-1）
        """
        scores = {}

        # 口味匹配度
        scores["taste_match"] = self._calc_taste_match(restaurant, taste_preference)

        # 预算适配度
        scores["budget_fit"] = self._calc_budget_fit(
            restaurant.avg_price, budget_min, budget_max
        )

        # 距离评分
        scores["distance"] = self._calc_distance_score(
            restaurant, user_lat, user_lng
        )

        # 评分
        scores["rating"] = self._calc_rating_score(restaurant.rating)

        # 热度
        scores["popularity"] = self._calc_popularity_score(restaurant.review_count)

        return scores

    def _calc_taste_match(
        self, restaurant: Restaurant, taste_preference: Optional[str]
    ) -> float:
        """
        计算口味匹配度

        Args:
            restaurant: 餐厅信息
            taste_preference: 用户口味偏好

        Returns:
            匹配度评分（0-1）
        """
        if not taste_preference:
            return 0.5  # 无偏好时返回中性分数

        # 获取餐厅菜系对应的口味标签
        restaurant_tastes = self.CUISINE_TASTE_MAP.get(
            restaurant.cuisine, [restaurant.cuisine]
        )

        # 计算用户偏好与餐厅口味的重叠度
        user_tastes = [t.strip() for t in taste_preference.split(",")]
        overlap = set(user_tastes) & set(restaurant_tastes)

        if overlap:
            return min(1.0, len(overlap) / max(len(user_tastes), 1))
        return 0.2  # 无重叠时给一个基础分

    def _calc_budget_fit(
        self,
        avg_price: float,
        budget_min: Optional[float],
        budget_max: Optional[float],
    ) -> float:
        """
        计算预算适配度

        Args:
            avg_price: 餐厅人均价格
            budget_min: 最低预算
            budget_max: 最高预算

        Returns:
            适配度评分（0-1）
        """
        if not budget_max:
            return 0.5  # 无预算限制时返回中性分数

        if budget_min and avg_price < budget_min:
            # 低于最低预算，适配度较低
            return max(0.0, 1.0 - (budget_min - avg_price) / budget_min)

        if avg_price <= budget_max:
            # 在预算范围内，越接近预算中点越好
            if budget_min:
                midpoint = (budget_min + budget_max) / 2
                deviation = abs(avg_price - midpoint) / (budget_max - budget_min)
                return max(0.5, 1.0 - deviation)
            return 0.8

        # 超出预算，适配度随超出比例降低
        over_ratio = (avg_price - budget_max) / budget_max
        return max(0.0, 1.0 - over_ratio * 2)

    def _calc_distance_score(
        self,
        restaurant: Restaurant,
        user_lat: Optional[float],
        user_lng: Optional[float],
    ) -> float:
        """
        计算距离评分

        Args:
            restaurant: 餐厅信息
            user_lat: 用户纬度
            user_lng: 用户经度

        Returns:
            距离评分（0-1）
        """
        if user_lat is None or user_lng is None:
            return 0.5  # 无位置信息时返回中性分数

        if restaurant.lat is None or restaurant.lng is None:
            return 0.3

        # 计算Haversine距离
        distance = self._haversine_distance(
            user_lat, user_lng, restaurant.lat, restaurant.lng
        )

        # 距离越近评分越高（5公里内线性衰减）
        max_distance = 5000  # 5公里
        if distance <= max_distance:
            return 1.0 - (distance / max_distance) * 0.7
        return max(0.0, 0.3 - (distance - max_distance) / 10000)

    def _calc_rating_score(self, rating: Optional[float]) -> float:
        """
        计算评分维度分数

        Args:
            rating: 餐厅评分

        Returns:
            评分分数（0-1）
        """
        if rating is None:
            return 0.3
        return min(1.0, rating / 5.0)

    def _calc_popularity_score(self, review_count: Optional[int]) -> float:
        """
        计算热度维度分数

        Args:
            review_count: 评论数量

        Returns:
            热度分数（0-1）
        """
        if review_count is None:
            return 0.3
        # 使用对数缩放，避免评论数量极大时主导评分
        import math
        return min(1.0, math.log10(max(review_count, 1) + 1) / 4.0)

    @staticmethod
    def _haversine_distance(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
        """
        计算两点之间的Haversine距离（米）

        Args:
            lat1: 起点纬度
            lng1: 起点经度
            lat2: 终点纬度
            lng2: 终点经度

        Returns:
            距离（米）
        """
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

    def _generate_reason(self, restaurant: Restaurant, scores: dict) -> str:
        """
        生成推荐理由

        Args:
            restaurant: 餐厅信息
            scores: 各维度评分

        Returns:
            推荐理由文本
        """
        reasons = []

        if scores.get("taste_match", 0) > 0.7:
            reasons.append(f"符合您的口味偏好")
        if scores.get("budget_fit", 0) > 0.7:
            reasons.append(f"人均{restaurant.avg_price}元，预算友好")
        if scores.get("rating", 0) > 0.8:
            reasons.append(f"评分{restaurant.rating}分，口碑优秀")
        if scores.get("popularity", 0) > 0.7:
            reasons.append(f"已有{restaurant.review_count}条评价，人气很高")

        if not reasons:
            reasons.append("综合推荐")

        return "；".join(reasons)

    async def _get_candidates(
        self,
        city: str,
        lat: Optional[float],
        lng: Optional[float],
        radius: float,
    ) -> list[Restaurant]:
        """
        获取候选餐厅列表

        优先从知识库检索，其次从外部API获取。

        Args:
            city: 城市名称
            lat: 纬度
            lng: 经度
            radius: 搜索半径

        Returns:
            候选餐厅列表
        """
        # 尝试从知识库检索
        try:
            from app.core.rag.retriever import HybridRetriever

            retriever = HybridRetriever()
            results = await retriever.retrieve(
                query=f"{city} 美食 餐厅推荐",
                collection_name="restaurants",
                top_k=50,
            )
            # 将检索结果转换为餐厅对象
            candidates = []
            for result in results:
                restaurant = Restaurant(
                    name=result.get("name", ""),
                    cuisine=result.get("cuisine", ""),
                    avg_price=result.get("avg_price", 0),
                    rating=result.get("rating"),
                    lat=result.get("lat"),
                    lng=result.get("lng"),
                    address=result.get("address", ""),
                    review_count=result.get("review_count"),
                    tags=result.get("tags", []),
                    description=result.get("description", ""),
                )
                candidates.append(restaurant)
            return candidates

        except Exception as e:
            logger.warning(f"知识库检索失败，尝试外部API: {e}")

        # 从外部API获取
        try:
            from app.services.juhe_service import JuheService

            service = JuheService()
            restaurants = await service.search_restaurants(
                city=city, lat=lat, lng=lng, radius=radius
            )
            return restaurants

        except Exception as e:
            logger.error(f"外部API获取餐厅失败: {e}")
            return []
