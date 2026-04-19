"""
行程规划 API 路由

提供智能行程规划相关接口，包括：
- 创建行程规划请求
- 获取行程规划结果
- 优化调整行程
- 获取行程详情
- 查询可用城市和景区/餐厅

Mock 模式下使用 LocalPlanner 替代 PlanOptimizer，
无需外部 LLM/Milvus/Redis 即可生成真实行程。

注意：路由注册顺序很重要！固定路径必须在动态路径 /{plan_id} 之前注册。
"""

import logging
from typing import Optional

from fastapi import APIRouter, BackgroundTasks, HTTPException, Query

from app.config import get_settings
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


# ============================================================
# 固定路径路由（必须在 /{plan_id} 之前注册）
# ============================================================

@router.post("/create", response_model=PlanResponse, summary="创建行程规划")
async def create_plan(
    request: PlanRequest,
    background_tasks: BackgroundTasks,
) -> PlanResponse:
    """
    创建智能行程规划

    根据用户输入的目的地、日期、偏好等信息生成行程方案。
    Mock 模式下使用本地规则引擎，无需外部 API。

    Args:
        request: 行程规划请求参数

    Returns:
        行程规划结果
    """
    logger.info(
        f"收到行程规划请求: 目的地={request.destination}, "
        f"天数={request.days}, 人数={len(request.travelers)}"
    )

    settings = get_settings()

    try:
        if settings.app.use_mock_data:
            # Mock 模式：使用 LocalPlanner
            from app.core.planner.local_planner import LocalPlanner

            planner = LocalPlanner()
            itinerary = planner.generate_itinerary(request)

            # 转换为 API 响应格式
            result = _itinerary_to_result(itinerary)
            plan_id = itinerary.plan_id

            return PlanResponse(
                plan_id=plan_id,
                status="completed",
                destination=request.destination,
                days=request.days,
                itinerary=result.get("itinerary", []),
                total_budget=result.get("total_budget", 0),
                total_cost=result.get("total_cost", 0),
                travelers_count=result.get("travelers_count", 1),
                tags=result.get("tags", []),
                warnings=result.get("warnings", []),
                tips=result.get("tips", []),
            )
        else:
            # 正常模式：使用 PlanOptimizer
            from app.core.planner.plan_optimizer import PlanOptimizer

            optimizer = PlanOptimizer()
            plan_id = await optimizer.create_plan(request)
            result = await optimizer.get_plan_result(plan_id)

            return PlanResponse(
                plan_id=plan_id,
                status="completed",
                destination=request.destination,
                days=request.days,
                itinerary=result.get("itinerary", []),
                total_budget=result.get("total_budget", 0),
                total_cost=result.get("total_cost", 0),
                travelers_count=result.get("travelers_count", 1),
                tags=result.get("tags", []),
                warnings=result.get("warnings", []),
                tips=result.get("tips", []),
            )

    except ValueError as e:
        logger.warning(f"行程规划参数错误: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"行程规划失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="行程规划服务暂时不可用，请稍后重试")


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
        raise HTTPException(status_code=500, detail="行程服务暂时不可用")


# ---- 城市和资源查询端点 ----

@router.get("/cities", summary="获取可用城市列表")
async def get_cities():
    """
    获取所有可用的城市列表及其数据概况

    Returns:
        城市信息列表
    """
    from app.core.mock_data_loader import get_available_cities

    cities = get_available_cities()
    return {"cities": cities, "total": len(cities)}


@router.get("/cities/{city}/spots", summary="获取城市景区列表")
async def get_city_spots(
    city: str,
    category: Optional[str] = Query(None, description="景区类别筛选"),
    limit: int = Query(20, ge=1, le=50, description="返回数量"),
):
    """
    获取指定城市的景区列表

    Args:
        city: 城市名称
        category: 景区类别（如"自然风光"、"历史古迹"）
        limit: 返回数量

    Returns:
        景区列表
    """
    from app.core.mock_data_loader import get_scenic_spots

    spots = get_scenic_spots(city)

    # 按类别筛选
    if category:
        spots = [s for s in spots if category in s.get("type", "") or category in s.get("description", "")]

    return {
        "city": city,
        "total": len(spots),
        "spots": spots[:limit],
    }


@router.get("/cities/{city}/restaurants", summary="获取城市餐厅列表")
async def get_city_restaurants(
    city: str,
    cuisine: Optional[str] = Query(None, description="菜系类型"),
    max_price: Optional[float] = Query(None, description="最高人均价格"),
    limit: int = Query(20, ge=1, le=50, description="返回数量"),
):
    """
    获取指定城市的餐厅列表

    Args:
        city: 城市名称
        cuisine: 菜系类型
        max_price: 最高人均价格
        limit: 返回数量

    Returns:
        餐厅列表
    """
    from app.core.mock_data_loader import get_restaurants

    restaurants = get_restaurants(city, cuisine=cuisine, max_price=max_price)

    return {
        "city": city,
        "total": len(restaurants),
        "restaurants": restaurants[:limit],
    }


@router.get("/transport", summary="查询城市间交通")
async def get_transport_info(
    from_city: str = Query(..., description="出发城市"),
    to_city: str = Query(..., description="目的城市"),
):
    """
    查询两个城市之间的交通信息（火车、航班、自驾）

    Args:
        from_city: 出发城市
        to_city: 目的城市

    Returns:
        交通信息
    """
    from app.core.mock_data_loader import get_transport

    transport = get_transport(from_city, to_city)
    if not transport:
        raise HTTPException(status_code=404, detail=f"未找到 {from_city} → {to_city} 的交通数据")

    return transport


# ============================================================
# 动态路径路由（必须放在最后）
# ============================================================

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


# ============================================================
# 辅助函数
# ============================================================

def _itinerary_to_result(itinerary) -> dict:
    """
    将 Itinerary 模型转换为 API 响应字典

    Args:
        itinerary: Itinerary 对象

    Returns:
        响应字典
    """
    return {
        "plan_id": itinerary.plan_id,
        "status": "completed",
        "destination": itinerary.destination,
        "days": itinerary.days,
        "start_date": str(itinerary.start_date) if itinerary.start_date else None,
        "end_date": str(itinerary.end_date) if itinerary.end_date else None,
        "itinerary": [dp.model_dump(mode='json') for dp in itinerary.day_plans],
        "total_budget": itinerary.total_budget,
        "total_cost": itinerary.total_cost,
        "travelers_count": itinerary.travelers_count,
        "tags": itinerary.tags,
        "tips": itinerary.tips,
        "warnings": itinerary.warnings,
    }
