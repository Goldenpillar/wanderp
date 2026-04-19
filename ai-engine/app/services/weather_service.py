"""
和风天气 API 服务封装

封装和风天气API调用，提供实时天气、天气预报等功能。
"""

import logging
from typing import Optional

import httpx

from app.config import get_settings

logger = logging.getLogger(__name__)


class WeatherService:
    """
    和风天气 API 服务

    提供以下功能：
    1. 实时天气查询
    2. 天气预报查询
    3. 生活指数查询
    4. 城市搜索
    """

    def __init__(self):
        """初始化天气服务"""
        self.settings = get_settings()
        self.base_url = self.settings.weather.qweather_base_url
        self.api_key = self.settings.weather.qweather_api_key

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

        Raises:
            RuntimeError: API调用失败
        """
        import asyncio

        url = f"{self.base_url}/{endpoint}"
        query_params = {"key": self.api_key}
        if params:
            query_params.update(params)

        last_error = None
        for attempt in range(max_retries):
            try:
                async with httpx.AsyncClient(timeout=10.0) as client:
                    response = await client.get(url, params=query_params)
                    response.raise_for_status()
                    data = response.json()

                    if data.get("code") == "200":
                        return data
                    else:
                        error_msg = f"天气API错误: code={data.get('code')}"
                        logger.warning(error_msg)
                        raise RuntimeError(error_msg)

            except httpx.HTTPError as e:
                last_error = e
                if attempt < max_retries - 1:
                    logger.warning(f"天气API请求失败，第{attempt + 1}次重试: {e}")
                    await asyncio.sleep(1.0 * (attempt + 1))

        raise RuntimeError(f"天气API请求失败: {last_error}")

    async def get_current_weather(self, city: str) -> dict:
        """
        获取实时天气

        Args:
            city: 城市名称（需要先通过城市搜索获取location_id）

        Returns:
            实时天气数据
        """
        # 先搜索城市获取location_id
        location_id = await self._search_city(city)
        if not location_id:
            raise RuntimeError(f"未找到城市: {city}")

        data = await self._request("weather/now", {"location": location_id})
        return data.get("now", {})

    async def get_weather_forecast(self, city: str, days: int = 3) -> list[dict]:
        """
        获取天气预报

        Args:
            city: 城市名称
            days: 预报天数（1-7）

        Returns:
            天气预报列表
        """
        location_id = await self._search_city(city)
        if not location_id:
            raise RuntimeError(f"未找到城市: {city}")

        days = min(max(days, 1), 7)
        data = await self._request("weather/{days}d", {"location": location_id})
        return data.get("daily", [])

    async def get_living_indices(self, city: str) -> list[dict]:
        """
        获取生活指数

        Args:
            city: 城市名称

        Returns:
            生活指数列表
        """
        location_id = await self._search_city(city)
        if not location_id:
            raise RuntimeError(f"未找到城市: {city}")

        data = await self._request("indices/1d", {
            "location": location_id,
            "type": "0",  # 全部类型
        })
        return data.get("daily", [])

    async def _search_city(self, city: str) -> Optional[str]:
        """
        搜索城市获取location_id

        Args:
            city: 城市名称

        Returns:
            城市location_id，未找到返回None
        """
        try:
            data = await self._request("geo/citylookup", {"location": city})
            locations = data.get("location", [])
            if locations:
                return locations[0].get("id")
            return None
        except Exception as e:
            logger.warning(f"城市搜索失败: {city}, error={e}")
            return None
