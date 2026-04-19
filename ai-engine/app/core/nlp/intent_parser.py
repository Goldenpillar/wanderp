"""
用户意图解析

解析用户输入的自然语言，识别旅行相关的意图和关键信息。
"""

import logging
import re
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)


class IntentType(str, Enum):
    """用户意图类型"""
    PLAN_TRIP = "plan_trip"           # 规划行程
    RECOMMEND_FOOD = "recommend_food"  # 推荐美食
    RECOMMEND_SCENIC = "recommend_scenic"  # 推荐景区
    MODIFY_PLAN = "modify_plan"       # 修改行程
    ASK_QUESTION = "ask_question"     # 问答
    CHAT = "chat"                     # 闲聊
    UNKNOWN = "unknown"               # 未知意图


class ParsedIntent(BaseModel):
    """解析后的意图"""
    intent_type: IntentType = Field(..., description="意图类型")
    confidence: float = Field(..., ge=0, le=1, description="置信度")
    destination: Optional[str] = Field(None, description="目的地")
    date_range: Optional[str] = Field(None, description="日期范围")
    travelers_count: Optional[int] = Field(None, description="出行人数")
    budget: Optional[str] = Field(None, description="预算描述")
    preferences: list[str] = Field(default_factory=list, description="偏好列表")
    keywords: list[str] = Field(default_factory=list, description="关键词")
    raw_text: str = Field(..., description="原始文本")


class IntentParser:
    """
    用户意图解析器

    使用规则 + LLM 混合方式解析用户意图。
    先用规则快速匹配常见模式，无法匹配时调用LLM进行深度解析。
    """

    # 意图关键词映射
    INTENT_PATTERNS = {
        IntentType.PLAN_TRIP: [
            r"规划.*行程", r"制定.*计划", r"安排.*旅行",
            r"帮我.*规划", r"我想.*旅游", r"准备.*出行",
            r".*天.*旅行", r"去.*玩", r".*旅游攻略",
        ],
        IntentType.RECOMMEND_FOOD: [
            r"推荐.*吃", r"有什么.*美食", r"哪里.*好吃",
            r"餐厅.*推荐", r"特色.*菜", r"小吃.*推荐",
            r"吃什么", r"美食.*推荐", r"好吃的",
        ],
        IntentType.RECOMMEND_SCENIC: [
            r"推荐.*景点", r"有什么.*玩", r"哪里.*好玩",
            r"景区.*推荐", r"景点.*推荐", r"旅游.*景点",
            r"去哪.*玩", r"好玩.*地方", r"必去.*景点",
        ],
        IntentType.MODIFY_PLAN: [
            r"修改.*行程", r"调整.*计划", r"换.*景点",
            r"不要.*了", r"改成", r"重新.*安排",
        ],
        IntentType.ASK_QUESTION: [
            r".*怎么样", r".*多少钱", r".*远不远",
            r".*天气", r".*交通", r".*门票",
            r"什么时候.*", r"怎么.*去",
        ],
    }

    # 目的地提取模式
    DESTINATION_PATTERNS = [
        r"去([\u4e00-\u9fff]{2,}(?:市|省|区|县|州|盟|岛|山|湖|海|古镇|古城))",
        r"([\u4e00-\u9fff]{2,}(?:市|省|区|县))",
        r"(?:到|去|前往|飞往|前往)([\u4e00-\u9fff]{2,6})",
    ]

    # 日期提取模式
    DATE_PATTERNS = [
        r"(\d+)天",
        r"(\d+月\d+日?[~\-到]\d+月?\d+日?)",
        r"(下周|这周|本月|下月|周末|节假日|国庆|五一|春节)",
        r"(\d{4}年\d{1,2}月)",
    ]

    # 人数提取模式
    TRAVELERS_PATTERNS = [
        r"(\d+)个人?",
        r"(一家人|全家|情侣|朋友|同事|同学|闺蜜)",
        r"(带.*孩子|带.*老人|亲子|家庭)",
    ]

    # 预算提取模式
    BUDGET_PATTERNS = [
        r"预算(\d+)[元块]?",
        r"(\d+)[元块].*预算",
        r"人均(\d+)[元块]?",
        r"大概(\d+)[元块]",
    ]

    def __init__(self):
        """初始化意图解析器"""
        # 预编译正则表达式
        self._compiled_patterns = {
            intent: [re.compile(p) for p in patterns]
            for intent, patterns in self.INTENT_PATTERNS.items()
        }
        self._compiled_dest = [re.compile(p) for p in self.DESTINATION_PATTERNS]
        self._compiled_date = [re.compile(p) for p in self.DATE_PATTERNS]
        self._compiled_travelers = [re.compile(p) for p in self.TRAVELERS_PATTERNS]
        self._compiled_budget = [re.compile(p) for p in self.BUDGET_PATTERNS]

    def parse(self, text: str) -> ParsedIntent:
        """
        解析用户输入文本

        Args:
            text: 用户输入文本

        Returns:
            解析后的意图
        """
        logger.info(f"解析用户意图: '{text[:50]}...'")

        # 1. 识别意图类型
        intent_type, confidence = self._detect_intent(text)

        # 2. 提取关键信息
        destination = self._extract_destination(text)
        date_range = self._extract_date(text)
        travelers_count = self._extract_travelers(text)
        budget = self._extract_budget(text)
        keywords = self._extract_keywords(text)

        # 3. 提取偏好
        preferences = self._extract_preferences(text)

        parsed = ParsedIntent(
            intent_type=intent_type,
            confidence=confidence,
            destination=destination,
            date_range=date_range,
            travelers_count=travelers_count,
            budget=budget,
            preferences=preferences,
            keywords=keywords,
            raw_text=text,
        )

        logger.info(f"意图解析结果: type={intent_type.value}, confidence={confidence:.2f}")
        return parsed

    async def parse_with_llm(self, text: str) -> ParsedIntent:
        """
        使用LLM辅助解析用户意图

        当规则解析置信度较低时，调用LLM进行深度解析。

        Args:
            text: 用户输入文本

        Returns:
            解析后的意图
        """
        # 先用规则解析
        rule_result = self.parse(text)

        # 如果置信度较高，直接返回
        if rule_result.confidence >= 0.7:
            return rule_result

        # 调用LLM辅助解析
        try:
            from app.services.llm_service import LLMService

            llm = LLMService()

            prompt = f"""请分析以下用户输入的旅行意图，以JSON格式返回。

用户输入: {text}

请返回以下JSON格式：
{{
    "intent_type": "plan_trip|recommend_food|recommend_scenic|modify_plan|ask_question|chat",
    "confidence": 0.0-1.0,
    "destination": "目的地城市或地区",
    "date_range": "日期范围描述",
    "travelers_count": 出行人数(整数),
    "budget": "预算描述",
    "preferences": ["偏好1", "偏好2"],
    "keywords": ["关键词1", "关键词2"]
}}

只返回JSON，不要其他内容。"""

            response = await llm.chat(
                system_prompt="你是一个旅行意图分析专家，请准确分析用户的旅行需求。",
                user_prompt=prompt,
                temperature=0.1,
                max_tokens=300,
            )

            import json
            result = json.loads(response)

            return ParsedIntent(
                intent_type=IntentType(result.get("intent_type", "unknown")),
                confidence=result.get("confidence", 0.5),
                destination=result.get("destination"),
                date_range=result.get("date_range"),
                travelers_count=result.get("travelers_count"),
                budget=result.get("budget"),
                preferences=result.get("preferences", []),
                keywords=result.get("keywords", []),
                raw_text=text,
            )

        except Exception as e:
            logger.warning(f"LLM意图解析失败，使用规则解析结果: {e}")
            return rule_result

    def _detect_intent(self, text: str) -> tuple[IntentType, float]:
        """
        检测用户意图类型

        Args:
            text: 用户输入

        Returns:
            (意图类型, 置信度)
        """
        best_intent = IntentType.UNKNOWN
        best_score = 0.0

        for intent_type, patterns in self._compiled_patterns.items():
            for pattern in patterns:
                if pattern.search(text):
                    # 匹配到模式，计算置信度
                    score = len(pattern.pattern) / 20  # 模式越长越精确
                    if score > best_score:
                        best_score = min(0.9, score)
                        best_intent = intent_type

        if best_intent == IntentType.UNKNOWN:
            return IntentType.CHAT, 0.3

        return best_intent, best_score

    def _extract_destination(self, text: str) -> Optional[str]:
        """提取目的地"""
        for pattern in self._compiled_dest:
            match = pattern.search(text)
            if match:
                return match.group(1)
        return None

    def _extract_date(self, text: str) -> Optional[str]:
        """提取日期范围"""
        for pattern in self._compiled_date:
            match = pattern.search(text)
            if match:
                return match.group(1)
        return None

    def _extract_travelers(self, text: str) -> Optional[int]:
        """提取出行人数"""
        for pattern in self._compiled_travelers:
            match = pattern.search(text)
            if match:
                group = match.group(1)
                # 尝试提取数字
                num_match = re.search(r"\d+", group)
                if num_match:
                    return int(num_match.group())
                # 特殊描述映射
                family_map = {"一家人": 3, "全家": 3, "情侣": 2, "朋友": 2}
                return family_map.get(group)
        return None

    def _extract_budget(self, text: str) -> Optional[str]:
        """提取预算信息"""
        for pattern in self._compiled_budget:
            match = pattern.search(text)
            if match:
                return match.group(0)
        return None

    def _extract_keywords(self, text: str) -> list[str]:
        """提取关键词"""
        import jieba

        # 分词
        words = list(jieba.cut(text))

        # 过滤停用词和短词
        stop_words = {"的", "了", "是", "在", "我", "有", "和", "就", "不", "人", "都", "一", "想", "要", "去", "能", "可以", "吗", "呢", "吧", "啊"}
        keywords = [w for w in words if len(w) >= 2 and w not in stop_words]

        return keywords

    def _extract_preferences(self, text: str) -> list[str]:
        """提取偏好信息"""
        preferences = []

        # 口味偏好
        taste_keywords = ["辣", "清淡", "甜", "咸", "日料", "火锅", "烧烤", "海鲜", "素食"]
        for kw in taste_keywords:
            if kw in text:
                preferences.append(kw)

        # 活动偏好
        activity_keywords = ["爬山", "游泳", "购物", "看海", "拍照", "历史", "文化", "自然", "冒险"]
        for kw in activity_keywords:
            if kw in text:
                preferences.append(kw)

        # 节奏偏好
        if "休闲" in text or "放松" in text:
            preferences.append("休闲放松")
        if "紧凑" in text or "充实" in text:
            preferences.append("紧凑充实")

        return preferences
