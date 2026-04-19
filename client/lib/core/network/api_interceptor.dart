import 'package:dio/dio.dart';

import '../../core/storage/local_storage.dart';
import '../../core/utils/logger.dart';

/// 鉴权拦截器
/// 自动在请求头中添加 Token，处理 Token 过期刷新
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 从本地存储获取 Token
    final token = LocalStorage.instance.getString('access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 处理 401 未授权错误，尝试刷新 Token
    if (err.response?.statusCode == 401) {
      // TODO: 实现 Token 刷新逻辑
      // final newToken = await _refreshToken();
      // if (newToken != null) {
      //   // 使用新 Token 重试请求
      //   err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      //   try {
      //     final response = await Dio().fetch(err.requestOptions);
      //     return handler.resolve(response);
      //   } catch (e) {
      //     return handler.next(err);
      //   }
      // }
      Logger.w('Token 已过期，需要重新登录');
    }
    handler.next(err);
  }

  /// 刷新 Token
  Future<String?> _refreshToken() async {
    try {
      final refreshToken = LocalStorage.instance.getString('refresh_token');
      if (refreshToken == null) return null;

      // TODO: 调用刷新 Token 接口
      // final response = await Dio().post(
      //   '/auth/refresh',
      //   data: {'refresh_token': refreshToken},
      // );
      // final newToken = response.data['access_token'];
      // await LocalStorage.instance.setString('access_token', newToken);
      // return newToken;
      return null;
    } catch (e) {
      Logger.e('刷新 Token 失败: $e');
      return null;
    }
  }
}

/// 日志拦截器
/// 在调试模式下打印请求和响应日志
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.d('┌─── 请求 ─────────────────────────');
    Logger.d('│ ${options.method} ${options.uri}');
    Logger.d('│ Headers: ${options.headers}');
    if (options.data != null) {
      Logger.d('│ Body: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      Logger.d('│ Query: ${options.queryParameters}');
    }
    Logger.d('└──────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.d('┌─── 响应 ─────────────────────────');
    Logger.d('│ ${response.statusCode} ${response.requestOptions.uri}');
    Logger.d('│ Data: ${response.data}');
    Logger.d('└──────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.e('┌─── 错误 ─────────────────────────');
    Logger.e('│ ${err.response?.statusCode} ${err.requestOptions.uri}');
    Logger.e('│ Message: ${err.message}');
    Logger.e('│ Data: ${err.response?.data}');
    Logger.e('└──────────────────────────────────');
    handler.next(err);
  }
}
