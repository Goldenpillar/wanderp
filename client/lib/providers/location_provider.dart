import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../core/utils/logger.dart';
import '../core/utils/location_helper.dart';

/// 位置状态
class LocationState {
  /// 当前纬度
  final double? latitude;

  /// 当前经度
  final double? longitude;

  /// 位置是否可用
  final bool isAvailable;

  /// 错误信息
  final String? errorMessage;

  const LocationState({
    this.latitude,
    this.longitude,
    this.isAvailable = false,
    this.errorMessage,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    bool? isAvailable,
    String? errorMessage,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAvailable: isAvailable ?? this.isAvailable,
      errorMessage: errorMessage,
    );
  }
}

/// 位置状态管理 Provider
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  /// 获取当前位置
  Future<void> getCurrentLocation() async {
    try {
      final position = await LocationHelper.getCurrentPosition();
      if (position != null) {
        state = LocationState(
          latitude: position.latitude,
          longitude: position.longitude,
          isAvailable: true,
        );
      } else {
        state = const LocationState(
          isAvailable: false,
          errorMessage: '无法获取位置信息',
        );
      }
    } catch (e) {
      Logger.e('获取位置失败: $e');
      state = LocationState(
        isAvailable: false,
        errorMessage: '获取位置失败: $e',
      );
    }
  }

  /// 监听位置变化
  void startListening() {
    LocationHelper.getPositionStream().listen(
      (position) {
        state = LocationState(
          latitude: position.latitude,
          longitude: position.longitude,
          isAvailable: true,
        );
      },
      onError: (error) {
        Logger.e('位置监听错误: $error');
        state = LocationState(
          isAvailable: false,
          errorMessage: '位置监听错误: $error',
        );
      },
    );
  }

  /// 清除位置信息
  void clearLocation() {
    state = const LocationState();
  }
}

/// 位置 Provider
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

/// 当前位置是否可用
final isLocationAvailableProvider = Provider<bool>((ref) {
  final location = ref.watch(locationProvider);
  return location.isAvailable;
});
