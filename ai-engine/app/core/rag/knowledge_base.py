"""
知识库管理

管理旅行知识库的创建、更新和查询。
支持多种文档类型的索引和检索。
"""

import logging
import os
from typing import Optional

from app.core.rag.vector_store import VectorStore

logger = logging.getLogger(__name__)


class KnowledgeBase:
    """
    旅行知识库管理器

    功能：
    1. 知识库初始化：创建必要的集合和索引
    2. 文档管理：添加、更新、删除知识文档
    3. 批量导入：从文件批量导入知识数据
    4. 知识查询：通过自然语言查询知识库
    """

    # 知识库集合名称
    COLLECTIONS = {
        "travel_knowledge": "旅行知识总库",
        "restaurants": "餐厅知识库",
        "scenic_spots": "景区知识库",
        "hotels": "酒店知识库",
        "transport": "交通知识库",
        "tips": "旅行贴士知识库",
    }

    def __init__(self, vector_store: Optional[VectorStore] = None):
        """
        初始化知识库管理器

        Args:
            vector_store: 向量存储实例
        """
        self.vector_store = vector_store or VectorStore()

    async def initialize(self) -> None:
        """
        初始化知识库

        创建所有必要的集合。
        """
        logger.info("正在初始化知识库...")

        for collection_name, description in self.COLLECTIONS.items():
            try:
                await self.vector_store.create_collection(
                    collection_name=collection_name,
                    dimension=1024,
                    description=description,
                )
                logger.info(f"集合就绪: {collection_name}")
            except Exception as e:
                logger.warning(f"集合初始化失败: {collection_name}, error={e}")

        logger.info("知识库初始化完成")

    async def add_document(
        self,
        collection_name: str,
        doc_id: str,
        text: str,
        metadata: Optional[dict] = None,
        doc_type: str = "general",
        city: str = "",
    ) -> bool:
        """
        添加知识文档

        Args:
            collection_name: 集合名称
            doc_id: 文档ID
            text: 文档文本
            metadata: 元数据
            doc_type: 文档类型
            city: 关联城市

        Returns:
            是否添加成功
        """
        try:
            from app.services.embedding_service import EmbeddingService

            embedding_service = EmbeddingService()

            # 生成文本向量
            embedding = await embedding_service.embed(text)

            # 插入向量存储
            await self.vector_store.insert(
                collection_name=collection_name,
                ids=[doc_id],
                texts=[text],
                embeddings=[embedding],
                metadatas=[metadata or {}],
                doc_types=[doc_type],
                cities=[city],
            )

            logger.info(f"文档添加成功: {doc_id} -> {collection_name}")
            return True

        except Exception as e:
            logger.error(f"文档添加失败: {doc_id}, error={e}")
            return False

    async def add_documents_batch(
        self,
        collection_name: str,
        documents: list[dict],
    ) -> int:
        """
        批量添加知识文档

        Args:
            collection_name: 集合名称
            documents: 文档列表，每个文档包含 id, text, metadata, doc_type, city

        Returns:
            成功添加的文档数量
        """
        if not documents:
            return 0

        try:
            from app.services.embedding_service import EmbeddingService

            embedding_service = EmbeddingService()

            # 批量生成向量
            texts = [doc["text"] for doc in documents]
            embeddings = await embedding_service.embed_batch(texts)

            # 批量插入
            ids = [doc["id"] for doc in documents]
            metadatas = [doc.get("metadata", {}) for doc in documents]
            doc_types = [doc.get("doc_type", "general") for doc in documents]
            cities = [doc.get("city", "") for doc in documents]

            count = await self.vector_store.insert(
                collection_name=collection_name,
                ids=ids,
                texts=texts,
                embeddings=embeddings,
                metadatas=metadatas,
                doc_types=doc_types,
                cities=cities,
            )

            logger.info(f"批量添加文档成功: {count} 条 -> {collection_name}")
            return count

        except Exception as e:
            logger.error(f"批量添加文档失败: {e}")
            return 0

    async def import_from_directory(
        self,
        collection_name: str,
        directory: str,
        doc_type: str = "general",
    ) -> int:
        """
        从目录导入知识文档

        支持的文件格式：.txt, .md, .json

        Args:
            collection_name: 集合名称
            directory: 目录路径
            doc_type: 文档类型

        Returns:
            导入的文档数量
        """
        if not os.path.isdir(directory):
            logger.warning(f"目录不存在: {directory}")
            return 0

        import hashlib
        import uuid

        documents = []
        count = 0

        for filename in os.listdir(directory):
            filepath = os.path.join(directory, filename)
            if not os.path.isfile(filepath):
                continue

            ext = os.path.splitext(filename)[1].lower()
            if ext not in (".txt", ".md", ".json"):
                continue

            try:
                with open(filepath, "r", encoding="utf-8") as f:
                    content = f.read()

                if not content.strip():
                    continue

                # 生成文档ID
                doc_id = str(uuid.uuid4())

                documents.append({
                    "id": doc_id,
                    "text": content,
                    "metadata": {
                        "source": filename,
                        "filepath": filepath,
                    },
                    "doc_type": doc_type,
                    "city": "",
                })
                count += 1

            except Exception as e:
                logger.warning(f"读取文件失败: {filepath}, error={e}")

        if documents:
            imported = await self.add_documents_batch(collection_name, documents)
            logger.info(f"从目录导入: {imported}/{count} 个文档")
            return imported

        return 0

    async def query(
        self,
        query: str,
        collection_name: str = "travel_knowledge",
        top_k: int = 5,
        city: Optional[str] = None,
    ) -> list[dict]:
        """
        查询知识库

        Args:
            query: 查询文本
            collection_name: 集合名称
            top_k: 返回数量
            city: 限定城市

        Returns:
            查询结果列表
        """
        from app.core.rag.retriever import HybridRetriever

        retriever = HybridRetriever()

        # 构建过滤表达式
        filter_expr = None
        if city:
            filter_expr = f'city == "{city}"'

        results = await retriever.retrieve(
            query=query,
            collection_name=collection_name,
            top_k=top_k,
            filter_expr=filter_expr,
        )

        return results

    async def get_stats(self) -> dict:
        """
        获取知识库统计信息

        Returns:
            各集合的统计信息
        """
        stats = {}
        for collection_name in self.COLLECTIONS:
            try:
                collection_stats = await self.vector_store.get_collection_stats(collection_name)
                stats[collection_name] = collection_stats
            except Exception as e:
                stats[collection_name] = {"error": str(e)}

        return stats
