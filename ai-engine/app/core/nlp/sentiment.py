"""
情绪/能量状态分析

分析用户文本中的情绪和能量状态，
用于个性化推荐和行程节奏调整。
"""

import logging
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)


class EmotionType(str, Enum):
    """情绪类型"""
    HAPPY = "happy"           # 开心
    EXCITED = "excited"       # 兴奋
    RELAXED = "relaxed"       # 放松
    NEUTRAL = "neutral"       # 中性
    TIRED = "tired"           # 疲惫
    ANXIOUS = "anxious"       # 焦虑
    FRUSTRATED = "frustrated"  # 沮丧
    BORED = "bored"           # 无聊


class EnergyState(str, Enum):
    """能量状态"""
    HIGH = "high"             # 高能量
    MEDIUM = "medium"         # 中等能量
    LOW = "low"               # 低能量
    DEPLETED = "depleted"     # 精力耗尽


class SentimentResult(BaseModel):
    """情绪分析结果"""
    emotion: EmotionType = Field(..., description="主要情绪")
    emotion_score: float = Field(..., ge=0, le=1, description="情绪强度")
    energy_state: EnergyState = Field(..., description="能量状态")
    energy_score: float = Field(..., ge=0, le=10, description="能量评分(1-10)")
    confidence: float = Field(..., ge=0, le=1, description="分析置信度")
    keywords: list[str] = Field(default_factory=list, description="情绪关键词")
    suggestion: str = Field("", description="行程建议")


class SentimentAnalyzer:
    """
    情绪/能量状态分析器

    通过分析用户文本中的情绪词汇和表达方式，
    判断用户当前的情绪状态和能量水平，
    为推荐系统提供上下文信息。

    分析维度：
    1. 情绪类型：开心、兴奋、放松、疲惫、焦虑等
    2. 情绪强度：情绪的强烈程度
    3. 能量状态：高、中、低、耗尽
    4. 能量评分：1-10的数值评分
    """

    # 情绪词典
    EMOTION_LEXICON = {
        EmotionType.HAPPY: [
            "开心", "高兴", "快乐", "愉快", "幸福", "满足", "美好", "棒", "赞",
            "太好了", "期待", "兴奋", "哈哈", "嘻嘻", "不错", "喜欢", "爱",
        ],
        EmotionType.EXCITED: [
            "激动", "兴奋", "期待", "迫不及待", "太棒了", "超开心", "超级",
            "终于", "等不及", "好激动", "太期待", "激动人心",
        ],
        EmotionType.RELAXED: [
            "放松", "悠闲", "舒适", "惬意", "安静", "平静", "宁静", "慢",
            "休闲", "休息", "舒服", "自在", "轻松", "悠闲",
        ],
        EmotionType.TIRED: [
            "累", "疲惫", "困", "乏", "没劲", "不想动", "好累", "太累了",
            "精疲力尽", "走不动", "腿酸", "腰疼", "头疼", "困了",
        ],
        EmotionType.ANXIOUS: [
            "焦虑", "担心", "着急", "紧张", "不安", "害怕", "恐惧", "慌",
            "怎么办", "好急", "来不及", "赶不上", "会不会",
        ],
        EmotionType.FRUSTRATED: [
            "烦", "郁闷", "生气", "不爽", "失望", "无语", "差评", "坑",
            "被骗", "太差", "不好", "不行", "受不了", "再也不",
        ],
        EmotionType.BORED: [
            "无聊", "没意思", "乏味", "单调", "闷", "没劲", "不知道干嘛",
            "没什么好玩的", "好无聊",
        ],
    }

    # 能量状态关键词
    ENERGY_LEXICON = {
        EnergyState.HIGH: [
            "精力充沛", "充满活力", "元气满满", "精神好", "状态好",
            "很有劲", "动力十足", "活力四射", "生龙活虎",
        ],
        EnergyState.MEDIUM: [
            "还行", "一般", "可以", "正常", "差不多", "马马虎虎",
            "凑合", "还好",
        ],
        EnergyState.LOW: [
            "有点累", "不太想动", "没精神", "懒", "困", "乏",
            "不太行", "不太舒服", "有点疲惫",
        ],
        EnergyState.DEPLETED: [
            "太累了", "走不动了", "完全没力气", "精疲力尽",
            "要死了", "快不行了", "累瘫了", "累死了",
        ],
    }

    def __init__(self):
        """初始化情绪分析器"""
        pass

    def analyze(self, text: str) -> SentimentResult:
        """
        分析文本中的情绪和能量状态

        Args:
            text: 用户输入文本

        Returns:
            情绪分析结果
        """
        logger.info(f"情绪分析: '{text[:50]}...'")

        # 1. 分析情绪类型
        emotion, emotion_score = self._detect_emotion(text)

        # 2. 分析能量状态
        energy_state, energy_score = self._detect_energy(text)

        # 3. 提取情绪关键词
        keywords = self._extract_emotion_keywords(text)

        # 4. 计算置信度
        confidence = self._calculate_confidence(emotion_score, energy_score)

        # 5. 生成行程建议
        suggestion = self._generate_suggestion(emotion, energy_state)

        result = SentimentResult(
            emotion=emotion,
            emotion_score=emotion_score,
            energy_state=energy_state,
            energy_score=energy_score,
            confidence=confidence,
            keywords=keywords,
            suggestion=suggestion,
        )

        logger.info(
            f"情绪分析结果: emotion={emotion.value}, "
            f"energy={energy_state.value}, score={energy_score}"
        )
        return result

    async def analyze_with_llm(self, text: str) -> SentimentResult:
        """
        使用LLM辅助情绪分析

        Args:
            text: 用户输入文本

        Returns:
            情绪分析结果
        """
        # 先用规则分析
        rule_result = self.analyze(text)

        # 如果置信度较高，直接返回
        if rule_result.confidence >= 0.6:
            return rule_result

        # 调用LLM辅助分析
        try:
            from app.services.llm_service import LLMService

            llm = LLMService()

            prompt = f"""请分析以下文本中说话人的情绪和能量状态。

文本: {text}

请以JSON格式返回：
{{
    "emotion": "happy|excited|relaxed|neutral|tired|anxious|frustrated|bored",
    "emotion_score": 0.0-1.0,
    "energy_state": "high|medium|low|depleted",
    "energy_score": 1-10,
    "keywords": ["关键词1", "关键词2"],
    "suggestion": "行程建议"
}}

只返回JSON。"""

            response = await llm.chat(
                system_prompt="你是一个情绪分析专家，请准确分析文本中的情绪和能量状态。",
                user_prompt=prompt,
                temperature=0.1,
                max_tokens=200,
            )

            import json
            result = json.loads(response)

            return SentimentResult(
                emotion=EmotionType(result.get("emotion", "neutral")),
                emotion_score=result.get("emotion_score", 0.5),
                energy_state=EnergyState(result.get("energy_state", "medium")),
                energy_score=result.get("energy_score", 5),
                confidence=0.8,
                keywords=result.get("keywords", []),
                suggestion=result.get("suggestion", ""),
            )

        except Exception as e:
            logger.warning(f"LLM情绪分析失败: {e}")
            return rule_result

    def _detect_emotion(self, text: str) -> tuple[EmotionType, float]:
        """
        检测情绪类型

        Args:
            text: 输入文本

        Returns:
            (情绪类型, 情绪强度)
        """
        scores: dict[EmotionType, int] = {}

        for emotion, keywords in self.EMOTION_LEXICON.items():
            count = sum(1 for kw in keywords if kw in text)
            if count > 0:
                scores[emotion] = count

        if not scores:
            return EmotionType.NEUTRAL, 0.3

        # 获取得分最高的情绪
        best_emotion = max(scores, key=scores.get)
        best_score = scores[best_emotion]

        # 计算情绪强度（0-1）
        intensity = min(1.0, best_score / 3.0)

        return best_emotion, intensity

    def _detect_energy(self, text: str) -> tuple[EnergyState, float]:
        """
        检测能量状态

        Args:
            text: 输入文本

        Returns:
            (能量状态, 能量评分)
        """
        scores: dict[EnergyState, int] = {}

        for state, keywords in self.ENERGY_LEXICON.items():
            count = sum(1 for kw in keywords if kw in text)
            if count > 0:
                scores[state] = count

        if not scores:
            return EnergyState.MEDIUM, 5.0

        best_state = max(scores, key=scores.get)

        # 能量评分映射
        energy_map = {
            EnergyState.HIGH: 8.5,
            EnergyState.MEDIUM: 5.5,
            EnergyState.LOW: 3.5,
            EnergyState.DEPLETED: 1.5,
        }

        base_score = energy_map[best_state]
        # 根据匹配关键词数量微调
        adjustment = min(scores[best_state] * 0.3, 1.5)
        final_score = min(10.0, base_score + adjustment)

        return best_state, final_score

    def _extract_emotion_keywords(self, text: str) -> list[str]:
        """提取文本中的情绪关键词"""
        keywords = []
        for emotion_words in self.EMOTION_LEXICON.values():
            for word in emotion_words:
                if word in text and word not in keywords:
                    keywords.append(word)
        return keywords

    def _calculate_confidence(self, emotion_score: float, energy_score: float) -> float:
        """计算分析置信度"""
        # 基于情绪强度和能量评分的偏离程度计算置信度
        base_confidence = 0.5
        emotion_boost = emotion_score * 0.3
        energy_stability = 1.0 - abs(energy_score - 5.0) / 10.0

        return min(1.0, base_confidence + emotion_boost + energy_stability * 0.2)

    def _generate_suggestion(self, emotion: EmotionType, energy: EnergyState) -> str:
        """
        根据情绪和能量状态生成行程建议

        Args:
            emotion: 情绪类型
            energy: 能量状态

        Returns:
            建议文本
        """
        suggestions = []

        # 基于情绪的建议
        if emotion in (EmotionType.HAPPY, EmotionType.EXCITED):
            suggestions.append("您心情很好，可以安排更多户外探索活动")
        elif emotion == EmotionType.RELAXED:
            suggestions.append("适合安排悠闲的行程，如公园散步、咖啡馆小憩")
        elif emotion in (EmotionType.TIRED, EmotionType.DEPLETED):
            suggestions.append("建议安排轻松的活动，多留休息时间")
        elif emotion == EmotionType.ANXIOUS:
            suggestions.append("建议选择熟悉、安全的景点，避免紧凑行程")
        elif emotion == EmotionType.BORED:
            suggestions.append("可以尝试一些新奇有趣的体验活动")

        # 基于能量的建议
        if energy == EnergyState.HIGH:
            suggestions.append("体力充沛，适合安排较长的游览路线")
        elif energy in (EnergyState.LOW, EnergyState.DEPLETED):
            suggestions.append("建议减少步行距离，选择交通便利的景点")

        return "；".join(suggestions) if suggestions else ""
