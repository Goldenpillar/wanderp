"""
通义千问 LLM 服务封装

封装通义千问（DashScope）API调用，
提供统一的聊天、流式聊天接口。
"""

import json
import logging
from typing import AsyncGenerator, Optional

from app.config import get_settings

logger = logging.getLogger(__name__)


class LLMService:
    """
    通义千问 LLM 服务

    通过DashScope SDK调用通义千问大模型，
    支持同步和流式两种调用方式。
    """

    def __init__(self):
        """初始化LLM服务"""
        self.settings = get_settings()
        self._client = None

    def _get_client(self):
        """获取或创建DashScope客户端"""
        if self._client is None:
            try:
                import dashscope
                dashscope.api_key = self.settings.llm.dashscope_api_key
                self._client = dashscope
            except ImportError:
                raise RuntimeError("请安装dashscope: pip install dashscope")
        return self._client

    async def chat(
        self,
        system_prompt: str = "",
        user_prompt: str = "",
        temperature: float = 0.7,
        max_tokens: int = 4096,
        history: Optional[list[dict]] = None,
    ) -> str:
        """
        调用LLM进行对话

        Args:
            system_prompt: 系统提示词
            user_prompt: 用户提示词
            temperature: 采样温度
            max_tokens: 最大生成token数
            history: 对话历史

        Returns:
            LLM响应文本

        Raises:
            RuntimeError: API调用失败
        """
        client = self._get_client()

        # 构建消息列表
        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        if history:
            messages.extend(history)
        messages.append({"role": "user", "content": user_prompt})

        try:
            import dashscope

            response = dashscope.Generation.call(
                model=self.settings.llm.llm_model,
                messages=messages,
                temperature=temperature,
                max_tokens=max_tokens,
                result_format="message",
            )

            if response.status_code == 200:
                content = response.output.choices[0].message.content
                logger.debug(f"LLM响应: {content[:100]}...")
                return content
            else:
                error_msg = f"LLM API错误: {response.code} - {response.message}"
                logger.error(error_msg)
                raise RuntimeError(error_msg)

        except Exception as e:
            if isinstance(e, RuntimeError):
                raise
            logger.error(f"LLM调用失败: {e}")
            raise RuntimeError(f"LLM调用失败: {e}") from e

    async def chat_stream(
        self,
        system_prompt: str = "",
        user_prompt: str = "",
        temperature: float = 0.7,
        history: Optional[list[dict]] = None,
    ) -> AsyncGenerator[str, None]:
        """
        流式调用LLM进行对话

        Args:
            system_prompt: 系统提示词
            user_prompt: 用户提示词
            temperature: 采样温度
            history: 对话历史

        Yields:
            LLM响应文本片段
        """
        client = self._get_client()

        messages = []
        if system_prompt:
            messages.append({"role": "system", "content": system_prompt})
        if history:
            messages.extend(history)
        messages.append({"role": "user", "content": user_prompt})

        try:
            import dashscope

            responses = dashscope.Generation.call(
                model=self.settings.llm.llm_model,
                messages=messages,
                temperature=temperature,
                max_tokens=self.settings.llm.llm_max_tokens,
                result_format="message",
                stream=True,
                incremental_output=True,
            )

            for response in responses:
                if response.status_code == 200:
                    content = response.output.choices[0].message.content
                    if content:
                        yield content
                else:
                    logger.error(f"LLM流式API错误: {response.code} - {response.message}")
                    break

        except Exception as e:
            logger.error(f"LLM流式调用失败: {e}")
            raise RuntimeError(f"LLM流式调用失败: {e}") from e

    async def chat_with_retry(
        self,
        system_prompt: str = "",
        user_prompt: str = "",
        temperature: float = 0.7,
        max_tokens: int = 4096,
        max_retries: int = 3,
        retry_delay: float = 1.0,
    ) -> str:
        """
        带重试的LLM调用

        Args:
            system_prompt: 系统提示词
            user_prompt: 用户提示词
            temperature: 采样温度
            max_tokens: 最大生成token数
            max_retries: 最大重试次数
            retry_delay: 重试延迟(秒)

        Returns:
            LLM响应文本
        """
        import asyncio

        last_error = None
        for attempt in range(max_retries):
            try:
                return await self.chat(
                    system_prompt=system_prompt,
                    user_prompt=user_prompt,
                    temperature=temperature,
                    max_tokens=max_tokens,
                )
            except RuntimeError as e:
                last_error = e
                if attempt < max_retries - 1:
                    logger.warning(f"LLM调用失败，第{attempt + 1}次重试: {e}")
                    await asyncio.sleep(retry_delay * (attempt + 1))

        raise last_error or RuntimeError("LLM调用失败：超过最大重试次数")
