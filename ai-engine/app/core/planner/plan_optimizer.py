"""
行程优化器

组合LLM行程生成器和OR-Tools约束求解器，
实现"LLM生成 -> 约束验证 -> 反馈优化"的迭代优化流程。
"""

import asyncio
import logging
import uuid
from datetime import datetime
from typing import AsyncGenerator, Optional

from app.core.planner.constraint_solver import ConstraintSolver
from app.core.planner.llm_planner import LLMPlanner
from app.core.planner.plan_models import ConstraintConfig, Itinerary
from app.models.plan_request import PlanOptimizeRequest, PlanRequest

logger = logging.getLogger(__name__)


class PlanOptimizer:
    """
    行程优化器

    整合LLM生成能力和约束求解能力，通过多轮迭代生成高质量行程方案。

    工作流程：
    1. LLM生成初始行程方案
    2. 约束求解器验证方案可行性
    3. 如有违规，将反馈发送给LLM重新优化
    4. 重复2-3直到方案满足所有约束或达到最大迭代次数
    """

    # 最大优化迭代次数
    MAX_ITERATIONS = 3

    def __init__(self):
        """初始化行程优化器"""
        self.llm_planner = LLMPlanner()
        self.constraint_solver = ConstraintSolver()

        # 任务状态存储（生产环境应使用Redis）
        self._tasks: dict[str, dict] = {}

    async def create_plan(self, request: PlanRequest) -> str:
        """
        创建行程规划任务

        Args:
            request: 行程规划请求

        Returns:
            任务ID
        """
        plan_id = str(uuid.uuid4())

        self._tasks[plan_id] = {
            "plan_id": plan_id,
            "status": "pending",
            "progress": 0,
            "message": "任务已创建",
            "request": request,
            "created_at": datetime.now().isoformat(),
        }

        logger.info(f"创建规划任务: plan_id={plan_id}")

        # 异步执行规划
        asyncio.create_task(self._execute_plan(plan_id, request))

        return plan_id

    async def get_plan_status(self, plan_id: str) -> Optional[dict]:
        """
        获取规划任务状态

        Args:
            plan_id: 任务ID

        Returns:
            任务状态信息
        """
        return self._tasks.get(plan_id)

    async def get_plan_result(self, plan_id: str) -> Optional[dict]:
        """
        获取规划结果

        Args:
            plan_id: 任务ID

        Returns:
            规划结果字典
        """
        task = self._tasks.get(plan_id)
        if task is None:
            return None

        if task["status"] != "completed":
            return None

        return task.get("result")

    async def optimize_plan(
        self,
        plan_id: str,
        request: PlanOptimizeRequest,
    ) -> dict:
        """
        优化已有行程方案

        Args:
            plan_id: 原始任务ID
            request: 优化请求

        Returns:
            优化后的行程结果
        """
        task = self._tasks.get(plan_id)
        if task is None:
            raise ValueError(f"规划任务不存在: {plan_id}")

        original_result = task.get("result")
        if original_result is None:
            raise ValueError("原始行程方案不存在")

        # 构建优化反馈
        feedback_parts = []
        if request.preferences:
            feedback_parts.append(f"调整偏好为: {', '.join(request.preferences)}")
        if request.budget_max:
            feedback_parts.append(f"预算上限调整为: {request.budget_max}元")
        if request.feedback:
            feedback_parts.append(f"用户反馈: {request.feedback}")

        feedback = "；".join(feedback_parts)

        # 构建约束配置
        constraint_config = {}
        if request.budget_max:
            constraint_config["daily_budget_max"] = request.budget_max / max(task["result"].get("days", 1))
            constraint_config["total_budget_max"] = request.budget_max

        # 重新执行优化流程
        optimized = await self._optimize_loop(
            plan_id=plan_id,
            request=task["request"],
            initial_feedback=feedback,
            constraint_overrides=constraint_config,
        )

        # 更新任务结果
        task["result"] = self._itinerary_to_dict(optimized)
        task["status"] = "completed"
        task["message"] = "行程优化完成"

        return task["result"]

    async def stream_plan(self, request: PlanRequest) -> AsyncGenerator[dict, None]:
        """
        流式执行行程规划

        Args:
            request: 行程规划请求

        Yields:
            流式事件
        """
        plan_id = str(uuid.uuid4())

        yield {"type": "init", "plan_id": plan_id, "message": "开始规划行程..."}

        # 第一阶段：LLM生成
        yield {"type": "stage", "stage": "llm_generate", "message": "AI正在生成行程方案..."}

        try:
            itinerary = await self.llm_planner.generate_plan(request)
            yield {
                "type": "progress",
                "stage": "llm_generate",
                "progress": 40,
                "message": "初始方案已生成，正在验证约束...",
            }

            # 第二阶段：约束验证和优化
            yield {"type": "stage", "stage": "constraint_check", "message": "正在验证行程约束..."}

            constraints = self._build_constraints(request)
            validation = self.constraint_solver.validate(itinerary, constraints)

            if validation["valid"]:
                yield {
                    "type": "progress",
                    "stage": "constraint_check",
                    "progress": 100,
                    "message": "行程方案验证通过",
                }
            else:
                yield {
                    "type": "progress",
                    "stage": "constraint_check",
                    "progress": 60,
                    "message": f"发现{len(validation['violations'])}个约束问题，正在优化...",
                }

                # 迭代优化
                optimized = await self._optimize_with_feedback(
                    itinerary, validation["violations"], constraints
                )
                itinerary = optimized

                yield {
                    "type": "progress",
                    "stage": "optimize",
                    "progress": 100,
                    "message": "行程优化完成",
                }

            # 返回最终结果
            result = self._itinerary_to_dict(itinerary)
            yield {"type": "complete", "plan_id": plan_id, "result": result}

        except Exception as e:
            logger.error(f"流式规划失败: {e}", exc_info=True)
            yield {"type": "error", "message": str(e)}

    async def _execute_plan(self, plan_id: str, request: PlanRequest) -> None:
        """
        异步执行规划任务

        Args:
            plan_id: 任务ID
            request: 规划请求
        """
        try:
            # 更新状态：LLM生成中
            self._update_task(plan_id, status="generating", progress=10, message="AI正在生成行程方案...")

            # 阶段1：LLM生成初始方案
            itinerary = await self.llm_planner.generate_plan(request)

            self._update_task(plan_id, status="validating", progress=50, message="正在验证行程约束...")

            # 阶段2：约束验证和优化
            constraints = self._build_constraints(request)
            optimized = await self._optimize_loop(plan_id, request, constraints=constraints)

            # 保存结果
            result = self._itinerary_to_dict(optimized)
            self._update_task(
                plan_id,
                status="completed",
                progress=100,
                message="行程规划完成",
                result=result,
            )

            logger.info(f"规划任务完成: plan_id={plan_id}")

        except Exception as e:
            logger.error(f"规划任务失败: plan_id={plan_id}, error={e}", exc_info=True)
            self._update_task(
                plan_id,
                status="failed",
                progress=0,
                message=f"规划失败: {str(e)}",
            )

    async def _optimize_loop(
        self,
        plan_id: str,
        request: PlanRequest,
        constraints: Optional[ConstraintConfig] = None,
        initial_feedback: Optional[str] = None,
        constraint_overrides: Optional[dict] = None,
    ) -> Itinerary:
        """
        执行优化循环

        Args:
            plan_id: 任务ID
            request: 规划请求
            constraints: 约束配置
            initial_feedback: 初始反馈
            constraint_overrides: 约束覆盖配置

        Returns:
            优化后的行程方案
        """
        if constraints is None:
            constraints = self._build_constraints(request)

        # 应用约束覆盖
        if constraint_overrides:
            if "daily_budget_max" in constraint_overrides:
                constraints.daily_budget_max = constraint_overrides["daily_budget_max"]
            if "total_budget_max" in constraint_overrides:
                constraints.total_budget_max = constraint_overrides["total_budget_max"]

        # 生成初始方案
        if initial_feedback:
            # 有反馈时先生成再优化
            itinerary = await self.llm_planner.generate_plan(request)
            itinerary = await self.llm_planner.refine_plan(
                itinerary, initial_feedback, constraint_overrides or {}
            )
        else:
            itinerary = await self.llm_planner.generate_plan(request)

        # 迭代优化
        for iteration in range(self.MAX_ITERATIONS):
            # 约束验证
            validation = self.constraint_solver.validate(itinerary, constraints)

            if validation["valid"]:
                logger.info(f"方案验证通过 (迭代{iteration + 1}次)")
                break

            logger.info(
                f"方案存在{len(validation['violations'])}个违规, "
                f"进行第{iteration + 1}轮优化"
            )

            self._update_task(
                plan_id,
                status="optimizing",
                progress=50 + (iteration + 1) * 15,
                message=f"正在优化行程 (第{iteration + 1}轮)...",
            )

            # 构建反馈
            feedback = self._build_feedback(validation["violations"])

            # LLM优化
            itinerary = await self.llm_planner.refine_plan(itinerary, feedback)

        # 最终约束求解优化
        itinerary = self.constraint_solver.solve(itinerary, constraints)

        return itinerary

    async def _optimize_with_feedback(
        self,
        itinerary: Itinerary,
        violations: list[dict],
        constraints: ConstraintConfig,
    ) -> Itinerary:
        """
        根据违规反馈优化行程

        Args:
            itinerary: 当前行程
            violations: 违规列表
            constraints: 约束配置

        Returns:
            优化后的行程
        """
        feedback = self._build_feedback(violations)
        refined = await self.llm_planner.refine_plan(itinerary, feedback)
        return self.constraint_solver.solve(refined, constraints)

    def _build_constraints(self, request: PlanRequest) -> ConstraintConfig:
        """
        从请求中构建约束配置

        Args:
            request: 规划请求

        Returns:
            约束配置
        """
        return ConstraintConfig(
            daily_budget_max=request.budget_max / request.days if request.budget_max else None,
            total_budget_max=request.budget_max,
        )

    def _build_feedback(self, violations: list[dict]) -> str:
        """
        根据违规列表构建优化反馈

        Args:
            violations: 违规列表

        Returns:
            反馈文本
        """
        feedback_parts = ["请根据以下问题优化行程方案："]

        for v in violations:
            feedback_parts.append(f"- {v['message']}")

        feedback_parts.append("请确保优化后的方案解决以上所有问题。")

        return "\n".join(feedback_parts)

    def _update_task(self, plan_id: str, **kwargs) -> None:
        """
        更新任务状态

        Args:
            plan_id: 任务ID
            **kwargs: 要更新的字段
        """
        if plan_id in self._tasks:
            self._tasks[plan_id].update(kwargs)

    def _itinerary_to_dict(self, itinerary: Itinerary) -> dict:
        """
        将行程方案转为字典（用于API响应）

        Args:
            itinerary: 行程方案

        Returns:
            字典格式
        """
        return {
            "plan_id": itinerary.plan_id,
            "destination": itinerary.destination,
            "days": itinerary.days,
            "start_date": str(itinerary.start_date) if itinerary.start_date else None,
            "end_date": str(itinerary.end_date) if itinerary.end_date else None,
            "itinerary": [dp.model_dump() for dp in itinerary.day_plans],
            "total_budget": itinerary.total_budget,
            "total_cost": itinerary.total_cost,
            "travelers_count": itinerary.travelers_count,
            "tags": itinerary.tags,
            "tips": itinerary.tips,
            "warnings": itinerary.warnings,
        }
