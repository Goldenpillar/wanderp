"""
Mock 数据加载器

从本地 JSON 文件加载杭州、北京等城市的景区、餐厅、演出、天气、交通数据，
提供统一的查询接口，替代外部 API 调用。

所有数据来源于 data/mock/ 目录下的 JSON 文件。
"""

import json
import logging
import os
from typing import Optional

logger = logging.getLogger(__name__)

# Mock 数据文件目录
_MOCK_DATA_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "data", "mock"
)

# 城市名称到文件名的映射
_CITY_FILE_MAP = {
    "杭州": "hangzhou_data.json",
    "北京": "beijing_data.json",
    "hangzhou": "hangzhou_data.json",
    "beijing": "beijing_data.json",
}

# 交通数据文件映射
_TRANSPORT_FILE_MAP = {
    ("杭州", "北京"): "transport_hangzhou_beijing.json",
    ("北京", "杭州"): "transport_hangzhou_beijing.json",
    ("hangzhou", "beijing"): "transport_hangzhou_beijing.json",
    ("beijing", "hangzhou"): "transport_hangzhou_beijing.json",
}

# 内存缓存：避免重复读取文件
_data_cache: dict[str, dict] = {}


def _load_json(filename: str) -> dict:
    """
    加载 JSON 文件并缓存结果

    Args:
        filename: JSON 文件名

    Returns:
        解析后的字典数据
    """
    if filename in _data_cache:
        return _data_cache[filename]

    filepath = os.path.join(_MOCK_DATA_DIR, filename)
    if not os.path.exists(filepath):
        logger.warning(f"Mock 数据文件不存在: {filepath}")
        return {}

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            data = json.load(f)
        _data_cache[filename] = data
        logger.info(f"成功加载 Mock 数据: {filename}")
        return data
    except Exception as e:
        logger.error(f"加载 Mock 数据失败: {filename}, 错误: {e}")
        return {}


def _normalize_city(city: str) -> str:
    """
    标准化城市名称（支持中英文）

    Args:
        city: 城市名称

    Returns:
        标准化后的城市名称
    """
    city_lower = city.lower().strip()
    # 中文映射
    if city in _CITY_FILE_MAP:
        return city
    # 英文映射
    if city_lower in _CITY_FILE_MAP:
        return city_lower
    # 尝试模糊匹配
    for key in _CITY_FILE_MAP:
        if key in city or city in key:
            return key
    return city


def _get_city_data(city: str) -> dict:
    """
    获取指定城市的全部数据

    Args:
        city: 城市名称

    Returns:
        城市数据字典
    """
    normalized = _normalize_city(city)
    filename = _CITY_FILE_MAP.get(normalized)
    if not filename:
        logger.warning(f"未找到城市数据: {city}")
        return {}
    return _load_json(filename)


# ============================================================
# 统一查询接口
# ============================================================

def get_scenic_spots(city: str) -> list[dict]:
    """
    获取指定城市的景区列表，按评分降序排列

    Args:
        city: 城市名称

    Returns:
        景区列表，每个元素为包含景区信息的字典
    """
    data = _get_city_data(city)
    spots = data.get("scenic_spots", [])
    # 按评分降序排列
    spots_sorted = sorted(spots, key=lambda x: x.get("rating", 0), reverse=True)
    return spots_sorted


def get_restaurants(
    city: str,
    cuisine: Optional[str] = None,
    max_price: Optional[float] = None,
    min_price: Optional[float] = None,
    district: Optional[str] = None,
) -> list[dict]:
    """
    获取指定城市的餐厅列表，支持按菜系、价格、区域筛选

    Args:
        city: 城市名称
        cuisine: 菜系类型（如"浙菜"、"北京菜"）
        max_price: 最高人均价格
        min_price: 最低人均价格
        district: 区域筛选

    Returns:
        餐厅列表，按评分降序排列
    """
    data = _get_city_data(city)
    restaurants = data.get("restaurants", [])

    # 按菜系筛选
    if cuisine:
        restaurants = [
            r for r in restaurants
            if cuisine in r.get("cuisine", "") or cuisine in r.get("cuisine_type", "")
        ]

    # 按价格区间筛选
    if max_price is not None:
        restaurants = [r for r in restaurants if r.get("avg_price", 0) <= max_price]
    if min_price is not None:
        restaurants = [r for r in restaurants if r.get("avg_price", 0) >= min_price]

    # 按区域筛选（通过地址模糊匹配）
    if district:
        restaurants = [
            r for r in restaurants
            if district in r.get("address", "")
        ]

    # 按评分降序排列
    restaurants_sorted = sorted(restaurants, key=lambda x: x.get("rating", 0), reverse=True)
    return restaurants_sorted


def get_events(city: str) -> list[dict]:
    """
    获取指定城市的演出/活动列表

    Args:
        city: 城市名称

    Returns:
        演出列表
    """
    data = _get_city_data(city)
    events = data.get("events", [])
    return events


def get_weather(city: str) -> dict:
    """
    获取指定城市的天气信息

    Args:
        city: 城市名称

    Returns:
        天气信息字典
    """
    data = _get_city_data(city)
    return data.get("weather", {})


def get_transport(from_city: str, to_city: str) -> dict:
    """
    获取两个城市之间的交通信息

    Args:
        from_city: 出发城市
        to_city: 目的城市

    Returns:
        交通信息字典（包含火车、航班、自驾等）
    """
    key = (_normalize_city(from_city), _normalize_city(to_city))
    filename = _TRANSPORT_FILE_MAP.get(key)
    if not filename:
        logger.warning(f"未找到交通数据: {from_city} -> {to_city}")
        return {}
    return _load_json(filename)


def search_poi(city: str, keyword: str) -> list[dict]:
    """
    在指定城市中搜索 POI（兴趣点），支持关键词模糊匹配

    Args:
        city: 城市名称
        keyword: 搜索关键词

    Returns:
        匹配的 POI 列表
    """
    results = []
    keyword_lower = keyword.lower()

    # 搜索景区
    for spot in get_scenic_spots(city):
        name = spot.get("name", "")
        desc = spot.get("description", "") or ""
        spot_type = spot.get("type", "") or ""
        if keyword_lower in name.lower() or keyword_lower in desc.lower() or keyword_lower in spot_type.lower():
            results.append({**spot, "_source": "scenic"})

    # 搜索餐厅
    for restaurant in get_restaurants(city):
        name = restaurant.get("name", "")
        desc = restaurant.get("description", "") or ""
        cuisine = restaurant.get("cuisine", "") or restaurant.get("cuisine_type", "")
        if keyword_lower in name.lower() or keyword_lower in desc.lower() or keyword_lower in cuisine.lower():
            results.append({**restaurant, "_source": "restaurant"})

    # 搜索演出
    for event in get_events(city):
        name = event.get("name", "")
        desc = event.get("description", "") or ""
        event_type = event.get("type", "") or ""
        if keyword_lower in name.lower() or keyword_lower in desc.lower() or keyword_lower in event_type.lower():
            results.append({**event, "_source": "event"})

    return results


def get_available_cities() -> list[dict]:
    """
    获取所有可用的城市列表

    Returns:
        城市信息列表
    """
    cities = []
    seen_files = set()
    for city_name, filename in _CITY_FILE_MAP.items():
        # 避免重复（同一文件只处理一次）
        if filename in seen_files:
            continue
        seen_files.add(filename)
        data = _load_json(filename)
        if data:
            cities.append({
                "name": data.get("city", city_name),
                "scenic_count": len(data.get("scenic_spots", [])),
                "restaurant_count": len(data.get("restaurants", [])),
                "event_count": len(data.get("events", [])),
            })
    return cities


def get_city_transport_info(city: str) -> dict:
    """
    获取指定城市的市内交通信息

    Args:
        city: 城市名称

    Returns:
        市内交通信息字典
    """
    data = _get_city_data(city)
    return data.get("transport", {})
