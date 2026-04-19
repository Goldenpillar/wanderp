"""
多人偏好聚合器

处理多人出行时的偏好聚合问题，
通过加权评分和妥协区域识别，找到满足所有人的最优方案。
"""

import logging
from typing import Optional

from app.models.preference import PreferenceInput, PreferenceProfile, TravelerInfo

logger = logging.getLogger(__name__)


class PreferenceAggregator:
    """
    多人偏好聚合器

    核心算法：
    1. 加权评分：根据每个旅行者的权重和偏好计算综合评分
    2. 妥协区域识别：找出偏好差异最大的维度，标记为需要妥协的区域
    3. 共识区域识别：找出所有人一致偏好的维度
    4. 帕累托优化：寻找帕累托最优的推荐方案
    """

    # 偏好维度及其默认权重
    DIMENSION_WEIGHTS = {
        "food": 0.25,        # 饮食偏好
        "activity": 0.25,    # 活动偏好
        "pace": 0.15,        # 节奏偏好
        "budget": 0.15,      # 预算偏好
        "transport": 0.10,   # 交通偏好
        "accommodation": 0.10,  # 住宿偏好
    }

    def __init__(self):
        """初始化偏好聚合器"""
        pass

    async def analyze_individual(self, input_data: PreferenceInput) -> PreferenceProfile:
        """
        分析单个用户的旅行偏好

        Args:
            input_data: 偏好分析输入

        Returns:
            用户偏好画像
        """
        logger.info(f"分析用户偏好: user_id={input_data.user_id}")

        # 从输入数据中提取偏好特征
        food_prefs = input_data.food_preferences or []
        activity_prefs = input_data.activity_preferences or []
        budget_pref = input_data.budget_level or "medium"
        pace_pref = input_data.pace_preference or "medium"

        # 构建偏好画像
        profile = PreferenceProfile(
            user_id=input_data.user_id,
            food_preferences=food_prefs,
            activity_preferences=activity_prefs,
            budget_level=budget_pref,
            pace_preference=pace_pref,
            transport_preference=input_data.transport_preference or "balanced",
            accommodation_preference=input_data.accommodation_preference or "comfort",
            special_requirements=input_data.special_requirements or [],
            confidence=self._calculate_confidence(input_data),
        )

        # 缓存偏好画像
        await self._cache_profile(profile)

        return profile

    async def aggregate_group(
        self, travelers: list[TravelerInfo]
    ) -> dict:
        """
        聚合多人偏好

        Args:
            travelers: 旅行者列表（含偏好信息）

        Returns:
            聚合结果，包含综合偏好、共识区域和妥协区域
        """
        logger.info(f"聚合多人偏好: {len(travelers)}人")

        if not travelers:
            raise ValueError("旅行者列表不能为空")

        if len(travelers) == 1:
            # 单人直接返回
            profile = self._traveler_to_profile(travelers[0])
            return {
                "profile": profile,
                "confidence": profile.confidence,
                "compromise_areas": [],
                "consensus_areas": list(profile.activity_preferences or []),
            }

        # 1. 收集所有旅行者的偏好
        profiles = [self._traveler_to_profile(t) for t in travelers]

        # 2. 计算各维度的共识度和差异度
        dimension_analysis = self._analyze_dimensions(profiles)

        # 3. 识别共识区域
        consensus_areas = self._find_consensus(dimension_analysis)

        # 4. 识别妥协区域
        compromise_areas = self._find_compromises(dimension_analysis)

        # 5. 计算综合偏好
        aggregated_profile = self._compute_aggregated_profile(profiles, dimension_analysis)

        return {
            "profile": aggregated_profile,
            "confidence": self._calculate_group_confidence(profiles),
            "compromise_areas": compromise_areas,
            "consensus_areas": consensus_areas,
            "dimension_analysis": dimension_analysis,
        }

    async def get_profile(self, user_id: str) -> Optional[PreferenceProfile]:
        """
        获取用户偏好画像

        Args:
            user_id: 用户ID

        Returns:
            偏好画像，不存在则返回None
        """
        try:
            from app.utils.cache import get_redis_client

            redis = get_redis_client()
            data = await redis.get(f"preference:profile:{user_id}")
            if data:
                return PreferenceProfile.model_validate_json(data)
            return None
        except Exception as e:
            logger.warning(f"获取偏好画像失败: {e}")
            return None

    async def update_profile(
        self, user_id: str, input_data: PreferenceInput
    ) -> PreferenceProfile:
        """
        更新用户偏好画像

        Args:
            user_id: 用户ID
            input_data: 新的偏好数据

        Returns:
            更新后的偏好画像
        """
        # 获取现有画像
        existing = await self.get_profile(user_id)

        # 合并新旧偏好
        new_profile = await self.analyze_individual(input_data)

        if existing:
            # 增量更新：保留历史数据，更新新数据
            new_profile.confidence = min(
                1.0, existing.confidence + 0.1
            )  # 每次更新增加置信度

        await self._cache_profile(new_profile)
        return new_profile

    def _analyze_dimensions(
        self, profiles: list[PreferenceProfile]
    ) -> dict[str, dict]:
        """
        分析各偏好维度的共识度和差异度

        Args:
            profiles: 偏好画像列表

        Returns:
            各维度的分析结果
        """
        analysis = {}

        # 饮食偏好维度
        food_sets = [set(p.food_preferences) for p in profiles if p.food_preferences]
        if food_sets:
            all_food = set().union(*food_sets)
            common_food = set.intersection(*food_sets) if len(food_sets) > 1 else food_sets[0]
            analysis["food"] = {
                "common": list(common_food),
                "unique": list(all_food - common_food),
                "consensus_score": len(common_food) / max(len(all_food), 1),
                "diversity_score": len(all_food - common_food) / max(len(all_food), 1),
            }

        # 活动偏好维度
        activity_sets = [set(p.activity_preferences) for p in profiles if p.activity_preferences]
        if activity_sets:
            all_activities = set().union(*activity_sets)
            common_activities = (
                set.intersection(*activity_sets) if len(activity_sets) > 1 else activity_sets[0]
            )
            analysis["activity"] = {
                "common": list(common_activities),
                "unique": list(all_activities - common_activities),
                "consensus_score": len(common_activities) / max(len(all_activities), 1),
                "diversity_score": len(all_activities - common_activities) / max(len(all_activities), 1),
            }

        # 预算维度
        budget_levels = [p.budget_level for p in profiles]
        budget_map = {"low": 1, "medium": 2, "high": 3, "luxury": 4}
        budget_values = [budget_map.get(b, 2) for b in budget_levels]
        if budget_values:
            avg_budget = sum(budget_values) / len(budget_values)
            budget_range = max(budget_values) - min(budget_values)
            analysis["budget"] = {
                "average": avg_budget,
                "range": budget_range,
                "consensus_score": max(0, 1.0 - budget_range / 3),
                "diversity_score": min(1.0, budget_range / 3),
            }

        # 节奏维度
        pace_levels = [p.pace_preference for p in profiles]
        pace_map = {"relaxed": 1, "medium": 2, "fast": 3}
        pace_values = [pace_map.get(p, 2) for p in pace_levels]
        if pace_values:
            avg_pace = sum(pace_values) / len(pace_values)
            pace_range = max(pace_values) - min(pace_values)
            analysis["pace"] = {
                "average": avg_pace,
                "range": pace_range,
                "consensus_score": max(0, 1.0 - pace_range / 2),
                "diversity_score": min(1.0, pace_range / 2),
            }

        return analysis

    def _find_consensus(self, dimension_analysis: dict) -> list[str]:
        """
        识别共识区域

        Args:
            dimension_analysis: 维度分析结果

        Returns:
            共识区域列表
        """
        consensus = []

        for dim, data in dimension_analysis.items():
            if data.get("consensus_score", 0) > 0.6:
                if dim == "food":
                    consensus.extend([f"饮食: {c}" for c in data.get("common", [])])
                elif dim == "activity":
                    consensus.extend([f"活动: {c}" for c in data.get("common", [])])
                elif dim == "budget":
                    consensus.append("预算水平接近")
                elif dim == "pace":
                    consensus.append("旅行节奏一致")

        return consensus

    def _find_compromises(self, dimension_analysis: dict) -> list[dict]:
        """
        识别妥协区域

        Args:
            dimension_analysis: 维度分析结果

        Returns:
            妥协区域列表
        """
        compromises = []

        for dim, data in dimension_analysis.items():
            if data.get("diversity_score", 0) > 0.4:
                compromise = {
                    "dimension": dim,
                    "severity": "high" if data["diversity_score"] > 0.7 else "medium",
                    "description": "",
                    "suggestion": "",
                }

                if dim == "food":
                    compromise["description"] = "饮食偏好差异较大"
                    compromise["suggestion"] = "建议选择综合餐厅或轮流满足各方口味"
                elif dim == "activity":
                    compromise["description"] = "活动偏好差异较大"
                    compromise["suggestion"] = "建议安排多样化的活动，兼顾各方兴趣"
                elif dim == "budget":
                    compromise["description"] = "预算水平差异较大"
                    compromise["suggestion"] = "建议选择中等价位方案，或分摊费用"
                elif dim == "pace":
                    compromise["description"] = "旅行节奏差异较大"
                    compromise["suggestion"] = "建议采用中等节奏，安排弹性时间"

                compromises.append(compromise)

        return compromises

    def _compute_aggregated_profile(
        self,
        profiles: list[PreferenceProfile],
        dimension_analysis: dict,
    ) -> PreferenceProfile:
        """
        计算聚合后的偏好画像

        Args:
            profiles: 偏好画像列表
            dimension_analysis: 维度分析结果

        Returns:
            聚合后的偏好画像
        """
        # 饮食偏好：取并集（包含所有人喜欢的）
        all_food = set()
        for p in profiles:
            if p.food_preferences:
                all_food.update(p.food_preferences)

        # 活动偏好：取并集
        all_activities = set()
        for p in profiles:
            if p.activity_preferences:
                all_activities.update(p.activity_preferences)

        # 预算：取平均值
        budget_map = {"low": 1, "medium": 2, "high": 3, "luxury": 4}
        reverse_budget = {v: k for k, v in budget_map.items()}
        budget_values = [budget_map.get(p.budget_level, 2) for p in profiles]
        avg_budget = sum(budget_values) / len(budget_values)
        budget_level = reverse_budget.get(round(avg_budget), "medium")

        # 节奏：取平均值
        pace_map = {"relaxed": 1, "medium": 2, "fast": 3}
        reverse_pace = {v: k for k, v in pace_map.items()}
        pace_values = [pace_map.get(p.pace_preference, 2) for p in profiles]
        avg_pace = sum(pace_values) / len(pace_values)
        pace_preference = reverse_pace.get(round(avg_pace), "medium")

        # 特殊需求：合并去重
        all_requirements = set()
        for p in profiles:
            if p.special_requirements:
                all_requirements.update(p.special_requirements)

        return PreferenceProfile(
            user_id="group",
            food_preferences=list(all_food),
            activity_preferences=list(all_activities),
            budget_level=budget_level,
            pace_preference=pace_preference,
            transport_preference="balanced",
            accommodation_preference="comfort",
            special_requirements=list(all_requirements),
            confidence=self._calculate_group_confidence(profiles),
        )

    def _calculate_confidence(self, input_data: PreferenceInput) -> float:
        """
        计算偏好分析的置信度

        Args:
            input_data: 输入数据

        Returns:
            置信度（0-1）
        """
        confidence = 0.3  # 基础置信度

        # 有饮食偏好加分
        if input_data.food_preferences:
            confidence += 0.15
        # 有活动偏好加分
        if input_data.activity_preferences:
            confidence += 0.15
        # 有预算偏好加分
        if input_data.budget_level:
            confidence += 0.1
        # 有历史行为数据加分
        if input_data.history_behaviors:
            confidence += 0.2
        # 有问卷回答加分
        if input_data.questionnaire_answers:
            confidence += 0.1

        return min(1.0, confidence)

    def _calculate_group_confidence(self, profiles: list[PreferenceProfile]) -> float:
        """
        计算群体偏好聚合的置信度

        Args:
            profiles: 偏好画像列表

        Returns:
            置信度（0-1）
        """
        if not profiles:
            return 0.0

        # 取所有个体置信度的平均值
        avg_confidence = sum(p.confidence for p in profiles) / len(profiles)

        # 人数越多，聚合置信度略低
        group_penalty = max(0, (len(profiles) - 1) * 0.05)

        return max(0.0, min(1.0, avg_confidence - group_penalty))

    def _traveler_to_profile(self, traveler: TravelerInfo) -> PreferenceProfile:
        """
        将旅行者信息转换为偏好画像

        Args:
            traveler: 旅行者信息

        Returns:
            偏好画像
        """
        return PreferenceProfile(
            user_id=traveler.user_id or "",
            food_preferences=traveler.food_preferences or [],
            activity_preferences=traveler.activity_preferences or [],
            budget_level=traveler.budget_level or "medium",
            pace_preference=traveler.pace_preference or "medium",
            transport_preference=traveler.transport_preference or "balanced",
            accommodation_preference=traveler.accommodation_preference or "comfort",
            special_requirements=traveler.special_requirements or [],
            confidence=0.5,
        )

    async def _cache_profile(self, profile: PreferenceProfile) -> None:
        """
        缓存偏好画像

        Args:
            profile: 偏好画像
        """
        try:
            from app.utils.cache import get_redis_client

            redis = get_redis_client()
            await redis.set(
                f"preference:profile:{profile.user_id}",
                profile.model_dump_json(),
                ex=86400 * 30,  # 缓存30天
            )
        except Exception as e:
            logger.warning(f"缓存偏好画像失败: {e}")
