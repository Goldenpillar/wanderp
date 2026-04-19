"""
高德地图 API 服务封装

封装高德地图API调用，提供POI搜索、路线规划、地理编码等功能。
"""

import hashlib
import logging
import time
import urllib.parse
from typing import Optional

import httpx

from app.config import get_settings

logger = logging.getLogger(__name__)


class AmapService:
    """
    高德地图 API 服务

    提供以下功能：
    1. POI搜索（关键词搜索、周边搜索）
    2. 路线规划（驾车、步行、公交、骑行）
    3. 地理编码/逆地理编码
    4. 距离计算
    """

    BASE_URL = "https://restapi.amap.com/v3"

    def __init__(self):
        """初始化高德地图服务"""
        self.settings = get_settings()
        self.api_key = self.settings.amap.amap_api_key
        self.secret_key = self.settings.amap.amap_secret_key

    def _sign(self, params: dict) -> str:
        """
        生成API签名

        Args:
            params: 请求参数

        Returns:
            签名字符串
        """
        if not self.secret_key:
            return ""

        # 按key排序拼接
        sorted_params = sorted(params.items())
        query_string = "&".join(f"{k}={v}" for k, v in sorted_params)
        # 拼接密钥
        sign_str = query_string + self.secret_key
        # MD5签名
        return hashlib.md5(sign_str.encode()).hexdigest()

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

        # 生成签名
        sign = self._sign(request_params)
        if sign:
            request_params["sig"] = sign

        last_error = None
        for attempt in range(max_retries):
            try:
                async with httpx.AsyncClient(timeout=10.0) as client:
                    response = await client.get(url, params=request_params)
                    response.raise_for_status()
                    data = response.json()

                    if data.get("status") == "1":
                        return data
                    else:
                        error_msg = f"高德API错误: info={data.get('info')}, code={data.get('infocode')}"
                        logger.warning(error_msg)
                        raise RuntimeError(error_msg)

            except httpx.HTTPError as e:
                last_error = e
                if attempt < max_retries - 1:
                    logger.warning(f"高德API请求失败，第{attempt + 1}次重试: {e}")
                    await asyncio.sleep(1.0 * (attempt + 1))

        raise RuntimeError(f"高德API请求失败: {last_error}")

    async def search_pois(
        self,
        keywords: str,
        city: Optional[str] = None,
        lat: Optional[float] = None,
        lng: Optional[float] = None,
        radius: Optional[float] = None,
        limit: int = 20,
    ) -> list[dict]:
        """
        搜索POI（兴趣点）

        Args:
            keywords: 搜索关键词
            city: 城市名称
            lat: 中心点纬度
            lng: 中心点经度
            radius: 搜索半径(米)
            limit: 返回数量

        Returns:
            POI列表
        """
        params = {
            "keywords": keywords,
            "offset": limit,
            "output": "JSON",
        }

        if city:
            params["city"] = city
        if lat is not None and lng is not None:
            params["location"] = f"{lng},{lat}"
            if radius:
                params["radius"] = str(int(radius))

        data = await self._request("place/text", params)
        pois = data.get("pois", [])

        # 格式化POI数据
        results = []
        for poi in pois:
            location = poi.get("location", "").split(",")
            result = {
                "name": poi.get("name", ""),
                "type": poi.get("type", ""),
                "address": poi.get("address", ""),
                "lat": float(location[1]) if len(location) == 2 else None,
                "lng": float(location[0]) if len(location) == 2 else None,
                "tel": poi.get("tel", ""),
                "rating": poi.get("rating"),
                "cost": poi.get("cost"),
            }
            results.append(result)

        return results

    async def search_nearby(
        self,
        keywords: str,
        lat: float,
        lng: float,
        radius: float = 3000,
        limit: int = 20,
    ) -> list[dict]:
        """
        周边搜索

        Args:
            keywords: 搜索关键词
            lat: 中心点纬度
            lng: 中心点经度
            radius: 搜索半径(米)
            limit: 返回数量

        Returns:
            POI列表
        """
        return await self.search_pois(
            keywords=keywords,
            lat=lat,
            lng=lng,
            radius=radius,
            limit=limit,
        )

    async def geocode(self, address: str, city: Optional[str] = None) -> Optional[dict]:
        """
        地理编码：地址 -> 坐标

        Args:
            address: 地址文本
            city: 城市名称

        Returns:
            地理编码结果
        """
        params = {"address": address}
        if city:
            params["city"] = city

        data = await self._request("geocode/geo", params)
        geocodes = data.get("geocodes", [])

        if geocodes:
            location = geocodes[0].get("location", "").split(",")
            return {
                "address": geocodes[0].get("formatted_address", ""),
                "lat": float(location[1]) if len(location) == 2 else None,
                "lng": float(location[0]) if len(location) == 2 else None,
                "city": geocodes[0].get("city", ""),
                "district": geocodes[0].get("district", ""),
            }
        return None

    async def reverse_geocode(self, lat: float, lng: float) -> Optional[dict]:
        """
        逆地理编码：坐标 -> 地址

        Args:
            lat: 纬度
            lng: 经度

        Returns:
            逆地理编码结果
        """
        data = await self._request("geocode/regeo", {
            "location": f"{lng},{lat}",
        })
        regeocode = data.get("regeocode", {})

        if regeocode:
            return {
                "address": regeocode.get("formatted_address", ""),
                "city": regeocode.get("addressComponent", {}).get("city", ""),
                "district": regeocode.get("addressComponent", {}).get("district", ""),
            }
        return None

    async def get_route(
        self,
        origin_lat: float,
        origin_lng: float,
        dest_lat: float,
        dest_lng: float,
        mode: str = "driving",
    ) -> dict:
        """
        路线规划

        Args:
            origin_lat: 起点纬度
            origin_lng: 起点经度
            dest_lat: 终点纬度
            dest_lng: 终点经度
            mode: 出行方式 (driving/walking/transit/bicycling)

        Returns:
            路线规划结果
        """
        endpoint_map = {
            "driving": "direction/driving",
            "walking": "direction/walking",
            "transit": "direction/transit/integrated",
            "bicycling": "direction/bicycling",
        }
        endpoint = endpoint_map.get(mode, "direction/driving")

        data = await self._request(endpoint, {
            "origin": f"{origin_lng},{origin_lat}",
            "destination": f"{dest_lng},{dest_lat}",
        })

        return data

    async def get_distance(
        self,
        origins: list[tuple[float, float]],
        destination: tuple[float, float],
        mode: str = "driving",
    ) -> list[dict]:
        """
        距离计算

        Args:
            origins: 起点坐标列表 [(lat, lng), ...]
            destination: 终点坐标 (lat, lng)
            mode: 出行方式

        Returns:
            距离结果列表
        """
        origins_str = ";".join(f"{lng},{lat}" for lat, lng in origins)
        dest_str = f"{destination[1]},{destination[0]}"

        data = await self._request("distance", {
            "origins": origins_str,
            "destination": dest_str,
            "type": mode,
        })

        return data.get("results", [])
