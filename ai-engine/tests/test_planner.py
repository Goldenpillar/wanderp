"""
行程规划器测试
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch

from app.core.planner.plan_models import (
    ActivityNode,
    ActivityType,
    ConstraintConfig,
    DayPlan,
    EnergyLevel,
    Itinerary,
    Location,
    TimeSlot,
    TransportMode,
    TransportSegment,
)
from app.core.planner.constraint_solver import ConstraintSolver
from app.models.plan_request import PlanRequest, TravelerRequest


class TestConstraintSolver:
    """约束求解器测试"""

    def setup_method(self):
        """测试前准备"""
        self.solver = ConstraintSolver()

    def _create_sample_itinerary(self) -> Itinerary:
        """创建示例行程"""
        activity1 = ActivityNode(
            activity_id="act-1",
            name="故宫博物院",
            activity_type=ActivityType.SCENIC,
            location=Location(name="故宫", address="北京东城区", lat=39.9163, lng=116.3972, district="东城区"),
            time_slot=TimeSlot(start=__import__("datetime").time(9, 0), end=__import__("datetime").time(12, 0)),
            duration_minutes=180,
            cost=60,
            energy_required=EnergyLevel.MEDIUM,
            rating=4.8,
        )
        activity2 = ActivityNode(
            activity_id="act-2",
            name="全聚德烤鸭",
            activity_type=ActivityType.FOOD,
            location=Location(name="全聚德", address="北京东城区", lat=39.8993, lng=116.4014, district="东城区"),
            time_slot=TimeSlot(start=__import__("datetime").time(12, 30), end=__import__("datetime").time(14, 0)),
            duration_minutes=90,
            cost=150,
            energy_required=EnergyLevel.LOW,
            rating=4.5,
        )
        activity3 = ActivityNode(
            activity_id="act-3",
            name="天安门广场",
            activity_type=ActivityType.SCENIC,
            location=Location(name="天安门", address="北京东城区", lat=39.9054, lng=116.3976, district="东城区"),
            time_slot=TimeSlot(start=__import__("datetime").time(15, 0), end=__import__("datetime").time(17, 0)),
            duration_minutes=120,
            cost=0,
            energy_required=EnergyLevel.LOW,
            rating=4.7,
        )

        day_plan = DayPlan(
            day_index=1,
            theme="北京文化之旅",
            activities=[activity1, activity2, activity3],
            total_cost=210,
        )

        return Itinerary(
            plan_id="test-plan-1",
            destination="北京",
            days=1,
            day_plans=[day_plan],
            total_budget=500,
            total_cost=210,
            travelers_count=2,
        )

    def test_validate_valid_itinerary(self):
        """测试验证合法行程"""
        itinerary = self._create_sample_itinerary()
        constraints = ConstraintConfig(daily_budget_max=300)

        result = self.solver.validate(itinerary, constraints)

        assert result["valid"] is True
        assert len(result["violations"]) == 0
        assert result["score"] > 0

    def test_validate_budget_violation(self):
        """测试预算违规检测"""
        itinerary = self._create_sample_itinerary()
        constraints = ConstraintConfig(daily_budget_max=100)

        result = self.solver.validate(itinerary, constraints)

        assert result["valid"] is False
        budget_violations = [v for v in result["violations"] if v["type"] == "budget"]
        assert len(budget_violations) > 0

    def test_validate_time_conflict(self):
        """测试时间冲突检测"""
        from datetime import time

        activity1 = ActivityNode(
            activity_id="act-1",
            name="活动A",
            activity_type=ActivityType.SCENIC,
            location=Location(name="地点A", lat=39.9, lng=116.4),
            time_slot=TimeSlot(start=time(9, 0), end=time(12, 0)),
            duration_minutes=180,
        )
        activity2 = ActivityNode(
            activity_id="act-2",
            name="活动B",
            activity_type=ActivityType.SCENIC,
            location=Location(name="地点B", lat=39.9, lng=116.5),
            time_slot=TimeSlot(start=time(11, 0), end=time(13, 0)),
            duration_minutes=120,
        )

        day_plan = DayPlan(day_index=1, activities=[activity1, activity2])
        itinerary = Itinerary(plan_id="test", destination="测试", days=1, day_plans=[day_plan])

        result = self.solver.validate(itinerary)

        assert result["valid"] is False
        conflicts = [v for v in result["violations"] if v["type"] == "time_conflict"]
        assert len(conflicts) > 0

    def test_validate_meal_check(self):
        """测试用餐检查"""
        activity = ActivityNode(
            activity_id="act-1",
            name="游览",
            activity_type=ActivityType.SCENIC,
            location=Location(name="地点", lat=39.9, lng=116.4),
            time_slot=TimeSlot(
                start=__import__("datetime").time(9, 0),
                end=__import__("datetime").time(17, 0),
            ),
            duration_minutes=480,
        )

        day_plan = DayPlan(day_index=1, activities=[activity])
        itinerary = Itinerary(plan_id="test", destination="测试", days=1, day_plans=[day_plan])

        result = self.solver.validate(itinerary)

        meal_violations = [v for v in result["violations"] if v["type"] == "meal"]
        assert len(meal_violations) > 0

    def test_calculate_score(self):
        """测试评分计算"""
        itinerary = self._create_sample_itinerary()
        constraints = ConstraintConfig()

        result = self.solver.validate(itinerary, constraints)

        assert 0 <= result["score"] <= 100


class TestPlanModels:
    """行程数据模型测试"""

    def test_time_slot_duration(self):
        """测试时间段时长计算"""
        from datetime import time

        slot = TimeSlot(start=time(9, 0), end=time(12, 0))
        assert slot.duration_hours == 3.0

    def test_day_plan_times(self):
        """测试日程时间"""
        from datetime import time

        activity = ActivityNode(
            activity_id="act-1",
            name="测试",
            activity_type=ActivityType.SCENIC,
            location=Location(name="地点", lat=39.9, lng=116.4),
            time_slot=TimeSlot(start=time(10, 0), end=time(12, 0)),
            duration_minutes=120,
        )
        day_plan = DayPlan(day_index=1, activities=[activity])

        assert day_plan.start_time == time(10, 0)
        assert day_plan.end_time == time(12, 0)

    def test_empty_day_plan(self):
        """测试空日程"""
        day_plan = DayPlan(day_index=1)
        assert day_plan.start_time is None
        assert day_plan.end_time is None
