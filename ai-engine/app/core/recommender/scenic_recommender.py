"""
景区推荐引擎

基于景区类别、心情偏好、天气状况等因素推荐景区。
支持天气感知推荐，根据实时天气调整推荐策略。
"""

import logging
from typing import Optional

from app.models.activity import Activity, ActivityRecommendation

logger = logging.getLogger(__name__)


class ScenicRecommender:
    """
    景区推荐引擎

    综合考虑以下因素进行景区推荐：
    1. 类别匹配度：用户偏好的景区类别
    2. 心情适配度：根据用户当前心情推荐合适的景区类型
    3. 天气适配度：根据天气状况调整推荐策略
    4. 评分权重：景区的用户评分
    5. 距离权重：景区与用户位置的距离
    """

    # 景区类别与心情的适配矩阵
    MOOD_CATEGORY_MAP = {
        "放松": ["自然风光", "温泉", "公园", "湖泊", "海滩"],
        "冒险": ["户外运动", "探险", "攀岩", "漂流", "徒步"],
        "浪漫": ["古镇", "夜景", "花园", "湖畔", "海边"],
        "文化": ["历史古迹", "博物馆", "寺庙", "古镇", "艺术馆"],
        "亲子": ["主题乐园", "动物园", "水族馆", "科技馆", "公园"],
        "购物": ["商业街", "市场", "特产店", "购物中心"],
        "美食": ["美食街", "夜市", "特产", "农家乐"],
    }

    # 天气与景区类型的适配矩阵
    WEATHER_CATEGORY_MAP = {
        "晴": ["自然风光", "户外运动", "公园", "海滩", "徒步"],
        "多云": ["历史古迹", "博物馆", "古镇", "公园", "商业街"],
        "阴": ["博物馆", "艺术馆", "商业街", "美食街", "室内娱乐"],
        "小雨": ["博物馆", "艺术馆", "室内娱乐", "温泉", "咖啡馆"],
        "大雨": ["博物馆", "室内娱乐", "购物中心", "电影院"],
        "雪": ["温泉", "滑雪", "室内娱乐", "博物馆"],
        "高温": ["水上乐园", "室内娱乐", "博物馆", "夜游"],
        "低温": ["温泉", "博物馆", "室内娱乐", "美食"],
    }

    # 各维度权重
    WEIGHTS = {
        "category_match": 0.25,
        "mood_fit": 0.20,
        "weather_fit": 0.20,
        "rating": 0.20,
        "distance": 0.15,
    }

    def __init__(self):
        """初始化景区推荐引擎"""
        pass

    async def recommend(
        self,
        city: str,
        lat: Optional[float] = None,
        lng: Optional[float] = None,
        category: Optional[str] = None,
        mood: Optional[str] = None,
        weather: Optional[str] = None,
        limit: int = 10,
    ) -> list[ActivityRecommendation]:
        """
        推荐景区

        Args:
            city: 城市名称
            lat: 用户纬度
            lng: 用户经度
            category: 景区类别偏好
            mood: 心情偏好
            weather: 天气状况
            limit: 返回数量

        Returns:
            推荐景区列表
        """
        logger.info(
            f"景区推荐: city={city}, category={category}, "
            f"mood={mood}, weather={weather}"
        )

        # 如果没有天气信息，尝试获取实时天气
        if weather is None:
            weather = await self._fetch_weather(city)

        # 获取候选景区
        candidates = await self._get_candidates(city, lat, lng)

        if not candidates:
            logger.warning(f"未找到候选景区: city={city}")
            return []

        # 计算各维度评分
        scored_activities = []
        for activity in candidates:
            scores = self._calculate_scores(
                activity=activity,
                category=category,
                mood=mood,
                weather=weather,
                user_lat=lat,
                user_lng=lng,
            )

            total_score = sum(
                score * self.WEIGHTS[dim]
                for dim, score in scores.items()
            )

            scored_activities.append((activity, scores, total_score))

        # 按综合评分排序
        scored_activities.sort(key=lambda x: x[2], reverse=True)

        # 构建推荐结果
        results = []
        for activity, scores, total_score in scored_activities[:limit]:
            recommendation = ActivityRecommendation(
                activity=activity,
                match_score=round(total_score, 4),
                match_details=scores,
                reason=self._generate_reason(activity, scores, weather),
            )
            results.append(recommendation)

        logger.info(f"景区推荐完成: 返回{len(results)}个结果")
        return results

    def _calculate_scores(
        self,
        activity: Activity,
        category: Optional[str],
        mood: Optional[str],
        weather: Optional[str],
        user_lat: Optional[float],
        user_lng: Optional[float],
    ) -> dict[str, float]:
        """
        计算景区在各维度的评分

        Args:
            activity: 景区信息
            category: 类别偏好
            mood: 心情偏好
            weather: 天气状况
            user_lat: 用户纬度
            user_lng: 用户经度

        Returns:
            各维度评分字典
        """
        scores = {}

        scores["category_match"] = self._calc_category_match(activity, category)
        scores["mood_fit"] = self._calc_mood_fit(activity, mood)
        scores["weather_fit"] = self._calc_weather_fit(activity, weather)
        scores["rating"] = self._calc_rating_score(activity.rating)
        scores["distance"] = self._calc_distance_score(
            activity, user_lat, user_lng
        )

        return scores

    def _calc_category_match(
        self, activity: Activity, category: Optional[str]
    ) -> float:
        """
        计算类别匹配度

        Args:
            activity: 景区信息
            category: 用户偏好的类别

        Returns:
            匹配度（0-1）
        """
        if not category:
            return 0.5

        activity_categories = activity.categories or []
        if category in activity_categories:
            return 1.0

        # 模糊匹配：检查是否包含关键词
        for ac in activity_categories:
            if category in ac or ac in category:
                return 0.7

        return 0.2

    def _calc_mood_fit(self, activity: Activity, mood: Optional[str]) -> float:
        """
        计算心情适配度

        Args:
            activity: 景区信息
            mood: 用户心情

        Returns:
            适配度（0-1）
        """
        if not mood:
            return 0.5

        recommended_categories = self.MOOD_CATEGORY_MAP.get(mood, [])
        activity_categories = activity.categories or []

        for rc in recommended_categories:
            for ac in activity_categories:
                if rc in ac or ac in rc:
                    return 1.0

        return 0.3

    def _calc_weather_fit(self, activity: Activity, weather: Optional[str]) -> float:
        """
        计算天气适配度

        Args:
            activity: 景区信息
            weather: 天气状况

        Returns:
            适配度（0-1）
        """
        if not weather:
            return 0.5

        suitable_categories = self.WEATHER_CATEGORY_MAP.get(weather, [])
        activity_categories = activity.categories or []

        for sc in suitable_categories:
            for ac in activity_categories:
                if sc in ac or ac in sc:
                    return 1.0

        # 检查是否是室内场所（不受天气影响）
        indoor_keywords = ["室内", "博物馆", "艺术馆", "购物中心", "电影院"]
        for ac in activity_categories:
            for keyword in indoor_keywords:
                if keyword in ac:
                    return 0.8  # 室内场所天气影响小

        return 0.2

    def _calc_rating_score(self, rating: Optional[float]) -> float:
        """计算评分维度分数"""
        if rating is None:
            return 0.3
        return min(1.0, rating / 5.0)

    def _calc_distance_score(
        self,
        activity: Activity,
        user_lat: Optional[float],
        user_lng: Optional[float],
    ) -> float:
        """计算距离维度分数"""
        if user_lat is None or user_lng is None:
            return 0.5
        if activity.lat is None or activity.lng is None:
            return 0.3

        import math
        R = 6371000
        phi1, phi2 = math.radians(user_lat), math.radians(activity.lat)
        dphi = math.radians(activity.lat - user_lat)
        dlambda = math.radians(activity.lng - user_lng)
        a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlambda / 2) ** 2
        distance = R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

        max_distance = 20000  # 20公里
        if distance <= max_distance:
            return 1.0 - (distance / max_distance) * 0.7
        return max(0.0, 0.3 - (distance - max_distance) / 30000)

    def _generate_reason(
        self, activity: Activity, scores: dict, weather: Optional[str]
    ) -> str:
        """生成推荐理由"""
        reasons = []

        if scores.get("category_match", 0) > 0.7:
            reasons.append("符合您的兴趣偏好")
        if scores.get("mood_fit", 0) > 0.7:
            reasons.append("适合您当前的心情")
        if weather and scores.get("weather_fit", 0) > 0.7:
            reasons.append(f"当前{weather}天非常适合游览")
        elif weather and scores.get("weather_fit", 0) < 0.3:
            reasons.append(f"注意：当前{weather}天可能影响游览体验")
        if scores.get("rating", 0) > 0.8:
            reasons.append(f"评分{activity.rating}分，值得推荐")

        return "；".join(reasons) if reasons else "综合推荐"

    async def _fetch_weather(self, city: str) -> Optional[str]:
        """
        获取城市实时天气

        Args:
            city: 城市名称

        Returns:
            天气描述
        """
        try:
            from app.services.weather_service import WeatherService

            service = WeatherService()
            weather_data = await service.get_current_weather(city)
            return weather_data.get("text") if weather_data else None
        except Exception as e:
            logger.warning(f"获取天气失败: {e}")
            return None

    async def _get_candidates(
        self,
        city: str,
        lat: Optional[float],
        lng: Optional[float],
    ) -> list[Activity]:
        """
        获取候选景区列表

        Args:
            city: 城市名称
            lat: 纬度
            lng: 经度

        Returns:
            候选景区列表
        """
        # 尝试从知识库检索
        try:
            from app.core.rag.retriever import HybridRetriever

            retriever = HybridRetriever()
            results = await retriever.retrieve(
                query=f"{city} 景点 景区推荐",
                collection_name="scenic_spots",
                top_k=50,
            )
            candidates = []
            for result in results:
                activity = Activity(
                    name=result.get("name", ""),
                    activity_type="scenic",
                    categories=result.get("categories", []),
                    rating=result.get("rating"),
                    lat=result.get("lat"),
                    lng=result.get("lng"),
                    address=result.get("address", ""),
                    description=result.get("description", ""),
                    ticket_price=result.get("ticket_price"),
                    open_hours=result.get("open_hours", ""),
                    tags=result.get("tags", []),
                )
                candidates.append(activity)
            return candidates

        except Exception as e:
            logger.warning(f"知识库检索失败: {e}")

        # 从外部API获取
        try:
            from app.services.amap_service import AmapService

            service = AmapService()
            pois = await service.search_pois(
                keywords="旅游景点",
                city=city,
                lat=lat,
                lng=lng,
            )
            candidates = []
            for poi in pois:
                activity = Activity(
                    name=poi.get("name", ""),
                    activity_type="scenic",
                    categories=[poi.get("type", "")],
                    rating=poi.get("rating"),
                    lat=poi.get("lat"),
                    lng=poi.get("lng"),
                    address=poi.get("address", ""),
                    description=poi.get("description", ""),
                )
                candidates.append(activity)
            return candidates

        except Exception as e:
            logger.error(f"外部API获取景区失败: {e}")
            return []
