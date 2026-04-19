"""
推荐 API 路由

提供美食推荐和景区推荐相关接口。
Mock 模式下从本地 Mock 数据返回推荐结果。
"""

import logging
from typing import Optional

from fastapi import APIRouter, HTTPException, Query

from app.config import get_settings
from app.models.activity import ActivityRecommendation
from app.models.restaurant import Restaurant, RestaurantRecommendation

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
    Mock 模式下从本地数据返回推荐结果。

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

    settings = get_settings()

    try:
        if settings.app.use_mock_data:
            # Mock 模式：从本地数据返回
            return _mock_recommend_food(city, taste, budget_min, budget_max, limit)
        else:
            # 正常模式
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
    Mock 模式下从本地数据返回推荐结果。

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

    settings = get_settings()

    try:
        if settings.app.use_mock_data:
            # Mock 模式：从本地数据返回
            return _mock_recommend_scenic(city, category, mood, weather, limit)
        else:
            # 正常模式
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
    Mock 模式下从本地数据返回推荐结果。

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

    settings = get_settings()

    try:
        if settings.app.use_mock_data:
            # Mock 模式：从本地数据返回综合推荐
            from app.core.mock_data_loader import get_scenic_spots, get_restaurants

            spots = get_scenic_spots(city)[:limit]
            restaurants = get_restaurants(city)[:limit]

            # 根据时间段筛选
            if time_slot == "morning":
                spots = [s for s in spots if "博物馆" not in s.get("type", "")]
            elif time_slot == "evening":
                restaurants = [r for r in restaurants if r.get("avg_price", 0) > 50]

            return {
                "city": city,
                "time_slot": time_slot,
                "energy_level": energy_level,
                "food_recommendations": [
                    {
                        "name": r.get("name", ""),
                        "cuisine": r.get("cuisine", r.get("cuisine_type", "")),
                        "avg_price": r.get("avg_price", 0),
                        "rating": r.get("rating", 0),
                        "reason": f"评分{r.get('rating', 0)}分，{r.get('cuisine', r.get('cuisine_type', ''))}代表",
                    }
                    for r in restaurants
                ],
                "scenic_recommendations": [
                    {
                        "name": s.get("name", ""),
                        "type": s.get("type", ""),
                        "rating": s.get("rating", 0),
                        "ticket_price": s.get("ticket_price_num", s.get("ticket_price", 0)),
                        "reason": f"评分{s.get('rating', 0)}分，{s.get('type', '')}类景点",
                    }
                    for s in spots
                ],
            }
        else:
            # 正常模式
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


# ============================================================
# Mock 模式辅助函数
# ============================================================

def _mock_recommend_food(
    city: str,
    taste: Optional[str],
    budget_min: Optional[float],
    budget_max: Optional[float],
    limit: int,
) -> list[RestaurantRecommendation]:
    """
    Mock 模式下的美食推荐

    Args:
        city: 城市名称
        taste: 口味偏好
        budget_min: 最低预算
        budget_max: 最高预算
        limit: 返回数量

    Returns:
        餐厅推荐列表
    """
    from app.core.mock_data_loader import get_restaurants

    restaurants = get_restaurants(city, cuisine=taste, max_price=budget_max)

    results = []
    for i, r in enumerate(restaurants[:limit]):
        # 计算匹配分数
        match_score = min(1.0, r.get("rating", 4.0) / 5.0)

        # 偏好匹配加分
        if taste:
            cuisine = r.get("cuisine", r.get("cuisine_type", ""))
            if taste in cuisine:
                match_score = min(1.0, match_score + 0.2)

        restaurant = Restaurant(
            restaurant_id=f"mock_r_{i}",
            name=r.get("name", ""),
            cuisine=r.get("cuisine", r.get("cuisine_type", "")),
            description=r.get("description", ""),
            address=r.get("address", ""),
            lat=r.get("latitude"),
            lng=r.get("longitude"),
            avg_price=r.get("avg_price", 0),
            rating=r.get("rating"),
            tags=r.get("cuisine", r.get("cuisine_type", "")).split("/"),
            recommend_dishes=r.get("signature_dishes", "").split("、") if isinstance(r.get("signature_dishes"), str) else r.get("signature_dishes", []),
        )

        results.append(RestaurantRecommendation(
            restaurant=restaurant,
            match_score=round(match_score, 2),
            match_details={
                "rating_match": round(r.get("rating", 4.0) / 5.0, 2),
                "budget_match": 1.0 if not budget_max or r.get("avg_price", 0) <= budget_max else 0.5,
            },
            reason=f"评分{r.get('rating', 'N/A')}，人均{r.get('avg_price', 0)}元，{r.get('cuisine', r.get('cuisine_type', ''))}",
        ))

    return results


def _mock_recommend_scenic(
    city: str,
    category: Optional[str],
    mood: Optional[str],
    weather: Optional[str],
    limit: int,
) -> list[ActivityRecommendation]:
    """
    Mock 模式下的景区推荐

    Args:
        city: 城市名称
        category: 景区类别
        mood: 心情偏好
        weather: 天气状况
        limit: 返回数量

    Returns:
        景区推荐列表
    """
    from app.core.mock_data_loader import get_scenic_spots

    spots = get_scenic_spots(city)

    # 按类别筛选
    if category:
        spots = [s for s in spots if category in s.get("type", "") or category in s.get("description", "")]

    # 天气适配
    if weather == "雨":
        # 下雨天优先推荐室内景点
        indoor_spots = [s for s in spots if any(k in s.get("type", "") for k in ["博物馆", "文化", "历史"])]
        if indoor_spots:
            spots = indoor_spots + [s for s in spots if s not in indoor_spots]

    results = []
    for i, s in enumerate(spots[:limit]):
        from app.models.activity import Activity

        match_score = min(1.0, s.get("rating", 4.0) / 5.0)

        activity = Activity(
            activity_id=f"mock_s_{i}",
            name=s.get("name", ""),
            activity_type="scenic",
            categories=s.get("type", "").split("/"),
            description=s.get("description", ""),
            address=s.get("address", ""),
            lat=s.get("latitude"),
            lng=s.get("longitude"),
            rating=s.get("rating"),
            ticket_price=s.get("ticket_price_num", 0),
            open_hours=s.get("open_time", ""),
            duration_minutes=120,
            tags=s.get("type", "").split("/"),
            tips=[s.get("tips", "")] if s.get("tips") else [],
        )

        results.append(ActivityRecommendation(
            activity=activity,
            match_score=round(match_score, 2),
            match_details={
                "rating_match": round(s.get("rating", 4.0) / 5.0, 2),
                "category_match": 1.0 if category and category in s.get("type", "") else 0.5,
            },
            reason=f"评分{s.get('rating', 'N/A')}，{s.get('type', '')}，{s.get('description', '')[:30]}...",
        ))

    return results
