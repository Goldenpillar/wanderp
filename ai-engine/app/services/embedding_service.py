"""
通义 Embedding 服务封装

封装通义千问Embedding API调用，
提供文本向量化和批量向量化接口。
"""

import logging
from typing import Optional

from app.config import get_settings

logger = logging.getLogger(__name__)


class EmbeddingService:
    """
    通义 Embedding 服务

    通过DashScope SDK调用通义千问Embedding模型，
    将文本转换为稠密向量表示。
    """

    def __init__(self):
        """初始化Embedding服务"""
        self.settings = get_settings()
        self._initialized = False

    def _initialize(self) -> None:
        """初始化DashScope"""
        if not self._initialized:
            try:
                import dashscope
                dashscope.api_key = self.settings.llm.dashscope_api_key
                self._initialized = True
            except ImportError:
                raise RuntimeError("请安装dashscope: pip install dashscope")

    async def embed(self, text: str) -> list[float]:
        """
        将单条文本转换为向量

        Args:
            text: 输入文本

        Returns:
            向量列表

        Raises:
            RuntimeError: API调用失败
        """
        self._initialize()

        try:
            import dashscope

            response = dashscope.TextEmbedding.call(
                model=self.settings.embedding.embedding_model,
                input=text,
                dimension=self.settings.embedding.embedding_dimension,
            )

            if response.status_code == 200:
                embedding = response.output["embeddings"][0]["embedding"]
                logger.debug(f"Embedding生成成功: dim={len(embedding)}")
                return embedding
            else:
                error_msg = f"Embedding API错误: {response.code} - {response.message}"
                logger.error(error_msg)
                raise RuntimeError(error_msg)

        except Exception as e:
            if isinstance(e, RuntimeError):
                raise
            logger.error(f"Embedding生成失败: {e}")
            raise RuntimeError(f"Embedding生成失败: {e}") from e

    async def embed_batch(self, texts: list[str]) -> list[list[float]]:
        """
        批量将文本转换为向量

        DashScope支持批量输入，一次最多处理25条文本。
        超过限制时自动分批处理。

        Args:
            texts: 输入文本列表

        Returns:
            向量列表

        Raises:
            RuntimeError: API调用失败
        """
        self._initialize()

        if not texts:
            return []

        all_embeddings = []
        batch_size = 25  # DashScope单次最大批量

        for i in range(0, len(texts), batch_size):
            batch = texts[i:i + batch_size]

            try:
                import dashscope

                response = dashscope.TextEmbedding.call(
                    model=self.settings.embedding.embedding_model,
                    input=batch,
                    dimension=self.settings.embedding.embedding_dimension,
                )

                if response.status_code == 200:
                    batch_embeddings = [
                        item["embedding"] for item in response.output["embeddings"]
                    ]
                    all_embeddings.extend(batch_embeddings)
                    logger.debug(f"批量Embedding: batch {i // batch_size + 1}, count={len(batch_embeddings)}")
                else:
                    error_msg = f"批量Embedding API错误: {response.code} - {response.message}"
                    logger.error(error_msg)
                    raise RuntimeError(error_msg)

            except Exception as e:
                if isinstance(e, RuntimeError):
                    raise
                logger.error(f"批量Embedding生成失败: {e}")
                raise RuntimeError(f"批量Embedding生成失败: {e}") from e

        return all_embeddings

    async def embed_with_retry(
        self,
        text: str,
        max_retries: int = 3,
    ) -> list[float]:
        """
        带重试的文本向量化

        Args:
            text: 输入文本
            max_retries: 最大重试次数

        Returns:
            向量列表
        """
        import asyncio

        last_error = None
        for attempt in range(max_retries):
            try:
                return await self.embed(text)
            except RuntimeError as e:
                last_error = e
                if attempt < max_retries - 1:
                    logger.warning(f"Embedding生成失败，第{attempt + 1}次重试")
                    await asyncio.sleep(1.0 * (attempt + 1))

        raise last_error or RuntimeError("Embedding生成失败：超过最大重试次数")
