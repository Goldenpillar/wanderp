"""
文档索引器

负责文档的预处理、分块和索引构建。
"""

import logging
import re
from typing import Optional

logger = logging.getLogger(__name__)


class DocumentIndexer:
    """
    文档索引器

    功能：
    1. 文档预处理：清洗文本、提取结构化信息
    2. 文档分块：将长文档分割为适合检索的文本块
    3. 索引构建：为文本块生成向量并建立索引
    """

    # 默认分块参数
    DEFAULT_CHUNK_SIZE = 512       # 默认块大小（字符数）
    DEFAULT_CHUNK_OVERLAP = 50     # 默认重叠大小
    MAX_CHUNK_SIZE = 1024          # 最大块大小
    MIN_CHUNK_SIZE = 100           # 最小块大小

    def __init__(
        self,
        chunk_size: int = DEFAULT_CHUNK_SIZE,
        chunk_overlap: int = DEFAULT_CHUNK_OVERLAP,
    ):
        """
        初始化文档索引器

        Args:
            chunk_size: 文本块大小
            chunk_overlap: 文本块重叠大小
        """
        self.chunk_size = min(chunk_size, self.MAX_CHUNK_SIZE)
        self.chunk_overlap = min(chunk_overlap, chunk_size // 2)

    def preprocess(self, text: str) -> str:
        """
        预处理文档文本

        Args:
            text: 原始文本

        Returns:
            清洗后的文本
        """
        # 移除多余空白
        text = re.sub(r"\n{3,}", "\n\n", text)
        text = re.sub(r" {2,}", " ", text)

        # 移除特殊字符（保留中文、英文、数字、常用标点）
        text = re.sub(r"[^\u4e00-\u9fff\w\s,，。！？、；：""''（）《》【】\-—.!?;:'\"()\[\]{}]", "", text)

        # 标准化引号
        text = text.replace('"', '"').replace('"', '"')
        text = text.replace(''', "'").replace(''', "'")

        return text.strip()

    def chunk_text(self, text: str) -> list[dict]:
        """
        将文本分割为块

        使用基于段落和句子的智能分块策略。

        Args:
            text: 输入文本

        Returns:
            文本块列表，每个块包含 text, start, end, index
        """
        if not text:
            return []

        # 预处理
        text = self.preprocess(text)

        # 按段落分割
        paragraphs = re.split(r"\n\n+", text)
        paragraphs = [p.strip() for p in paragraphs if p.strip()]

        chunks = []
        current_chunk = ""
        chunk_start = 0

        for para in paragraphs:
            # 如果当前块加上新段落不超过大小限制，则合并
            if len(current_chunk) + len(para) + 2 <= self.chunk_size:
                if current_chunk:
                    current_chunk += "\n\n" + para
                else:
                    current_chunk = para
            else:
                # 保存当前块
                if current_chunk and len(current_chunk) >= self.MIN_CHUNK_SIZE:
                    chunks.append({
                        "text": current_chunk,
                        "start": chunk_start,
                        "end": chunk_start + len(current_chunk),
                        "index": len(chunks),
                    })

                # 如果单个段落超过块大小，按句子分割
                if len(para) > self.chunk_size:
                    sub_chunks = self._split_by_sentences(para, chunk_start)
                    chunks.extend(sub_chunks)
                    current_chunk = ""
                    chunk_start += len(para) + 2
                else:
                    # 保留重叠部分
                    overlap_text = ""
                    if current_chunk and self.chunk_overlap > 0:
                        overlap_text = current_chunk[-self.chunk_overlap:]
                    current_chunk = overlap_text + para
                    chunk_start += len(para) + 2

        # 保存最后一个块
        if current_chunk and len(current_chunk) >= self.MIN_CHUNK_SIZE:
            chunks.append({
                "text": current_chunk,
                "start": chunk_start,
                "end": chunk_start + len(current_chunk),
                "index": len(chunks),
            })

        return chunks

    def _split_by_sentences(self, text: str, base_offset: int = 0) -> list[dict]:
        """
        按句子分割长段落

        Args:
            text: 输入文本
            base_offset: 基础偏移量

        Returns:
            文本块列表
        """
        # 中文和英文句子分割
        sentences = re.split(r"(?<=[。！？.!?\n])", text)
        sentences = [s.strip() for s in sentences if s.strip()]

        chunks = []
        current_chunk = ""
        offset = base_offset

        for sentence in sentences:
            if len(current_chunk) + len(sentence) <= self.chunk_size:
                current_chunk += sentence
            else:
                if current_chunk:
                    chunks.append({
                        "text": current_chunk,
                        "start": offset,
                        "end": offset + len(current_chunk),
                        "index": len(chunks),
                    })
                    offset += len(current_chunk)

                    # 保留重叠
                    if self.chunk_overlap > 0:
                        overlap = current_chunk[-self.chunk_overlap:]
                        current_chunk = overlap + sentence
                    else:
                        current_chunk = sentence
                else:
                    current_chunk = sentence

        if current_chunk:
            chunks.append({
                "text": current_chunk,
                "start": offset,
                "end": offset + len(current_chunk),
                "index": len(chunks),
            })

        return chunks

    def extract_metadata(self, text: str, doc_type: str = "general") -> dict:
        """
        从文档文本中提取元数据

        Args:
            text: 文档文本
            doc_type: 文档类型

        Returns:
            元数据字典
        """
        metadata = {
            "doc_type": doc_type,
            "char_count": len(text),
            "paragraph_count": len(re.split(r"\n\n+", text)),
        }

        # 尝试提取城市信息
        city_patterns = [
            r"([\u4e00-\u9fff]{2,}(?:市|区|县|州|盟))",
        ]
        for pattern in city_patterns:
            match = re.search(pattern, text)
            if match:
                metadata["city"] = match.group(1)
                break

        # 尝试提取价格信息
        price_match = re.search(r"(\d+)\s*[元块]", text)
        if price_match:
            metadata["price"] = int(price_match.group(1))

        return metadata
