"""
OR-Tools 约束求解器

使用Google OR-Tools CP-SAT求解器对行程进行约束建模和优化。
负责处理时间冲突、预算限制、距离约束等硬性约束条件。
"""

import logging
import math
from typing import Optional

from ortools.sat.python import cp_model

from app.core.planner.plan_models import (
    ActivityNode,
    ActivityType,
    ConstraintConfig,
    DayPlan,
    EnergyLevel,
    Itinerary,
    TimeSlot,
    TransportMode,
    TransportSegment,
)

logger = logging.getLogger(__name__)


class ConstraintSolver:
    """
    行程约束求解器

    使用OR-Tools CP-SAT求解器对行程方案进行约束验证和优化。
    确保行程满足所有硬性约束（时间、预算、距离等），
    并在满足约束的前提下最大化行程质量评分。
    """

    def __init__(self):
        """初始化约束求解器"""
        self.model = cp_model.CpModel()
        self.solver = cp_model.CpSolver()
        # 设置求解器参数
        self.solver.parameters.max_time_in_seconds = 30.0  # 最大求解时间30秒
        self.solver.parameters.num_workers = 4  # 并行求解线程数

    def solve(
        self,
        itinerary: Itinerary,
        constraints: Optional[ConstraintConfig] = None,
    ) -> Itinerary:
        """
        对行程方案进行约束求解和优化

        Args:
            itinerary: LLM生成的初始行程方案
            constraints: 约束配置

        Returns:
            优化后的行程方案
        """
        if constraints is None:
            constraints = ConstraintConfig()

        logger.info(f"开始约束求解: plan_id={itinerary.plan_id}")

        # 收集所有活动节点
        all_activities = []
        for day_plan in itinerary.day_plans:
            all_activities.extend(day_plan.activities)

        if not all_activities:
            logger.warning("行程中没有活动，跳过约束求解")
            return itinerary

        # 构建约束模型
        self.model = cp_model.CpModel()
        variables = self._build_model(all_activities, constraints, itinerary)

        # 求解
        status = self.solver.Solve(self.model)

        if status in (cp_model.OPTIMAL, cp_model.FEASIBLE):
            logger.info(f"约束求解成功: status={self.solver.StatusName(status)}")
            optimized = self._extract_solution(all_activities, variables, itinerary)
            return optimized
        else:
            logger.warning(f"约束求解未找到可行解: status={self.solver.StatusName(status)}")
            # 返回原始方案，但标记约束冲突
            return self._mark_violations(itinerary, constraints)

    def validate(self, itinerary: Itinerary, constraints: Optional[ConstraintConfig] = None) -> dict:
        """
        验证行程方案是否满足所有约束条件

        Args:
            itinerary: 行程方案
            constraints: 约束配置

        Returns:
            验证结果，包含是否通过和违规详情
        """
        if constraints is None:
            constraints = ConstraintConfig()

        violations = []

        for day_plan in itinerary.day_plans:
            # 检查每日预算
            if constraints.daily_budget_max is not None:
                day_cost = sum(a.cost for a in day_plan.activities)
                if day_cost > constraints.daily_budget_max:
                    violations.append({
                        "day": day_plan.day_index,
                        "type": "budget",
                        "message": f"第{day_plan.day_index}天费用{day_cost}元超过预算{constraints.daily_budget_max}元",
                        "severity": "high",
                    })

            # 检查每日活动时长
            total_activity_minutes = sum(a.duration_minutes for a in day_plan.activities)
            max_minutes = constraints.daily_activity_hours_max * 60
            min_minutes = constraints.daily_activity_hours_min * 60
            if total_activity_minutes > max_minutes:
                violations.append({
                    "day": day_plan.day_index,
                    "type": "time",
                    "message": f"第{day_plan.day_index}天活动时长{total_activity_minutes/60:.1f}小时超过上限{constraints.daily_activity_hours_max}小时",
                    "severity": "medium",
                })
            if total_activity_minutes < min_minutes:
                violations.append({
                    "day": day_plan.day_index,
                    "type": "time",
                    "message": f"第{day_plan.day_index}天活动时长{total_activity_minutes/60:.1f}小时低于下限{constraints.daily_activity_hours_min}小时",
                    "severity": "low",
                })

            # 检查每日步行距离
            total_walking = sum(
                seg.distance_meters
                for seg in day_plan.transport_segments
                if seg.mode == TransportMode.WALKING
            )
            if total_walking > constraints.max_walking_distance_meters:
                violations.append({
                    "day": day_plan.day_index,
                    "type": "distance",
                    "message": f"第{day_plan.day_index}天步行距离{total_walking/1000:.1f}公里超过上限{constraints.max_walking_distance_meters/1000:.1f}公里",
                    "severity": "medium",
                })

            # 检查用餐安排
            meal_types = {ActivityType.FOOD}
            meals = [a for a in day_plan.activities if a.activity_type in meal_types]
            if len(meals) < 2:
                violations.append({
                    "day": day_plan.day_index,
                    "type": "meal",
                    "message": f"第{day_plan.day_index}天用餐安排不足（仅{len(meals)}餐）",
                    "severity": "high",
                })

            # 检查时间冲突
            sorted_activities = sorted(
                day_plan.activities,
                key=lambda a: (a.time_slot.start.hour, a.time_slot.start.minute),
            )
            for i in range(len(sorted_activities) - 1):
                curr_end = sorted_activities[i].time_slot.end
                next_start = sorted_activities[i + 1].time_slot.start
                if curr_end > next_start:
                    violations.append({
                        "day": day_plan.day_index,
                        "type": "time_conflict",
                        "message": (
                            f"时间冲突: '{sorted_activities[i].name}' "
                            f"({curr_end}) 与 '{sorted_activities[i + 1].name}' "
                            f"({next_start}) 重叠"
                        ),
                        "severity": "high",
                    })

        # 检查总预算
        if constraints.total_budget_max is not None:
            total_cost = sum(dp.total_cost for dp in itinerary.day_plans)
            if total_cost > constraints.total_budget_max:
                violations.append({
                    "day": 0,
                    "type": "total_budget",
                    "message": f"总费用{total_cost}元超过预算{constraints.total_budget_max}元",
                    "severity": "high",
                })

        return {
            "valid": len(violations) == 0,
            "violations": violations,
            "score": self._calculate_score(itinerary, violations),
        }

    def _build_model(
        self,
        activities: list[ActivityNode],
        constraints: ConstraintConfig,
        itinerary: Itinerary,
    ) -> dict:
        """
        构建CP-SAT约束模型

        为每个活动创建决策变量，并添加约束条件。

        Args:
            activities: 活动列表
            constraints: 约束配置
            itinerary: 原始行程方案（用于按天分组）

        Returns:
            变量字典
        """
        variables = {}

        # 为每个活动创建布尔变量（是否包含在最终方案中）
        for i, activity in enumerate(activities):
            # 活动是否选中
            var_selected = self.model.NewBoolVar(f"selected_{i}")

            # 活动开始时间（以分钟为单位，从0:00开始）
            start_minutes = (
                activity.time_slot.start.hour * 60 + activity.time_slot.start.minute
            )
            var_start = self.model.NewIntVar(0, 1440, f"start_{i}")
            self.model.Add(var_start == start_minutes).OnlyEnforceIf(var_selected)

            # 活动持续时间
            var_duration = self.model.NewIntVar(
                activity.duration_minutes // 2,
                activity.duration_minutes * 2,
                f"duration_{i}",
            )
            self.model.Add(var_duration == activity.duration_minutes).OnlyEnforceIf(var_selected)

            variables[i] = {
                "selected": var_selected,
                "start": var_start,
                "duration": var_duration,
                "activity": activity,
            }

        # ---- 约束1: 活动之间不重叠 ----
        for i in range(len(activities)):
            for j in range(i + 1, len(activities)):
                act_i = activities[i]
                act_j = activities[j]

                # 只对同一天的活动添加不重叠约束
                # 通过比较活动ID前缀判断是否同一天（简化处理）
                vars_i = variables[i]
                vars_j = variables[j]

                # 创建辅助变量表示顺序
                i_before_j = self.model.NewBoolVar(f"i_before_j_{i}_{j}")
                j_before_i = self.model.NewBoolVar(f"j_before_i_{i}_{j}")

                # i在j之前 或 j在i之前（至少一个成立）
                self.model.Add(vars_i["start"] + vars_i["duration"] <= vars_j["start"]).OnlyEnforceIf(i_before_j)
                self.model.Add(vars_j["start"] + vars_j["duration"] <= vars_i["start"]).OnlyEnforceIf(j_before_i)
                self.model.AddBoolOr([i_before_j, j_before_i])

        # ---- 约束2: 每日预算限制 ----
        if constraints.daily_budget_max is not None:
            # 计算每日预算上限：优先使用配置中的 daily_budget_max，
            # 若未设置则按总预算均分到每天
            daily_budget_limit = constraints.daily_budget_max
            if daily_budget_limit <= 0 and constraints.total_budget_max is not None:
                num_days = len(itinerary.day_plans)
                if num_days > 0:
                    daily_budget_limit = constraints.total_budget_max / num_days

            if daily_budget_limit > 0:
                # 按天分组活动，计算每天的总费用约束
                # 使用 itinerary 中的 day_plans 按天索引分组
                activity_offset = 0
                for day_plan in itinerary.day_plans:
                    day_activity_count = len(day_plan.activities)
                    if day_activity_count == 0:
                        activity_offset += day_activity_count
                        continue

                    # 获取当天所有活动的费用项（单位转换为分，与目标函数一致）
                    day_cost_terms = []
                    for k in range(day_activity_count):
                        idx = activity_offset + k
                        if idx in variables:
                            cost_cents = int(variables[idx]["activity"].cost * 100)
                            day_cost_terms.append(
                                variables[idx]["selected"] * cost_cents
                            )

                    if day_cost_terms:
                        # 当天总费用变量
                        day_cost_var = self.model.NewIntVar(
                            0, int(daily_budget_limit * 100) * 2,
                            f"day_{day_plan.day_index}_cost",
                        )
                        self.model.Add(
                            day_cost_var == sum(day_cost_terms)
                        )
                        # 约束：当天总费用 <= 每日预算上限（转换为分）
                        self.model.Add(
                            day_cost_var <= int(daily_budget_limit * 100)
                        )

                    activity_offset += day_activity_count

        # ---- 约束3: 用餐时间约束 ----
        meal_times = constraints.meal_times
        for meal_time in meal_times:
            meal_start = meal_time.start.hour * 60 + meal_time.start.minute
            meal_end = meal_time.end.hour * 60 + meal_time.end.minute

            # 至少有一个food类型活动在用餐时间段内
            meal_activities = [
                i for i, a in enumerate(activities)
                if a.activity_type == ActivityType.FOOD
            ]
            if meal_activities:
                has_meal = self.model.NewBoolVar(f"has_meal_{meal_start}")
                meal_vars = [variables[i]["selected"] for i in meal_activities]
                self.model.AddMaxEquality(has_meal, meal_vars)
                self.model.Add(has_meal == 1)

        # ---- 目标函数: 最大化行程质量评分 ----
        # 评分 = 选中活动数量 * 平均评分 - 总费用惩罚
        score_terms = []
        for i, var in variables.items():
            activity = var["activity"]
            # 活动评分贡献
            rating = activity.rating or 3.0
            score_terms.append(var["selected"] * int(rating * 100))

        # 费用惩罚（超出预算部分）
        if constraints.total_budget_max is not None:
            cost_var = self.model.NewIntVar(0, constraints.total_budget_max * 2, "total_cost")
            cost_terms = [
                var["selected"] * int(var["activity"].cost * 100)
                for var in variables.values()
            ]
            self.model.Add(cost_var == sum(cost_terms))

            # 超出预算的惩罚
            over_budget = self.model.NewIntVar(0, constraints.total_budget_max, "over_budget")
            self.model.AddMaxEquality(
                over_budget,
                [cost_var - int(constraints.total_budget_max * 100), 0],
            )
            score_terms.append(-over_budget * 2)  # 超出预算扣分

        if score_terms:
            self.model.Maximize(sum(score_terms))

        return variables

    def _extract_solution(
        self,
        activities: list[ActivityNode],
        variables: dict,
        original_itinerary: Itinerary,
    ) -> Itinerary:
        """
        从求解结果中提取优化后的行程方案

        Args:
            activities: 原始活动列表
            variables: 决策变量
            original_itinerary: 原始行程

        Returns:
            优化后的行程
        """
        # 筛选被选中的活动
        selected_indices = []
        for i, var in variables.items():
            if self.solver.Value(var["selected"]) == 1:
                selected_indices.append(i)

        # 重建行程
        optimized_day_plans = []
        current_day_activities = []
        current_day_index = 1

        for idx in selected_indices:
            activity = variables[idx]["activity"]
            # 简化处理：假设活动按天排列
            current_day_activities.append(activity)

        # 按天分组重建
        for day_plan in original_itinerary.day_plans:
            optimized_activities = [
                a for a in day_plan.activities
                if any(
                    a.activity_id == variables[idx]["activity"].activity_id
                    for idx in selected_indices
                )
            ]
            optimized_day = DayPlan(
                day_index=day_plan.day_index,
                date=day_plan.date,
                theme=day_plan.theme,
                activities=optimized_activities,
                transport_segments=day_plan.transport_segments,
                total_cost=sum(a.cost for a in optimized_activities),
                notes=day_plan.notes,
            )
            optimized_day_plans.append(optimized_day)

        return Itinerary(
            plan_id=original_itinerary.plan_id,
            destination=original_itinerary.destination,
            days=original_itinerary.days,
            start_date=original_itinerary.start_date,
            end_date=original_itinerary.end_date,
            day_plans=optimized_day_plans,
            total_budget=original_itinerary.total_budget,
            total_cost=sum(dp.total_cost for dp in optimized_day_plans),
            travelers_count=original_itinerary.travelers_count,
            tags=original_itinerary.tags,
            tips=original_itinerary.tips,
            warnings=original_itinerary.warnings,
        )

    def _mark_violations(
        self,
        itinerary: Itinerary,
        constraints: ConstraintConfig,
    ) -> Itinerary:
        """
        标记行程中的约束违规

        Args:
            itinerary: 原始行程
            constraints: 约束配置

        Returns:
            标记了违规的行程
        """
        validation = self.validate(itinerary, constraints)
        if validation["violations"]:
            warnings = [v["message"] for v in validation["violations"]]
            itinerary.warnings.extend(warnings)
        return itinerary

    def _calculate_score(self, itinerary: Itinerary, violations: list[dict]) -> float:
        """
        计算行程质量评分

        Args:
            itinerary: 行程方案
            violations: 违规列表

        Returns:
            评分（0-100）
        """
        score = 100.0

        # 违规扣分
        for violation in violations:
            severity = violation.get("severity", "low")
            if severity == "high":
                score -= 15
            elif severity == "medium":
                score -= 8
            else:
                score -= 3

        # 活动多样性加分
        activity_types = set()
        for day_plan in itinerary.day_plans:
            for activity in day_plan.activities:
                activity_types.add(activity.activity_type)
        score += min(len(activity_types) * 3, 15)

        # 评分覆盖加分
        rated_activities = [
            a for dp in itinerary.day_plans
            for a in dp.activities
            if a.rating
        ]
        if rated_activities:
            avg_rating = sum(a.rating for a in rated_activities) / len(rated_activities)
            score += avg_rating * 3

        return max(0, min(100, score))
