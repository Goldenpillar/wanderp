import 'dart:developer' as developer;

/// 日志工具类
/// 统一管理应用日志输出
class Logger {
  Logger._();

  /// 是否启用日志（生产环境关闭）
  static bool _enabled = true;

  /// 设置日志开关
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// 调试日志
  static void d(String message, {String? tag}) {
    if (!_enabled) return;
    developer.log(
      message,
      name: tag ?? 'WanderP',
      level: 500,
    );
  }

  /// 信息日志
  static void i(String message, {String? tag}) {
    if (!_enabled) return;
    developer.log(
      message,
      name: tag ?? 'WanderP',
      level: 800,
    );
  }

  /// 警告日志
  static void w(String message, {String? tag}) {
    if (!_enabled) return;
    developer.log(
      message,
      name: tag ?? 'WanderP',
      level: 900,
    );
  }

  /// 错误日志
  static void e(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (!_enabled) return;
    developer.log(
      message,
      name: tag ?? 'WanderP',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
