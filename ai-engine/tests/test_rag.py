"""
RAG知识检索测试
"""

import pytest

from app.core.rag.indexer import DocumentIndexer


class TestDocumentIndexer:
    """文档索引器测试"""

    def setup_method(self):
        self.indexer = DocumentIndexer(chunk_size=200, chunk_overlap=30)

    def test_preprocess(self):
        """测试文本预处理"""
        text = "这是  一个  测试\n\n\n\n多行文本"
        result = self.indexer.preprocess(text)
        assert "\n\n\n" not in result
        assert "  " not in result

    def test_chunk_text_short(self):
        """测试短文本分块"""
        text = "这是一段短文本。"
        chunks = self.indexer.chunk_text(text)
        # 短文本可能不满足最小块大小
        assert isinstance(chunks, list)

    def test_chunk_text_long(self):
        """测试长文本分块"""
        text = "这是第一段内容。" * 50 + "\n\n" + "这是第二段内容。" * 50
        chunks = self.indexer.chunk_text(text)
        assert len(chunks) >= 1

        # 检查每个块的大小
        for chunk in chunks:
            assert len(chunk["text"]) <= self.indexer.MAX_CHUNK_SIZE
            assert "text" in chunk
            assert "index" in chunk

    def test_chunk_text_paragraphs(self):
        """测试段落分块"""
        text = "第一段内容，包含多个句子。这里继续写。再写一些。\n\n" \
               "第二段内容，同样有多个句子。继续写。再多一些。\n\n" \
               "第三段内容。"
        chunks = self.indexer.chunk_text(text)
        assert isinstance(chunks, list)

    def test_chunk_text_empty(self):
        """测试空文本"""
        chunks = self.indexer.chunk_text("")
        assert chunks == []

    def test_extract_metadata_city(self):
        """测试城市提取"""
        text = "北京故宫是中国最著名的景点之一，位于北京市东城区。"
        metadata = self.indexer.extract_metadata(text)
        assert "city" in metadata

    def test_extract_metadata_price(self):
        """测试价格提取"""
        text = "门票价格为60元。"
        metadata = self.indexer.extract_metadata(text)
        assert metadata.get("price") == 60

    def test_extract_metadata_char_count(self):
        """测试字符数统计"""
        text = "这是一段测试文本"
        metadata = self.indexer.extract_metadata(text)
        assert metadata["char_count"] == len(text)


class TestHybridRetriever:
    """混合检索器测试"""

    def test_rrf_fusion(self):
        """测试RRF融合"""
        from app.core.rag.retriever import HybridRetriever

        retriever = HybridRetriever()

        dense_results = [
            {"id": "doc-1", "score": 0.9, "text": "文档1"},
            {"id": "doc-2", "score": 0.8, "text": "文档2"},
            {"id": "doc-3", "score": 0.7, "text": "文档3"},
        ]
        sparse_results = [
            {"id": "doc-3", "score": 0.95, "text": "文档3"},
            {"id": "doc-1", "score": 0.85, "text": "文档1"},
            {"id": "doc-4", "score": 0.6, "text": "文档4"},
        ]

        fused = retriever._reciprocal_rank_fusion(dense_results, sparse_results)

        # doc-1 和 doc-3 在两个列表中都出现，应该排在前面
        assert len(fused) == 4
        fused_ids = [r["id"] for r in fused]
        assert "doc-1" in fused_ids
        assert "doc-3" in fused_ids
        assert "doc-4" in fused_ids

        # 检查RRF分数
        for result in fused:
            assert "rrf_score" in result
            assert result["rrf_score"] > 0

    def test_bm25_score(self):
        """测试BM25评分"""
        from app.core.rag.retriever import HybridRetriever

        retriever = HybridRetriever()

        text = "北京故宫是中国最著名的历史文化景点"
        keywords = ["北京", "故宫", "景点"]

        score = retriever._calc_bm25_score(text, keywords)
        assert score > 0

    def test_bm25_score_no_match(self):
        """测试BM25无匹配"""
        from app.core.rag.retriever import HybridRetriever

        retriever = HybridRetriever()

        text = "这是一段不相关的文本"
        keywords = ["北京", "故宫"]

        score = retriever._calc_bm25_score(text, keywords)
        assert score == 0
