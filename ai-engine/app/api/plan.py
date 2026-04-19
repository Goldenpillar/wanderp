"""
行程规划 API 路由

提供智能行程规划相关接口，包括：
- 创建行程规划请求
- 获取行程规划结果
- 优化调整行程
- 获取行程详情
"""

import logging
from typing import Optional

from fastapi import APIRouter, BackgroundTasks, HTTPException, Query

from app.models.plan_request import (
    PlanOptimizeRequest,
    PlanRequest,
    PlanResponse,
    PlanStatusResponse,
)

logger = logging.getLogger(__name__)

router = APIRouter()


# 内存中的任务状态存储（生产环境应使用Redis或数据库）
_plan_tasks: dict[str, dict] = {}


@router.post("/create", response_model=PlanResponse, summary="创建行程规划")
async def create_plan(
    request: PlanRequest,
    background_tasks: BackgroundTasks,
) -> PlanResponse:
    """
    创建智能行程规划

    根据用户输入的目的地、日期、偏好等信息，
    使用LLM生成初始行程方案，并通过约束求解器优化。

    Args:
        request: 行程规划请求参数

    Returns:
        行程规划结果
    """
    logger.info(
        f"收到行程规划请求: 目的地={request.destination}, "
        f"天数={request.days}, 人数={len(request.travelers)}"
    )

    try:
        from app.core.planner.plan_optimizer import PlanOptimizer

        optimizer = PlanOptimizer()

        # 异步执行规划任务
        plan_id = await optimizer.create_plan(request)

        # 获取规划结果
        result = await optimizer.get_plan_result(plan_id)

        return PlanResponse(
            plan_id=plan_id,
            status="completed",
            destination=request.destination,
            days=request.days,
            itinerary=result.get("itinerary", []),
            total_budget=result.get("total_budget", 0),
            tips=result.get("tips", []),
        )

    except ValueError as e:
        logger.warning(f"行程规划参数错误: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"行程规划失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="行程规划服务暂时不可用，请稍后重试")


@router.get("/status/{plan_id}", response_model=PlanStatusResponse, summary="查询规划状态")
async def get_plan_status(plan_id: str) -> PlanStatusResponse:
    """
    查询行程规划任务状态

    Args:
        plan_id: 规划任务ID

    Returns:
        规划任务状态信息
    """
    from app.core.planner.plan_optimizer import PlanOptimizer

    optimizer = PlanOptimizer()
    status = await optimizer.get_plan_status(plan_id)

    if status is None:
        raise HTTPException(status_code=404, detail="规划任务不存在")

    return PlanStatusResponse(
        plan_id=plan_id,
        status=status["status"],
        progress=status.get("progress", 0),
        message=status.get("message", ""),
    )


@router.get("/{plan_id}", response_model=PlanResponse, summary="获取行程详情")
async def get_plan(plan_id: str) -> PlanResponse:
    """
    获取已完成的行程规划详情

    Args:
        plan_id: 规划任务ID

    Returns:
        完整的行程规划结果
    """
    from app.core.planner.plan_optimizer import PlanOptimizer

    optimizer = PlanOptimizer()
    result = await optimizer.get_plan_result(plan_id)

    if result is None:
        raise HTTPException(status_code=404, detail="行程规划不存在")

    return PlanResponse(
        plan_id=plan_id,
        status="completed",
        destination=result.get("destination", ""),
        days=result.get("days", 0),
        itinerary=result.get("itinerary", []),
        total_budget=result.get("total_budget", 0),
        tips=result.get("tips", []),
    )


@router.post("/optimize/{plan_id}", response_model=PlanResponse, summary="优化行程")
async def optimize_plan(
    plan_id: str,
    request: PlanOptimizeRequest,
) -> PlanResponse:
    """
    对已有行程进行优化调整

    支持调整偏好、预算、时间等约束条件后重新优化。

    Args:
        plan_id: 原始规划任务ID
        request: 优化调整请求参数

    Returns:
        优化后的行程规划结果
    """
    logger.info(f"收到行程优化请求: plan_id={plan_id}")

    try:
        from app.core.planner.plan_optimizer import PlanOptimizer

        optimizer = PlanOptimizer()
        result = await optimizer.optimize_plan(plan_id, request)

        return PlanResponse(
            plan_id=plan_id,
            status="completed",
            destination=result.get("destination", ""),
            days=result.get("days", 0),
            itinerary=result.get("itinerary", []),
            total_budget=result.get("total_budget", 0),
            tips=result.get("tips", []),
        )

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"行程优化失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="行程优化服务暂时不可用")


@router.post("/stream", summary="流式行程规划")
async def stream_plan(request: PlanRequest):
    """
    流式行程规划接口

    使用Server-Sent Events (SSE) 实时返回规划进度和结果。

    Args:
        request: 行程规划请求参数

    Returns:
        SSE事件流
    """
    from fastapi.responses import StreamingResponse

    async def event_generator():
        """SSE事件生成器"""
        import json

        try:
            from app.core.planner.plan_optimizer import PlanOptimizer

            optimizer = PlanOptimizer()

            # 发送开始事件
            yield f"data: {json.dumps({'type': 'start', 'message': '开始规划行程...'}, ensure_ascii=False)}\n\n"

            # 执行规划并流式返回进度
            async for event in optimizer.stream_plan(request):
                yield f"data: {json.dumps(event, ensure_ascii=False)}\n\n"

            # 发送完成事件
            yield f"data: {json.dumps({'type': 'done', 'message': '行程规划完成'}, ensure_ascii=False)}\n\n"

        except Exception as e:
            yield f"data: {json.dumps({'type': 'error', 'message': str(e)}, ensure_ascii=False)}\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
        },
    )
