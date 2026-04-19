/// API 异常定义
/// 统一网络请求异常处理
class ApiException implements Exception {
  /// 错误消息
  final String message;

  /// HTTP 状态码
  final int? statusCode;

  /// 原始错误
  final dynamic originalError;

  const ApiException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  /// 未知错误
  factory ApiException.unknown([dynamic error]) {
    return ApiException(
      message: '未知错误，请稍后重试',
      originalError: error,
    );
  }

  /// 网络连接错误
  factory ApiException.networkError() {
    return const ApiException(
      message: '网络连接失败，请检查网络设置',
      statusCode: null,
    );
  }

  /// 请求超时
  factory ApiException.timeout() {
    return const ApiException(
      message: '请求超时，请稍后重试',
      statusCode: null,
    );
  }

  /// 服务器错误
  factory ApiException.serverError([int? statusCode]) {
    return ApiException(
      message: '服务器错误($statusCode)，请稍后重试',
      statusCode: statusCode,
    );
  }

  /// 未授权
  factory ApiException.unauthorized() {
    return const ApiException(
      message: '登录已过期，请重新登录',
      statusCode: 401,
    );
  }

  /// 禁止访问
  factory ApiException.forbidden() {
    return const ApiException(
      message: '没有权限访问该资源',
      statusCode: 403,
    );
  }

  /// 资源未找到
  factory ApiException.notFound() {
    return const ApiException(
      message: '请求的资源不存在',
      statusCode: 404,
    );
  }

  /// 请求参数错误
  factory ApiException.badRequest(String message) {
    return ApiException(
      message: message,
      statusCode: 400,
    );
  }

  /// 根据 HTTP 状态码创建异常
  factory ApiException.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return ApiException.badRequest(message ?? '请求参数错误');
      case 401:
        return ApiException.unauthorized();
      case 403:
        return ApiException.forbidden();
      case 404:
        return ApiException.notFound();
      case 408:
        return ApiException.timeout();
      case 500:
      case 502:
      case 503:
        return ApiException.serverError(statusCode);
      default:
        return ApiException(
          message: message ?? '请求失败($statusCode)',
          statusCode: statusCode,
        );
    }
  }

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}
