"""
WanderP AI Engine - 配置管理模块

使用 pydantic-settings 统一管理所有配置项，
支持环境变量和 .env 文件两种方式加载。
"""

from functools import lru_cache
from typing import Optional

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class LLMSettings(BaseSettings):
    """通义千问 LLM 配置"""

    dashscope_api_key: str = Field(..., description="通义千问API密钥")
    llm_model: str = Field(default="qwen-max", description="LLM模型名称")
    llm_max_tokens: int = Field(default=4096, description="LLM最大生成token数")
    llm_temperature: float = Field(default=0.7, ge=0.0, le=2.0, description="LLM采样温度")

    model_config = SettingsConfigDict(env_prefix="", env_file=".env")


class EmbeddingSettings(BaseSettings):
    """通义 Embedding 配置"""

    embedding_model: str = Field(default="text-embedding-v3", description="Embedding模型名称")
    embedding_dimension: int = Field(default=1024, description="向量维度")

    model_config = SettingsConfigDict(env_prefix="", env_file=".env")


class MilvusSettings(BaseSettings):
    """Milvus 向量数据库配置"""

    milvus_host: str = Field(default="localhost", description="Milvus主机地址")
    milvus_port: int = Field(default=19530, description="Milvus端口")
    milvus_user: str = Field(default="root", description="Milvus用户名")
    milvus_password: str = Field(default="Milvus", description="Milvus密码")
    milvus_db_name: str = Field(default="wanderp", description="数据库名称")
    milvus_collection_name: str = Field(default="travel_knowledge", description="集合名称")

    model_config = SettingsConfigDict(env_prefix="", env_file=".env")


class RedisSettings(BaseSettings):
    """Redis 缓存配置"""

    redis_host: str = Field(default="localhost", description="Redis主机地址")
    redis_port: int = Field(default=6379, description="Redis端口")
    redis_db: int = Field(default=0, description="Redis数据库编号")
    redis_password: Optional[str] = Field(default=None, description="Redis密码")
    redis_ttl: int = Field(default=3600, description="缓存过期时间(秒)")

    model_config = SettingsConfigDict(env_prefix="", env_file=".env")

    @property
    def redis_url(self) -> str:
        """构建Redis连接URL"""
        if self.redis_password:
            return f"redis://:{self.redis_password}@{self.redis_host}:{self.redis_port}/{self.redis_db}"
        return f"redis://{self.redis_host}:{self.redis_port}/{self.redis_db}"


class WeatherSettings(BaseSettings):
    """和风天气 API 配置"""

    qweather_api_key: str = Field(..., description="和风天气API密钥")
    qweather_base_url: str = Field(
        default="https://devapi.qweather.com/v7",
        description="和风天气API基础URL",
    )

    model_config = SettingsConfigDict(env_prefix="", env_file=".env")


class AmapSettings(BaseSettings):
    """高德地图 API 配置"""

    amap_api_key: str = Field(..., description="高德地图API密钥")
    amap_secret_key: str = Field(default="", description="高德地图签名密钥")

    model_config = SettingsConfigDict(env_prefix="", env_file=".env")


class JuheSettings(BaseSettings):
    """聚合数据 API 配置"""

    juhe_api_key: str = Field(..., description="聚合数据API密钥")

    model_config = SettingsConfigDict(env_prefix="", env_file=".env")


class FeizhuSettings(BaseSettings):
    """飞猪开放平台 API 配置"""

    feizhu_app_key: str = Field(..., description="飞猪应用Key")
    feizhu_app_secret: str = Field(..., description="飞猪应用Secret")

    model_config = SettingsConfigDict(env_prefix="", env_file=".env")


class AppSettings(BaseSettings):
    """应用基础配置"""

    app_name: str = Field(default="wanderp-ai-engine", description="应用名称")
    app_env: str = Field(default="development", description="运行环境")
    debug: bool = Field(default=True, description="调试模式")
    log_level: str = Field(default="INFO", description="日志级别")
    host: str = Field(default="0.0.0.0", description="服务监听地址")
    port: int = Field(default=8000, description="服务监听端口")
    cors_origins: str = Field(
        default="http://localhost:3000,http://localhost:8080",
        description="CORS允许的源(逗号分隔)",
    )
    cors_allow_credentials: bool = Field(default=True, description="CORS允许携带凭证")

    model_config = SettingsConfigDict(env_prefix="", env_file=".env")

    @property
    def cors_origins_list(self) -> list[str]:
        """将CORS源字符串转为列表"""
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


class Settings(BaseSettings):
    """全局配置聚合"""

    app: AppSettings = Field(default_factory=AppSettings)
    llm: LLMSettings = Field(default_factory=LLMSettings)
    embedding: EmbeddingSettings = Field(default_factory=EmbeddingSettings)
    milvus: MilvusSettings = Field(default_factory=MilvusSettings)
    redis: RedisSettings = Field(default_factory=RedisSettings)
    weather: WeatherSettings = Field(default_factory=WeatherSettings)
    amap: AmapSettings = Field(default_factory=AmapSettings)
    juhe: JuheSettings = Field(default_factory=JuheSettings)
    feizhu: FeizhuSettings = Field(default_factory=FeizhuSettings)

    model_config = SettingsConfigDict(env_file=".env", env_nested_delimiter="__")


@lru_cache
def get_settings() -> Settings:
    """获取全局配置单例"""
    return Settings()
