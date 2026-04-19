import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import 'api_interceptor.dart';

/// API 客户端封装
/// 基于 Dio 的统一网络请求客户端
class ApiClient {
  ApiClient._();

  static late ApiClient _instance;
  static ApiClient get instance => _instance;

  late Dio _dio;

  /// 获取 Dio 实例（供需要直接使用的场景）
  Dio get dio => _dio;

  /// 初始化 API 客户端
  static void init() {
    _instance = ApiClient._();
    _instance._setupDio();
  }

  /// 配置 Dio 实例
  void _setupDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.instance.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.instance.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.instance.receiveTimeout),
        sendTimeout: Duration(milliseconds: AppConfig.instance.connectTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加拦截器
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  // ==================== GET 请求 ====================

  /// GET 请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // ==================== POST 请求 ====================

  /// POST 请求
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );
  }

  // ==================== PUT 请求 ====================

  /// PUT 请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // ==================== DELETE 请求 ====================

  /// DELETE 请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // ==================== 文件上传 ====================

  /// 上传文件
  Future<Response<T>> upload<T>(
    String path, {
    required FormData formData,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }

  // ==================== 文件下载 ====================

  /// 下载文件
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
      queryParameters: queryParameters,
    );
  }
}
