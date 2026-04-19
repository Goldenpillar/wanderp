"""
推荐 API 路由

提供美食推荐和景区推荐相关接口。
"""

import logging
from typing import Optional

from fastapi import APIRouter, HTTPException, Query

from app.models.activity import ActivityRecommendation
from app.models.restaurant import RestaurantRecommendation

logger = logging.getLogger(__name__)

router = APIRouter()


@router.get("/food", response_model=list[RestaurantRecommendation], summary="美食推荐")
async def recommend_food(
    city: str = Query(..., description="城市名称"),
    lat: Optional[float] = Query(None, description="纬度"),
    lng: Optional[float] = Query(None, description="经度"),
    taste: Optional[str] = Query(None, description="口味偏好(如: 川菜、粤菜、日料)"),
    budget_min: Optional[float] = Query(None, description="最低人均预算"),
    budget_max: Optional[float] = Query(None, description="最高人均预算"),
    radius: float = Query(5000, description="搜索半径(米)"),
    limit: int = Query(10, ge=1, le=50, description="返回数量"),
) -> list[RestaurantRecommendation]:
    """
    美食推荐接口

    根据用户位置、口味偏好、预算等条件推荐餐厅。
    支持基于距离、口味匹配度、评分的综合排序。

    Args:
        city: 城市名称
        lat: 纬度坐标
        lng: 经度坐标
        taste: 口味偏好
        budget_min: 最低人均预算
        budget_max: 最高人均预算
        radius: 搜索半径(米)
        limit: 返回数量

    Returns:
        推荐餐厅列表
    """
    logger.info(f"美食推荐请求: city={city}, taste={taste}, budget=[{budget_min}, {budget_max}]")

    try:
        from app.core.recommender.food_recommender import FoodRecommender

        recommender = FoodRecommender()
        results = await recommender.recommend(
            city=city,
            lat=lat,
            lng=lng,
            taste_preference=taste,
            budget_min=budget_min,
            budget_max=budget_max,
            radius=radius,
            limit=limit,
        )
        return results

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"美食推荐失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="美食推荐服务暂时不可用")


@router.get("/scenic", response_model=list[ActivityRecommendation], summary="景区推荐")
async def recommend_scenic(
    city: str = Query(..., description="城市名称"),
    lat: Optional[float] = Query(None, description="纬度"),
    lng: Optional[float] = Query(None, description="经度"),
    category: Optional[str] = Query(None, description="景区类别(如: 自然风光、历史古迹、主题乐园)"),
    mood: Optional[str] = Query(None, description="心情偏好(如: 放松、冒险、浪漫)"),
    weather: Optional[str] = Query(None, description="天气状况(如: 晴、雨、阴)"),
    limit: int = Query(10, ge=1, le=50, description="返回数量"),
) -> list[ActivityRecommendation]:
    """
    景区推荐接口

    根据城市、类别偏好、心情、天气等条件推荐景区。
    结合天气状况智能调整推荐策略。

    Args:
        city: 城市名称
        lat: 纬度坐标
        lng: 经度坐标
        category: 景区类别
        mood: 心情偏好
        weather: 天气状况
        limit: 返回数量

    Returns:
        推荐景区列表
    """
    logger.info(f"景区推荐请求: city={city}, category={category}, mood={mood}")

    try:
        from app.core.recommender.scenic_recommender import ScenicRecommender

        recommender = ScenicRecommender()
        results = await recommender.recommend(
            city=city,
            lat=lat,
            lng=lng,
            category=category,
            mood=mood,
            weather=weather,
            limit=limit,
        )
        return results

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"景区推荐失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="景区推荐服务暂时不可用")


@router.get("/hybrid", summary="综合推荐")
async def hybrid_recommend(
    city: str = Query(..., description="城市名称"),
    lat: Optional[float] = Query(None, description="纬度"),
    lng: Optional[float] = Query(None, description="经度"),
    time_slot: str = Query(..., description="时间段(如: morning, afternoon, evening)"),
    energy_level: int = Query(5, ge=1, le=10, description="体力等级(1-10)"),
    limit: int = Query(10, ge=1, le=50, description="返回数量"),
) -> dict:
    """
    综合推荐接口

    根据时间段、体力等级等上下文信息，综合推荐适合的美食和景区。

    Args:
        city: 城市名称
        lat: 纬度坐标
        lng: 经度坐标
        time_slot: 时间段
        energy_level: 体力等级
        limit: 返回数量

    Returns:
        包含美食和景区的综合推荐结果
    """
    logger.info(f"综合推荐请求: city={city}, time_slot={time_slot}, energy={energy_level}")

    try:
        from app.core.recommender.hybrid_recommender import HybridRecommender

        recommender = HybridRecommender()
        results = await recommender.recommend(
            city=city,
            lat=lat,
            lng=lng,
            time_slot=time_slot,
            energy_level=energy_level,
            limit=limit,
        )
        return results

    except Exception as e:
        logger.error(f"综合推荐失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="推荐服务暂时不可用")
