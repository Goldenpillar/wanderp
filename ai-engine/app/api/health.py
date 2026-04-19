"""
健康检查 API 路由

提供服务健康状态检查接口，用于监控和负载均衡。
"""

from datetime import datetime

from fastapi import APIRouter, Response

router = APIRouter()


@router.get("/health", summary="健康检查")
async def health_check(response: Response) -> dict:
    """
    基础健康检查接口

    检查服务是否正常运行，返回服务状态信息。
    用于Kubernetes存活探针和就绪探针。
    """
    response.status_code = 200
    return {
        "status": "healthy",
        "service": "wanderp-ai-engine",
        "timestamp": datetime.now().isoformat(),
    }


@router.get("/health/ready", summary="就绪检查")
async def readiness_check(response: Response) -> dict:
    """
    就绪检查接口

    检查所有依赖服务（Redis、Milvus等）是否可用。
    用于Kubernetes就绪探针。
    """
    checks = {}

    # 检查Redis连接
    try:
        from app.utils.cache import get_redis_client

        redis = get_redis_client()
        await redis.ping()
        checks["redis"] = {"status": "healthy"}
    except Exception as e:
        checks["redis"] = {"status": "unhealthy", "error": str(e)}

    # 检查Milvus连接
    try:
        from app.core.rag.vector_store import VectorStore

        vs = VectorStore()
        if vs.is_connected():
            checks["milvus"] = {"status": "healthy"}
        else:
            checks["milvus"] = {"status": "disconnected"}
    except Exception as e:
        checks["milvus"] = {"status": "unhealthy", "error": str(e)}

    # 判断整体状态
    all_healthy = all(
        c.get("status") == "healthy" for c in checks.values()
    )

    if all_healthy:
        response.status_code = 200
        return {
            "status": "ready",
            "checks": checks,
            "timestamp": datetime.now().isoformat(),
        }
    else:
        response.status_code = 503
        return {
            "status": "not_ready",
            "checks": checks,
            "timestamp": datetime.now().isoformat(),
        }


@router.get("/health/live", summary="存活检查")
async def liveness_check(response: Response) -> dict:
    """
    存活检查接口

    仅检查服务进程是否存活。
    用于Kubernetes存活探针。
    """
    response.status_code = 200
    return {
        "status": "alive",
        "timestamp": datetime.now().isoformat(),
    }
