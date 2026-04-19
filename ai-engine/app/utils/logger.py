"""
日志工具

配置应用日志系统，支持控制台和文件输出。
"""

import logging
import sys
from typing import Optional


def setup_logging(
    log_level: Optional[str] = None,
    log_file: Optional[str] = None,
) -> None:
    """
    配置日志系统

    Args:
        log_level: 日志级别 (DEBUG/INFO/WARNING/ERROR/CRITICAL)
        log_file: 日志文件路径（可选）
    """
    if log_level is None:
        from app.config import get_settings
        try:
            settings = get_settings()
            log_level = settings.app.log_level
        except Exception:
            log_level = "INFO"

    # 创建根日志格式
    log_format = (
        "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
    )
    date_format = "%Y-%m-%d %H:%M:%S"

    # 配置根日志器
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))

    # 清除已有处理器
    root_logger.handlers.clear()

    # 控制台处理器
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(getattr(logging, log_level.upper(), logging.INFO))
    console_formatter = logging.Formatter(log_format, datefmt=date_format)
    console_handler.setFormatter(console_formatter)
    root_logger.addHandler(console_handler)

    # 文件处理器（可选）
    if log_file:
        try:
            file_handler = logging.FileHandler(log_file, encoding="utf-8")
            file_handler.setLevel(logging.DEBUG)
            file_formatter = logging.Formatter(log_format, datefmt=date_format)
            file_handler.setFormatter(file_formatter)
            root_logger.addHandler(file_handler)
        except Exception as e:
            root_logger.warning(f"无法创建日志文件: {log_file}, error={e}")

    # 降低第三方库的日志级别
    third_party_loggers = [
        "httpx",
        "httpcore",
        "hpack",
        "pymilvus",
        "urllib3",
    ]
    for logger_name in third_party_loggers:
        third_party_logger = logging.getLogger(logger_name)
        third_party_logger.setLevel(logging.WARNING)


def get_logger(name: str) -> logging.Logger:
    """
    获取日志器

    Args:
        name: 日志器名称

    Returns:
        日志器实例
    """
    return logging.getLogger(name)
