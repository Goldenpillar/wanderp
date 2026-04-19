"""
WanderP AI Engine - FastAPI 应用入口

包含CORS中间件、路由注册、生命周期管理。
"""

import logging
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import get_settings
from app.utils.logger import setup_logging

# 初始化日志
setup_logging()
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """
    应用生命周期管理

    启动时：初始化外部连接（Milvus、Redis等）
    关闭时：清理资源连接
    """
    logger.info("WanderP AI Engine 正在启动...")

    # ---- 启动阶段 ----
    try:
        # 初始化Redis连接池
        from app.utils.cache import get_redis_client

        redis_client = get_redis_client()
        await redis_client.ping()
        logger.info("Redis 连接成功")

        # 初始化Milvus连接
        from app.core.rag.vector_store import VectorStore

        vector_store = VectorStore()
        await vector_store.connect()
        logger.info("Milvus 连接成功")

        # 初始化知识库（如果集合不存在则创建）
        from app.core.rag.knowledge_base import KnowledgeBase

        kb = KnowledgeBase(vector_store=vector_store)
        await kb.initialize()
        logger.info("知识库初始化完成")

    except Exception as e:
        logger.warning(f"启动时部分服务初始化失败（非致命）: {e}")
        logger.warning("服务将以降级模式运行，部分功能可能不可用")

    logger.info("WanderP AI Engine 启动完成")

    yield

    # ---- 关闭阶段 ----
    logger.info("WanderP AI Engine 正在关闭...")

    try:
        # 关闭Redis连接
        from app.utils.cache import close_redis_client

        await close_redis_client()
        logger.info("Redis 连接已关闭")

        # 关闭Milvus连接
        from app.core.rag.vector_store import VectorStore

        vector_store = VectorStore()
        await vector_store.disconnect()
        logger.info("Milvus 连接已关闭")

    except Exception as e:
        logger.warning(f"关闭时发生错误: {e}")

    logger.info("WanderP AI Engine 已关闭")


def create_app() -> FastAPI:
    """
    创建并配置FastAPI应用实例

    Returns:
        配置完成的FastAPI应用
    """
    settings = get_settings()

    app = FastAPI(
        title=settings.app.app_name,
        description="WanderP 智能旅行规划AI引擎 - 基于LLM与约束求解的行程规划服务",
        version="0.1.0",
        docs_url="/docs" if settings.app.debug else None,
        redoc_url="/redoc" if settings.app.debug else None,
        lifespan=lifespan,
    )

    # ---- CORS 中间件 ----
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.app.cors_origins_list,
        allow_credentials=settings.app.cors_allow_credentials,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ---- 全局异常处理 ----
    @app.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception):
        """全局未捕获异常处理"""
        logger.error(f"未捕获异常: {exc}", exc_info=True, extra={"path": request.url.path})
        return JSONResponse(
            status_code=500,
            content={"detail": "服务器内部错误，请稍后重试"},
        )

    # ---- 注册路由 ----
    from app.api.health import router as health_router
    from app.api.plan import router as plan_router
    from app.api.preference import router as preference_router
    from app.api.recommend import router as recommend_router

    app.include_router(health_router, prefix="/api", tags=["健康检查"])
    app.include_router(plan_router, prefix="/api/plan", tags=["行程规划"])
    app.include_router(recommend_router, prefix="/api/recommend", tags=["智能推荐"])
    app.include_router(preference_router, prefix="/api/preference", tags=["偏好分析"])

    return app


# 创建应用实例
app = create_app()
