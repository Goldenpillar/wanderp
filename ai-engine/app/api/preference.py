"""
偏好分析 API 路由

提供用户偏好分析、多人偏好聚合相关接口。
"""

import logging
from typing import Optional

from fastapi import APIRouter, HTTPException

from app.models.preference import (
    PreferenceAnalysisResponse,
    PreferenceInput,
    PreferenceProfile,
    TravelerPreferencesRequest,
)

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/analyze", response_model=PreferenceAnalysisResponse, summary="分析用户偏好")
async def analyze_preference(
    request: PreferenceInput,
) -> PreferenceAnalysisResponse:
    """
    分析单个用户的旅行偏好

    根据用户历史行为、问卷回答等信息，分析并生成用户偏好画像。

    Args:
        request: 偏好分析输入（包含用户行为数据或问卷回答）

    Returns:
        偏好分析结果
    """
    logger.info(f"偏好分析请求: user_id={request.user_id}")

    try:
        from app.core.recommender.preference_aggregator import PreferenceAggregator

        aggregator = PreferenceAggregator()
        profile = await aggregator.analyze_individual(request)

        return PreferenceAnalysisResponse(
            user_id=request.user_id,
            profile=profile,
            confidence=profile.confidence,
        )

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"偏好分析失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="偏好分析服务暂时不可用")


@router.post("/aggregate", response_model=PreferenceAnalysisResponse, summary="多人偏好聚合")
async def aggregate_preferences(
    request: TravelerPreferencesRequest,
) -> PreferenceAnalysisResponse:
    """
    多人偏好聚合

    当多个旅行者一起出行时，聚合各自的偏好，
    识别共同偏好区域和需要妥协的方面。

    Args:
        request: 多人偏好请求（包含所有旅行者的偏好信息）

    Returns:
        聚合后的偏好分析结果
    """
    logger.info(f"多人偏好聚合请求: {len(request.travelers)}人")

    try:
        from app.core.recommender.preference_aggregator import PreferenceAggregator

        aggregator = PreferenceAggregator()
        result = await aggregator.aggregate_group(request.travelers)

        return PreferenceAnalysisResponse(
            user_id="group",
            profile=result["profile"],
            confidence=result.get("confidence", 0.0),
            compromise_areas=result.get("compromise_areas", []),
            consensus_areas=result.get("consensus_areas", []),
        )

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"偏好聚合失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="偏好聚合服务暂时不可用")


@router.get("/profile/{user_id}", response_model=PreferenceProfile, summary="获取用户偏好画像")
async def get_preference_profile(user_id: str) -> PreferenceProfile:
    """
    获取用户的偏好画像

    从缓存或数据库中获取已分析的用户偏好画像。

    Args:
        user_id: 用户ID

    Returns:
        用户偏好画像
    """
    try:
        from app.core.recommender.preference_aggregator import PreferenceAggregator

        aggregator = PreferenceAggregator()
        profile = await aggregator.get_profile(user_id)

        if profile is None:
            raise HTTPException(status_code=404, detail="用户偏好画像不存在")

        return profile

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"获取偏好画像失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="偏好服务暂时不可用")


@router.put("/profile/{user_id}", response_model=PreferenceProfile, summary="更新用户偏好")
async def update_preference_profile(
    user_id: str,
    request: PreferenceInput,
) -> PreferenceProfile:
    """
    更新用户偏好画像

    根据新的行为数据更新用户偏好画像。

    Args:
        user_id: 用户ID
        request: 新的偏好数据

    Returns:
        更新后的偏好画像
    """
    logger.info(f"更新偏好画像: user_id={user_id}")

    try:
        from app.core.recommender.preference_aggregator import PreferenceAggregator

        aggregator = PreferenceAggregator()
        profile = await aggregator.update_profile(user_id, request)

        return profile

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"更新偏好画像失败: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="偏好服务暂时不可用")
