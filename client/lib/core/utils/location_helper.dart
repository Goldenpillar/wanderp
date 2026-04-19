import 'package:geolocator/geolocator.dart';

import '../utils/logger.dart';

/// 位置工具类
/// 封装定位相关功能
class LocationHelper {
  LocationHelper._();

  /// 检查定位权限
  static Future<bool> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Logger.w('定位服务未开启');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Logger.w('定位权限被拒绝');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Logger.w('定位权限被永久拒绝');
      return false;
    }

    return true;
  }

  /// 获取当前位置
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return position;
    } catch (e) {
      Logger.e('获取当前位置失败: $e');
      return null;
    }
  }

  /// 获取当前位置（低精度，省电）
  static Future<Position?> getCurrentPositionLow() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return position;
    } catch (e) {
      Logger.e('获取当前位置失败: $e');
      return null;
    }
  }

  /// 持续监听位置变化
  static Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: locationSettings ??
          const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
    );
  }

  /// 计算两点之间的距离（单位：米）
  static double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// 计算两点之间的方位角（单位：度）
  static double bearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
