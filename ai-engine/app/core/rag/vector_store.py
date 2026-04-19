"""
Milvus 向量存储

封装Milvus向量数据库的连接和操作，
提供集合管理、向量插入、相似度搜索等功能。
"""

import logging
from typing import Any, Optional

from pymilvus import (
    Collection,
    CollectionSchema,
    DataType,
    FieldSchema,
    MilvusClient,
    connections,
    utility,
)

from app.config import get_settings

logger = logging.getLogger(__name__)


class VectorStore:
    """
    Milvus 向量存储封装

    提供以下功能：
    1. 连接管理：建立和断开Milvus连接
    2. 集合管理：创建、删除、加载集合
    3. 数据操作：插入、删除、更新向量数据
    4. 相似度搜索：稠密向量相似度检索
    """

    # 默认集合schema定义
    DEFAULT_FIELDS = [
        FieldSchema(name="id", dtype=DataType.VARCHAR, is_primary=True, max_length=64),
        FieldSchema(name="text", dtype=DataType.VARCHAR, max_length=65535),
        FieldSchema(name="embedding", dtype=DataType.FLOAT_VECTOR, dim=1024),
        FieldSchema(name="metadata", dtype=DataType.JSON),
        FieldSchema(name="doc_type", dtype=DataType.VARCHAR, max_length=64),
        FieldSchema(name="city", dtype=DataType.VARCHAR, max_length=64),
    ]

    def __init__(self):
        """初始化向量存储"""
        self.settings = get_settings()
        self._client: Optional[MilvusClient] = None
        self._connected = False

    async def connect(self) -> None:
        """
        建立Milvus连接

        Raises:
            ConnectionError: 连接失败
        """
        try:
            connections.connect(
                alias="default",
                host=self.settings.milvus.milvus_host,
                port=self.settings.milvus.milvus_port,
                user=self.settings.milvus.milvus_user,
                password=self.settings.milvus.milvus_password,
                db_name=self.settings.milvus.milvus_db_name,
            )
            self._connected = True
            logger.info(
                f"Milvus连接成功: {self.settings.milvus.milvus_host}:{self.settings.milvus.milvus_port}"
            )
        except Exception as e:
            self._connected = False
            logger.error(f"Milvus连接失败: {e}")
            raise ConnectionError(f"无法连接到Milvus: {e}") from e

    async def disconnect(self) -> None:
        """断开Milvus连接"""
        try:
            connections.disconnect("default")
            self._connected = False
            logger.info("Milvus连接已断开")
        except Exception as e:
            logger.warning(f"断开Milvus连接时出错: {e}")

    def is_connected(self) -> bool:
        """检查是否已连接"""
        return self._connected

    async def create_collection(
        self,
        collection_name: str,
        dimension: int = 1024,
        description: str = "",
    ) -> Collection:
        """
        创建向量集合

        Args:
            collection_name: 集合名称
            dimension: 向量维度
            description: 集合描述

        Returns:
            创建的集合对象
        """
        if not self._connected:
            raise ConnectionError("Milvus未连接")

        # 检查集合是否已存在
        if utility.has_collection(collection_name):
            logger.info(f"集合已存在: {collection_name}")
            return Collection(collection_name)

        # 构建schema
        fields = [
            FieldSchema(name="id", dtype=DataType.VARCHAR, is_primary=True, max_length=64),
            FieldSchema(name="text", dtype=DataType.VARCHAR, max_length=65535),
            FieldSchema(
                name="embedding",
                dtype=DataType.FLOAT_VECTOR,
                dim=dimension,
            ),
            FieldSchema(name="metadata", dtype=DataType.JSON),
            FieldSchema(name="doc_type", dtype=DataType.VARCHAR, max_length=64),
            FieldSchema(name="city", dtype=DataType.VARCHAR, max_length=64),
        ]

        schema = CollectionSchema(
            fields=fields,
            description=description or f"{collection_name}向量集合",
        )

        # 创建集合
        collection = Collection(
            name=collection_name,
            schema=schema,
        )

        # 创建索引（IVF_FLAT）
        index_params = {
            "index_type": "IVF_FLAT",
            "metric_type": "COSINE",
            "params": {"nlist": 128},
        }
        collection.create_index(
            field_name="embedding",
            index_params=index_params,
        )

        logger.info(f"集合创建成功: {collection_name}, 维度={dimension}")
        return collection

    async def drop_collection(self, collection_name: str) -> None:
        """
        删除向量集合

        Args:
            collection_name: 集合名称
        """
        if not self._connected:
            raise ConnectionError("Milvus未连接")

        if utility.has_collection(collection_name):
            utility.drop_collection(collection_name)
            logger.info(f"集合已删除: {collection_name}")

    async def insert(
        self,
        collection_name: str,
        ids: list[str],
        texts: list[str],
        embeddings: list[list[float]],
        metadatas: Optional[list[dict]] = None,
        doc_types: Optional[list[str]] = None,
        cities: Optional[list[str]] = None,
    ) -> int:
        """
        插入向量数据

        Args:
            collection_name: 集合名称
            ids: 文档ID列表
            texts: 文本内容列表
            embeddings: 向量列表
            metadatas: 元数据列表
            doc_types: 文档类型列表
            cities: 城市列表

        Returns:
            插入的数据条数
        """
        if not self._connected:
            raise ConnectionError("Milvus未连接")

        collection = Collection(collection_name)

        # 构建插入数据
        data = [
            ids,
            texts,
            embeddings,
            metadatas or [{}] * len(ids),
            doc_types or ["general"] * len(ids),
            cities or [""] * len(ids),
        ]

        # 插入数据
        result = collection.insert(data)
        collection.flush()

        logger.info(f"插入数据成功: collection={collection_name}, count={result.insert_count}")
        return result.insert_count

    async def search(
        self,
        collection_name: str,
        query_embedding: list[float],
        top_k: int = 10,
        filter_expr: Optional[str] = None,
        output_fields: Optional[list[str]] = None,
    ) -> list[dict]:
        """
        向量相似度搜索

        Args:
            collection_name: 集合名称
            query_embedding: 查询向量
            top_k: 返回数量
            filter_expr: 过滤表达式
            output_fields: 输出字段

        Returns:
            搜索结果列表
        """
        if not self._connected:
            raise ConnectionError("Milvus未连接")

        collection = Collection(collection_name)
        collection.load()

        # 执行搜索
        results = collection.search(
            data=[query_embedding],
            anns_field="embedding",
            param={
                "metric_type": "COSINE",
                "params": {"nprobe": 16},
            },
            limit=top_k,
            expr=filter_expr,
            output_fields=output_fields or ["text", "metadata", "doc_type", "city"],
        )

        # 格式化结果
        formatted = []
        for hits in results:
            for hit in hits:
                item = {
                    "id": hit.id,
                    "score": hit.score,
                    "text": hit.entity.get("text", ""),
                    "metadata": hit.entity.get("metadata", {}),
                    "doc_type": hit.entity.get("doc_type", ""),
                    "city": hit.entity.get("city", ""),
                }
                formatted.append(item)

        return formatted

    async def delete(
        self,
        collection_name: str,
        ids: list[str],
    ) -> None:
        """
        删除向量数据

        Args:
            collection_name: 集合名称
            ids: 要删除的ID列表
        """
        if not self._connected:
            raise ConnectionError("Milvus未连接")

        collection = Collection(collection_name)
        collection.delete(expr=f"id in {ids}")

        logger.info(f"删除数据: collection={collection_name}, count={len(ids)}")

    async def get_collection_stats(self, collection_name: str) -> dict:
        """
        获取集合统计信息

        Args:
            collection_name: 集合名称

        Returns:
            统计信息字典
        """
        if not self._connected:
            raise ConnectionError("Milvus未连接")

        if not utility.has_collection(collection_name):
            return {"exists": False}

        collection = Collection(collection_name)
        return {
            "exists": True,
            "name": collection_name,
            "num_entities": collection.num_entities,
            "description": collection.description,
        }
