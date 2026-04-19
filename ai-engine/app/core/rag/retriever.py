"""
混合检索器

实现稠密向量检索 + BM25稀疏检索 + 重排序的混合检索策略。
"""

import logging
import math
from typing import Optional

from app.core.rag.vector_store import VectorStore
from app.services.embedding_service import EmbeddingService

logger = logging.getLogger(__name__)


class HybridRetriever:
    """
    混合检索器

    检索流程：
    1. 稠密向量检索：使用Embedding向量进行语义相似度搜索
    2. BM25稀疏检索：使用关键词匹配进行精确搜索
    3. 结果融合：使用RRF（Reciprocal Rank Fusion）融合两种检索结果
    4. 重排序：使用LLM或交叉编码器对融合结果重新排序
    """

    # RRF融合参数
    RRF_K = 60  # RRF常数，通常设为60

    # 检索权重
    DENSE_WEIGHT = 0.6   # 稠密检索权重
    SPARSE_WEIGHT = 0.4  # 稀疏检索权重

    def __init__(self):
        """初始化混合检索器"""
        self.vector_store = VectorStore()
        self.embedding_service = EmbeddingService()

    async def retrieve(
        self,
        query: str,
        collection_name: str = "travel_knowledge",
        top_k: int = 10,
        filter_expr: Optional[str] = None,
        rerank: bool = True,
    ) -> list[dict]:
        """
        混合检索

        Args:
            query: 查询文本
            collection_name: 集合名称
            top_k: 返回数量
            filter_expr: 过滤表达式
            rerank: 是否进行重排序

        Returns:
            检索结果列表
        """
        logger.info(f"混合检索: query='{query[:50]}...', collection={collection_name}")

        # 1. 稠密向量检索
        dense_results = await self._dense_retrieve(
            query=query,
            collection_name=collection_name,
            top_k=top_k * 2,
            filter_expr=filter_expr,
        )

        # 2. BM25稀疏检索
        sparse_results = await self._sparse_retrieve(
            query=query,
            collection_name=collection_name,
            top_k=top_k * 2,
            filter_expr=filter_expr,
        )

        # 3. 结果融合
        fused_results = self._reciprocal_rank_fusion(
            dense_results=dense_results,
            sparse_results=sparse_results,
        )

        # 4. 重排序
        if rerank and fused_results:
            fused_results = await self._rerank(query, fused_results)

        # 截取top_k
        return fused_results[:top_k]

    async def _dense_retrieve(
        self,
        query: str,
        collection_name: str,
        top_k: int,
        filter_expr: Optional[str] = None,
    ) -> list[dict]:
        """
        稠密向量检索

        Args:
            query: 查询文本
            collection_name: 集合名称
            top_k: 返回数量
            filter_expr: 过滤表达式

        Returns:
            检索结果列表
        """
        try:
            # 生成查询向量
            query_embedding = await self.embedding_service.embed(query)

            # 向量搜索
            results = await self.vector_store.search(
                collection_name=collection_name,
                query_embedding=query_embedding,
                top_k=top_k,
                filter_expr=filter_expr,
            )

            logger.info(f"稠密检索返回 {len(results)} 条结果")
            return results

        except Exception as e:
            logger.error(f"稠密检索失败: {e}")
            return []

    async def _sparse_retrieve(
        self,
        query: str,
        collection_name: str,
        top_k: int,
        filter_expr: Optional[str] = None,
    ) -> list[dict]:
        """
        BM25稀疏检索

        使用jieba分词后进行关键词匹配。
        由于Milvus原生不支持BM25，这里使用简化实现：
        通过文本过滤和关键词匹配模拟稀疏检索。

        Args:
            query: 查询文本
            collection_name: 集合名称
            top_k: 返回数量
            filter_expr: 过滤表达式

        Returns:
            检索结果列表
        """
        try:
            import jieba

            # 分词
            keywords = list(jieba.cut(query))
            # 过滤停用词
            stop_words = {"的", "了", "是", "在", "我", "有", "和", "就", "不", "人", "都", "一", "一个", "上", "也", "很", "到", "说", "要", "去", "你", "会", "着", "没有", "看", "好", "自己", "这"}
            keywords = [kw for kw in keywords if kw.strip() and kw not in stop_words]

            if not keywords:
                return []

            # 构建过滤表达式（包含任一关键词）
            keyword_filter_parts = [f'text like "%{kw}%"' for kw in keywords[:5]]
            sparse_filter = f"({' or '.join(keyword_filter_parts)})"

            if filter_expr:
                sparse_filter = f"({filter_expr}) and {sparse_filter}"

            # 使用向量搜索获取候选（简化实现）
            query_embedding = await self.embedding_service.embed(query)
            results = await self.vector_store.search(
                collection_name=collection_name,
                query_embedding=query_embedding,
                top_k=top_k,
                filter_expr=sparse_filter,
            )

            # 计算BM25-like评分
            for result in results:
                text = result.get("text", "")
                bm25_score = self._calc_bm25_score(text, keywords)
                result["sparse_score"] = bm25_score

            # 按BM25分数排序
            results.sort(key=lambda x: x.get("sparse_score", 0), reverse=True)

            logger.info(f"稀疏检索返回 {len(results)} 条结果")
            return results

        except Exception as e:
            logger.error(f"稀疏检索失败: {e}")
            return []

    def _calc_bm25_score(self, text: str, keywords: list[str]) -> float:
        """
        计算简化的BM25评分

        Args:
            text: 文本内容
            keywords: 查询关键词列表

        Returns:
            BM25评分
        """
        import jieba

        # 文本分词
        text_tokens = list(jieba.cut(text))
        text_len = len(text_tokens)
        if text_len == 0:
            return 0.0

        # 计算每个关键词的BM25分数
        score = 0.0
        k1 = 1.5  # BM25参数
        b = 0.75  # BM25参数
        avg_dl = 100  # 假设平均文档长度

        for keyword in keywords:
            tf = text_tokens.count(keyword)  # 词频
            if tf == 0:
                continue

            # 简化的IDF（假设DF=1）
            idf = math.log((1000 - 1 + 0.5) / (1 + 0.5) + 1)

            # BM25公式
            tf_norm = (tf * (k1 + 1)) / (tf + k1 * (1 - b + b * text_len / avg_dl))
            score += idf * tf_norm

        return score

    def _reciprocal_rank_fusion(
        self,
        dense_results: list[dict],
        sparse_results: list[dict],
    ) -> list[dict]:
        """
        RRF（Reciprocal Rank Fusion）结果融合

        将稠密检索和稀疏检索的结果按排名融合。

        Args:
            dense_results: 稠密检索结果
            sparse_results: 稀疏检索结果

        Returns:
            融合后的结果列表
        """
        # 构建ID到分数的映射
        rrf_scores: dict[str, dict] = {}

        # 稠密检索排名贡献
        for rank, result in enumerate(dense_results):
            doc_id = result.get("id", "")
            if doc_id not in rrf_scores:
                rrf_scores[doc_id] = {
                    "data": result,
                    "dense_score": result.get("score", 0),
                    "sparse_score": result.get("sparse_score", 0),
                    "rrf_score": 0,
                }
            rrf_scores[doc_id]["rrf_score"] += self.DENSE_WEIGHT / (self.RRF_K + rank + 1)

        # 稀疏检索排名贡献
        for rank, result in enumerate(sparse_results):
            doc_id = result.get("id", "")
            if doc_id not in rrf_scores:
                rrf_scores[doc_id] = {
                    "data": result,
                    "dense_score": result.get("score", 0),
                    "sparse_score": result.get("sparse_score", 0),
                    "rrf_score": 0,
                }
            rrf_scores[doc_id]["rrf_score"] += self.SPARSE_WEIGHT / (self.RRF_K + rank + 1)
            rrf_scores[doc_id]["sparse_score"] = result.get("sparse_score", 0)

        # 按RRF分数排序
        sorted_results = sorted(
            rrf_scores.values(),
            key=lambda x: x["rrf_score"],
            reverse=True,
        )

        # 添加融合分数到结果中
        fused = []
        for item in sorted_results:
            result = item["data"].copy()
            result["rrf_score"] = item["rrf_score"]
            result["dense_score"] = item["dense_score"]
            result["sparse_score"] = item["sparse_score"]
            fused.append(result)

        return fused

    async def _rerank(self, query: str, results: list[dict]) -> list[dict]:
        """
        重排序

        使用LLM对检索结果进行语义重排序。
        评估每个结果与查询的相关性。

        Args:
            query: 查询文本
            results: 待排序的结果列表

        Returns:
            重排序后的结果列表
        """
        if len(results) <= 1:
            return results

        try:
            from app.services.llm_service import LLMService

            llm = LLMService()

            # 构建重排序prompt
            context = "\n".join(
                f"[{i+1}] {r.get('text', '')[:200]}"
                for i, r in enumerate(results[:10])
            )

            prompt = f"""请根据查询问题，对以下检索结果按相关性从高到低排序。

查询: {query}

检索结果:
{context}

请只输出排序后的编号列表，用逗号分隔。例如: 3,1,5,2,4"""

            response = await llm.chat(
                system_prompt="你是一个搜索结果排序专家，请根据相关性对结果排序。",
                user_prompt=prompt,
                temperature=0.1,
                max_tokens=100,
            )

            # 解析排序结果
            import re

            numbers = re.findall(r"\d+", response)
            rank_order = [int(n) for n in numbers if 1 <= int(n) <= len(results)]

            # 按排序结果重排
            reranked = []
            for idx in rank_order:
                if idx - 1 < len(results):
                    reranked.append(results[idx - 1])

            # 添加未排序的结果
            sorted_ids = set(rank_order)
            for i, result in enumerate(results):
                if i + 1 not in sorted_ids:
                    reranked.append(result)

            logger.info(f"重排序完成: {len(reranked)} 条结果")
            return reranked

        except Exception as e:
            logger.warning(f"重排序失败，使用原始排序: {e}")
            return results
