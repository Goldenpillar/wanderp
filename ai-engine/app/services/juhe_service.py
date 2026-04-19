"""
聚合数据 API 服务封装

封装聚合数据API调用，提供美食搜索、酒店查询等功能。
"""

import logging
from typing import Optional

import httpx

from app.config import get_settings

logger = logging.getLogger(__name__)


class JuheService:
    """
    聚合数据 API 服务

    提供以下功能：
    1. 美食搜索
    2. 酒店查询
    3. 景点查询
    4. 新闻/资讯获取
    """

    BASE_URL = "http://v.juhe.cn"

    def __init__(self):
        """初始化聚合数据服务"""
        self.settings = get_settings()
        self.api_key = self.settings.juhe.juhe_api_key

    async def _request(
        self,
        endpoint: str,
        params: Optional[dict] = None,
        max_retries: int = 3,
    ) -> dict:
        """
        发送API请求

        Args:
            endpoint: API端点
            params: 请求参数
            max_retries: 最大重试次数

        Returns:
            API响应字典
        """
        import asyncio

        url = f"{self.BASE_URL}/{endpoint}"
        request_params = {"key": self.api_key}
        if params:
            request_params.update(params)

        last_error = None
        for attempt in range(max_retries):
            try:
                async with httpx.AsyncClient(timeout=10.0) as client:
                    response = await client.get(url, params=request_params)
                    response.raise_for_status()
                    data = response.json()

                    if data.get("error_code") == 0 or data.get("result"):
                        return data
                    else:
                        error_msg = f"聚合API错误: {data.get('reason', '未知错误')}"
                        logger.warning(error_msg)
                        raise RuntimeError(error_msg)

            except httpx.HTTPError as e:
                last_error = e
                if attempt < max_retries - 1:
                    logger.warning(f"聚合API请求失败，第{attempt + 1}次重试: {e}")
                    await asyncio.sleep(1.0 * (attempt + 1))

        raise RuntimeError(f"聚合API请求失败: {last_error}")

    async def search_restaurants(
        self,
        city: str,
        lat: Optional[float] = None,
        lng: Optional[float] = None,
        radius: float = 5000,
        keyword: Optional[str] = None,
        limit: int = 20,
    ) -> list:
        """
        搜索餐厅

        Args:
            city: 城市名称
            lat: 纬度
            lng: 经度
            radius: 搜索半径(米)
            keyword: 搜索关键词
            limit: 返回数量

        Returns:
            餐厅列表
        """
        from app.models.restaurant import Restaurant

        params = {
            "city": city,
            "rn": limit,
        }
        if keyword:
            params["keyword"] = keyword

        try:
            data = await self._request("life/dining/query", params)
            results = data.get("result", {}).get("data", [])

            restaurants = []
            for item in results:
                restaurant = Restaurant(
                    name=item.get("restaurantName", ""),
                    cuisine=item.get("cuisine", ""),
                    avg_price=item.get("avgPrice", 0),
                    rating=item.get("score"),
                    address=item.get("address", ""),
                    lat=item.get("lat"),
                    lng=item.get("lng"),
                    review_count=item.get("commentCount"),
                    tags=item.get("tags", "").split(",") if item.get("tags") else [],
                    description=item.get("description", ""),
                    phone=item.get("phone", ""),
                    open_hours=item.get("openTime", ""),
                )
                restaurants.append(restaurant)

            return restaurants

        except Exception as e:
            logger.error(f"搜索餐厅失败: {e}")
            return []

    async def search_hotels(
        self,
        city: str,
        check_in: str,
        check_out: str,
        limit: int = 10,
    ) -> list[dict]:
        """
        搜索酒店

        Args:
            city: 城市名称
            check_in: 入住日期 (YYYY-MM-DD)
            check_out: 离店日期 (YYYY-MM-DD)
            limit: 返回数量

        Returns:
            酒店列表
        """
        params = {
            "city": city,
            "checkIn": check_in,
            "checkOut": check_out,
            "rn": limit,
        }

        try:
            data = await self._request("hotel/query", params)
            return data.get("result", {}).get("data", [])
        except Exception as e:
            logger.error(f"搜索酒店失败: {e}")
            return []

    async def get_scenic_spots(
        self,
        city: str,
        limit: int = 20,
    ) -> list[dict]:
        """
        获取景点列表

        Args:
            city: 城市名称
            limit: 返回数量

        Returns:
            景点列表
        """
        params = {
            "city": city,
            "rn": limit,
        }

        try:
            data = await self._request("travel/scenic/query", params)
            return data.get("result", {}).get("data", [])
        except Exception as e:
            logger.error(f"获取景点失败: {e}")
            return []
