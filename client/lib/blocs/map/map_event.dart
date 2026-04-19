import 'package:equatable/equatable.dart';

/// 地图 BLoC 事件基类
abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化地图
class InitializeMap extends MapEvent {
  const InitializeMap();
}

/// 更新当前位置
class UpdateCurrentLocation extends MapEvent {
  final double latitude;
  final double longitude;

  const UpdateCurrentLocation({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

/// 移动地图到指定位置
class MoveToLocation extends MapEvent {
  final double latitude;
  final double longitude;
  final double? zoom;

  const MoveToLocation({
    required this.latitude,
    required this.longitude,
    this.zoom,
  });

  @override
  List<Object?> get props => [latitude, longitude, zoom];
}

/// 加载行程标记点
class LoadTripMarkers extends MapEvent {
  final String tripId;

  const LoadTripMarkers(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

/// 加载附近 POI
class LoadNearbyPoi extends MapEvent {
  final String category;
  final double? latitude;
  final double? longitude;
  final int? radius;

  const LoadNearbyPoi({
    required this.category,
    this.latitude,
    this.longitude,
    this.radius,
  });

  @override
  List<Object?> get props => [category, latitude, longitude, radius];
}

/// 开始轨迹记录
class StartTrajectoryRecording extends MapEvent {
  const StartTrajectoryRecording();
}

/// 停止轨迹记录
class StopTrajectoryRecording extends MapEvent {
  const StopTrajectoryRecording();
}

/// 添加轨迹点
class AddTrajectoryPoint extends MapEvent {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const AddTrajectoryPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, timestamp];
}

/// 清除轨迹
class ClearTrajectory extends MapEvent {
  const ClearTrajectory();
}
