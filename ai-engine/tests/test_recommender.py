"""
推荐引擎测试
"""

import pytest

from app.core.recommender.food_recommender import FoodRecommender
from app.core.recommender.preference_aggregator import PreferenceAggregator
from app.core.recommender.scenic_recommender import ScenicRecommender
from app.models.activity import Activity
from app.models.preference import PreferenceInput, TravelerInfo, TravelerPreferencesRequest
from app.models.restaurant import Restaurant


class TestFoodRecommender:
    """美食推荐引擎测试"""

    def setup_method(self):
        self.recommender = FoodRecommender()

    def test_calc_taste_match_exact(self):
        """测试口味精确匹配"""
        restaurant = Restaurant(name="川菜馆", cuisine="川菜", avg_price=80)
        score = self.recommender._calc_taste_match(restaurant, "辣,麻")
        assert score > 0.5

    def test_calc_taste_match_no_preference(self):
        """测试无偏好"""
        restaurant = Restaurant(name="川菜馆", cuisine="川菜", avg_price=80)
        score = self.recommender._calc_taste_match(restaurant, None)
        assert score == 0.5

    def test_calc_taste_match_no_overlap(self):
        """测试口味不匹配"""
        restaurant = Restaurant(name="日料店", cuisine="日料", avg_price=150)
        score = self.recommender._calc_taste_match(restaurant, "辣,麻")
        assert score < 0.5

    def test_calc_budget_fit_in_range(self):
        """测试预算在范围内"""
        score = self.recommender._calc_budget_fit(80, 50, 150)
        assert score > 0.5

    def test_calc_budget_fit_over_budget(self):
        """测试超出预算"""
        score = self.recommender._calc_budget_fit(300, 50, 150)
        assert score < 0.5

    def test_calc_budget_fit_no_limit(self):
        """测试无预算限制"""
        score = self.recommender._calc_budget_fit(80, None, None)
        assert score == 0.5

    def test_calc_rating_score(self):
        """测试评分计算"""
        assert self.recommender._calc_rating_score(5.0) == 1.0
        assert self.recommender._calc_rating_score(3.0) == 0.6
        assert self.recommender._calc_rating_score(None) == 0.3

    def test_haversine_distance(self):
        """测试距离计算"""
        # 北京到上海大约1000公里
        distance = FoodRecommender._haversine_distance(39.9, 116.4, 31.2, 121.5)
        assert 900000 < distance < 1200000  # 900-1200公里

    def test_calc_distance_score_no_location(self):
        """测试无位置信息"""
        restaurant = Restaurant(name="测试餐厅", avg_price=80)
        score = self.recommender._calc_distance_score(restaurant, None, None)
        assert score == 0.5


class TestScenicRecommender:
    """景区推荐引擎测试"""

    def setup_method(self):
        self.recommender = ScenicRecommender()

    def test_calc_category_match_exact(self):
        """测试类别精确匹配"""
        activity = Activity(name="故宫", categories=["历史古迹", "博物馆"])
        score = self.recommender._calc_category_match(activity, "历史古迹")
        assert score == 1.0

    def test_calc_category_match_fuzzy(self):
        """测试类别模糊匹配"""
        activity = Activity(name="景点", categories=["古迹游览"])
        score = self.recommender._calc_category_match(activity, "历史古迹")
        assert score > 0.5

    def test_calc_mood_fit(self):
        """测试心情适配"""
        activity = Activity(name="温泉", categories=["温泉", "休闲"])
        score = self.recommender._calc_mood_fit(activity, "放松")
        assert score > 0.5

    def test_calc_weather_fit_sunny_outdoor(self):
        """测试晴天户外适配"""
        activity = Activity(name="公园", categories=["自然风光", "公园"])
        score = self.recommender._calc_weather_fit(activity, "晴")
        assert score > 0.5

    def test_calc_weather_fit_rainy_indoor(self):
        """测试雨天室内适配"""
        activity = Activity(name="博物馆", categories=["博物馆", "室内"])
        score = self.recommender._calc_weather_fit(activity, "大雨")
        assert score > 0.5

    def test_calc_weather_fit_rainy_outdoor(self):
        """测试雨天户外不适配"""
        activity = Activity(name="爬山", categories=["户外运动", "徒步"])
        score = self.recommender._calc_weather_fit(activity, "大雨")
        assert score < 0.5


class TestPreferenceAggregator:
    """偏好聚合器测试"""

    def setup_method(self):
        self.aggregator = PreferenceAggregator()

    def test_analyze_individual(self):
        """测试单人偏好分析"""
        import asyncio

        input_data = PreferenceInput(
            user_id="user-1",
            food_preferences=["川菜", "火锅"],
            activity_preferences=["文化", "历史"],
            budget_level="medium",
        )

        profile = asyncio.get_event_loop().run_until_complete(
            self.aggregator.analyze_individual(input_data)
        )

        assert profile.user_id == "user-1"
        assert "川菜" in profile.food_preferences
        assert "文化" in profile.activity_preferences
        assert profile.budget_level == "medium"

    def test_aggregate_group(self):
        """测试多人偏好聚合"""
        import asyncio

        travelers = [
            TravelerInfo(
                user_id="user-1",
                food_preferences=["川菜", "火锅"],
                activity_preferences=["文化"],
                budget_level="medium",
            ),
            TravelerInfo(
                user_id="user-2",
                food_preferences=["粤菜", "日料"],
                activity_preferences=["自然"],
                budget_level="high",
            ),
        ]

        request = TravelerPreferencesRequest(travelers=travelers)
        result = asyncio.get_event_loop().run_until_complete(
            self.aggregator.aggregate_group(request.travelers)
        )

        assert "profile" in result
        assert "compromise_areas" in result
        assert "consensus_areas" in result
        assert result["profile"].user_id == "group"

    def test_aggregate_single_traveler(self):
        """测试单人聚合"""
        import asyncio

        travelers = [
            TravelerInfo(
                user_id="user-1",
                food_preferences=["川菜"],
                budget_level="low",
            ),
        ]

        result = asyncio.get_event_loop().run_until_complete(
            self.aggregator.aggregate_group(travelers)
        )

        assert result["profile"].food_preferences == ["川菜"]
        assert len(result["compromise_areas"]) == 0

    def test_find_compromises(self):
        """测试妥协区域识别"""
        profiles = [
            type("Profile", (), {
                "food_preferences": ["川菜", "火锅"],
                "activity_preferences": ["文化"],
                "budget_level": "low",
                "pace_preference": "relaxed",
            })(),
            type("Profile", (), {
                "food_preferences": ["粤菜", "日料"],
                "activity_preferences": ["户外"],
                "budget_level": "luxury",
                "pace_preference": "fast",
            })(),
        ]

        analysis = self.aggregator._analyze_dimensions(profiles)

        assert "food" in analysis
        assert "budget" in analysis
        assert "pace" in analysis

        compromises = self.aggregator._find_compromises(analysis)
        assert len(compromises) > 0
