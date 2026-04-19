import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../services/auth_service.dart';
import '../services/collab_service.dart';
import '../services/food_service.dart';
import '../services/map_service.dart';
import '../services/trip_service.dart';
import '../services/weather_service.dart';
import '../services/transport_service.dart';

/// API 客户端 Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient.instance;
});

/// 行程服务 Provider
final tripServiceProvider = Provider<TripService>((ref) {
  return TripService();
});

/// 地图服务 Provider
final mapServiceProvider = Provider<MapService>((ref) {
  return MapService();
});

/// 美食服务 Provider
final foodServiceProvider = Provider<FoodService>((ref) {
  return FoodService();
});

/// 天气服务 Provider
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

/// 交通服务 Provider
final transportServiceProvider = Provider<TransportService>((ref) {
  return TransportService();
});

/// 认证服务 Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// 协作服务 Provider
final collabServiceProvider = Provider<CollabService>((ref) {
  final service = CollabService();
  ref.onDispose(() => service.dispose());
  return service;
});
