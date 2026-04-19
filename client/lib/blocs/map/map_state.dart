import 'package:equatable/equatable.dart';

/// 地图标记点模型
class MapMarker {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final String? snippet;
  final String? iconUrl;

  const MapMarker({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.snippet,
    this.iconUrl,
  });
}

/// 轨迹点模型
class TrajectoryPoint {
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? speed;
  final double? altitude;

  const TrajectoryPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.speed,
    this.altitude,
  });
}

/// 地图 BLoC 状态基类
abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class MapInitial extends MapState {
  const MapInitial();
}

/// 地图加载中
class MapLoading extends MapState {
  const MapLoading();
}

/// 地图就绪
class MapReady extends MapState {
  final double? currentLatitude;
  final double? currentLongitude;
  final double zoom;
  final List<MapMarker> markers;
  final bool isRecording;
  final List<TrajectoryPoint> trajectoryPoints;

  const MapReady({
    this.currentLatitude,
    this.currentLongitude,
    this.zoom = 15.0,
    this.markers = const [],
    this.isRecording = false,
    this.trajectoryPoints = const [],
  });

  /// 是否有当前位置
  bool get hasLocation =>
      currentLatitude != null && currentLongitude != null;

  /// 轨迹总距离（米）
  double get totalDistance {
    if (trajectoryPoints.length < 2) return 0;
    double total = 0;
    for (int i = 1; i < trajectoryPoints.length; i++) {
      final p1 = trajectoryPoints[i - 1];
      final p2 = trajectoryPoints[i];
      // 简化距离计算
      total += _calculateDistance(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      );
    }
    return total;
  }

  /// 简化的距离计算（Haversine 公式）
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = _toRadians(lat1) *
            _toRadians(lat1) +
        _toRadians(lat2) *
            _toRadians(lat2) *
            (1 - (dLat * dLat + dLon * dLon) / 4).clamp(0.0, 1.0);
    final c = 2 * _asin(a.sqrt());
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * 3.141592653589793 / 180;
  static double _asin(double x) => x;

  @override
  List<Object?> get props => [
        currentLatitude,
        currentLongitude,
        zoom,
        markers,
        isRecording,
        trajectoryPoints,
      ];

  /// 复制并修改
  MapReady copyWith({
    double? currentLatitude,
    double? currentLongitude,
    double? zoom,
    List<MapMarker>? markers,
    bool? isRecording,
    List<TrajectoryPoint>? trajectoryPoints,
  }) {
    return MapReady(
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      zoom: zoom ?? this.zoom,
      markers: markers ?? this.markers,
      isRecording: isRecording ?? this.isRecording,
      trajectoryPoints: trajectoryPoints ?? this.trajectoryPoints,
    );
  }
}

/// 地图错误
class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}
