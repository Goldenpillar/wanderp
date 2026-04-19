"""
Redis 缓存工具

封装Redis操作，提供缓存读写、连接管理等功能。
"""

import json
import logging
from typing import Any, Optional

from app.config import get_settings

logger = logging.getLogger(__name__)

# 全局Redis客户端
_redis_client = None


async def get_redis_client():
    """
    获取Redis客户端单例

    Returns:
        Redis客户端实例
    """
    global _redis_client

    if _redis_client is not None:
        return _redis_client

    settings = get_settings()

    try:
        import redis.asyncio as aioredis

        _redis_client = aioredis.from_url(
            settings.redis.redis_url,
            encoding="utf-8",
            decode_responses=True,
            max_connections=20,
        )

        logger.info(f"Redis客户端创建成功: {settings.redis.redis_host}:{settings.redis.redis_port}")
        return _redis_client

    except ImportError:
        logger.warning("redis包未安装，缓存功能不可用")
        return None
    except Exception as e:
        logger.error(f"Redis客户端创建失败: {e}")
        return None


async def close_redis_client() -> None:
    """关闭Redis客户端连接"""
    global _redis_client

    if _redis_client is not None:
        try:
            await _redis_client.close()
            logger.info("Redis客户端已关闭")
        except Exception as e:
            logger.warning(f"关闭Redis客户端失败: {e}")
        finally:
            _redis_client = None


async def cache_get(key: str) -> Optional[Any]:
    """
    从缓存获取值

    Args:
        key: 缓存键

    Returns:
        缓存值，不存在返回None
    """
    client = await get_redis_client()
    if client is None:
        return None

    try:
        value = await client.get(key)
        if value is not None:
            try:
                return json.loads(value)
            except (json.JSONDecodeError, TypeError):
                return value
        return None
    except Exception as e:
        logger.warning(f"缓存读取失败: key={key}, error={e}")
        return None


async def cache_set(
    key: str,
    value: Any,
    ttl: Optional[int] = None,
) -> bool:
    """
    设置缓存值

    Args:
        key: 缓存键
        value: 缓存值
        ttl: 过期时间(秒)，None使用默认值

    Returns:
        是否设置成功
    """
    client = await get_redis_client()
    if client is None:
        return False

    try:
        settings = get_settings()
        if ttl is None:
            ttl = settings.redis.redis_ttl

        if isinstance(value, (dict, list)):
            serialized = json.dumps(value, ensure_ascii=False)
        else:
            serialized = str(value)

        await client.set(key, serialized, ex=ttl)
        return True

    except Exception as e:
        logger.warning(f"缓存写入失败: key={key}, error={e}")
        return False


async def cache_delete(key: str) -> bool:
    """
    删除缓存值

    Args:
        key: 缓存键

    Returns:
        是否删除成功
    """
    client = await get_redis_client()
    if client is None:
        return False

    try:
        await client.delete(key)
        return True
    except Exception as e:
        logger.warning(f"缓存删除失败: key={key}, error={e}")
        return False


async def cache_exists(key: str) -> bool:
    """
    检查缓存是否存在

    Args:
        key: 缓存键

    Returns:
        是否存在
    """
    client = await get_redis_client()
    if client is None:
        return False

    try:
        result = await client.exists(key)
        return bool(result)
    except Exception as e:
        logger.warning(f"缓存检查失败: key={key}, error={e}")
        return False
