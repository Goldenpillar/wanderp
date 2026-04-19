"""
飞猪开放平台 API 服务封装

封装飞猪开放平台API调用，提供机票、酒店、门票等查询和预订功能。
"""

import hashlib
import hmac
import json
import logging
import time
import uuid
from typing import Optional

import httpx

from app.config import get_settings

logger = logging.getLogger(__name__)


class FeizhuService:
    """
    飞猪开放平台 API 服务

    提供以下功能：
    1. 机票查询
    2. 酒店查询
    3. 景区门票查询
    4. 火车票查询

    注意：飞猪开放平台需要企业认证和签名验证。
    """

    BASE_URL = "https://api.alibaba.com/openapi"

    def __init__(self):
        """初始化飞猪服务"""
        self.settings = get_settings()
        self.app_key = self.settings.feizhu.feizhu_app_key
        self.app_secret = self.settings.feizhu.feizhu_app_secret

    def _generate_sign(self, params: dict) -> str:
        """
        生成API签名（HMAC-MD5）

        Args:
            params: 请求参数

        Returns:
            签名字符串
        """
        # 按key排序
        sorted_params = sorted(params.items())
        # 拼接参数
        query_string = "&".join(f"{k}{v}" for k, v in sorted_params)
        # HMAC-MD5签名
        sign = hmac.new(
            self.app_secret.encode(),
            query_string.encode(),
            hashlib.md5,
        ).hexdigest().upper()
        return sign

    def _build_common_params(self, method: str) -> dict:
        """
        构建公共请求参数

        Args:
            method: API方法名

        Returns:
            公共参数字典
        """
        return {
            "app_key": self.app_key,
            "method": method,
            "v": "2.0",
            "sign_method": "hmac",
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
            "format": "json",
            "partner_id": self.app_key,
        }

    async def _request(
        self,
        method: str,
        biz_params: Optional[dict] = None,
        max_retries: int = 3,
    ) -> dict:
        """
        发送API请求

        Args:
            method: API方法名
            biz_params: 业务参数
            max_retries: 最大重试次数

        Returns:
            API响应字典
        """
        import asyncio

        # 构建请求参数
        params = self._build_common_params(method)
        if biz_params:
            params["biz_content"] = json.dumps(biz_params, ensure_ascii=False)

        # 生成签名
        params["sign"] = self._generate_sign(params)

        last_error = None
        for attempt in range(max_retries):
            try:
                async with httpx.AsyncClient(timeout=15.0) as client:
                    response = await client.post(
                        self.BASE_URL,
                        data=params,
                    )
                    response.raise_for_status()
                    data = response.json()

                    # 检查响应状态
                    if data.get("error_response"):
                        error = data["error_response"]
                        error_msg = f"飞猪API错误: code={error.get('code')}, msg={error.get('msg')}"
                        logger.warning(error_msg)
                        raise RuntimeError(error_msg)

                    return data

            except httpx.HTTPError as e:
                last_error = e
                if attempt < max_retries - 1:
                    logger.warning(f"飞猪API请求失败，第{attempt + 1}次重试: {e}")
                    await asyncio.sleep(2.0 * (attempt + 1))

        raise RuntimeError(f"飞猪API请求失败: {last_error}")

    async def search_flights(
        self,
        departure_city: str,
        arrival_city: str,
        departure_date: str,
        adults: int = 1,
    ) -> dict:
        """
        搜索机票

        Args:
            departure_city: 出发城市
            arrival_city: 到达城市
            departure_date: 出发日期 (YYYY-MM-DD)
            adults: 成人数量

        Returns:
            机票搜索结果
        """
        return await self._request(
            "alitrip.trip.search.flight",
            {
                "departure_city": departure_city,
                "arrival_city": arrival_city,
                "departure_date": departure_date,
                "adult_count": adults,
            },
        )

    async def search_hotels(
        self,
        city: str,
        check_in: str,
        check_out: str,
        guests: int = 2,
    ) -> dict:
        """
        搜索酒店

        Args:
            city: 城市名称
            check_in: 入住日期
            check_out: 离店日期
            guests: 入住人数

        Returns:
            酒店搜索结果
        """
        return await self._request(
            "alitrip.hotel.search",
            {
                "city": city,
                "check_in": check_in,
                "check_out": check_out,
                "guest_count": guests,
            },
        )

    async def search_scenic_tickets(
        self,
        city: str,
        scenic_name: Optional[str] = None,
        visit_date: Optional[str] = None,
    ) -> dict:
        """
        搜索景区门票

        Args:
            city: 城市名称
            scenic_name: 景区名称
            visit_date: 游览日期

        Returns:
            门票搜索结果
        """
        params = {"city": city}
        if scenic_name:
            params["scenic_name"] = scenic_name
        if visit_date:
            params["visit_date"] = visit_date

        return await self._request(
            "alitrip.scenic.ticket.search",
            params,
        )

    async def search_trains(
        self,
        departure_city: str,
        arrival_city: str,
        departure_date: str,
    ) -> dict:
        """
        搜索火车票

        Args:
            departure_city: 出发城市
            arrival_city: 到达城市
            departure_date: 出发日期

        Returns:
            火车票搜索结果
        """
        return await self._request(
            "alitrip.train.search",
            {
                "departure_city": departure_city,
                "arrival_city": arrival_city,
                "departure_date": departure_date,
            },
        )
