import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/logger.dart';
import '../../services/map_service.dart';
import 'map_event.dart';
import 'map_state.dart';

/// 地图 BLoC
/// 管理地图显示、标记点和轨迹记录
class MapBloc extends Bloc<MapEvent, MapState> {
  final MapService _mapService;

  MapBloc({MapService? mapService})
      : _mapService = mapService ?? MapService(),
        super(const MapInitial()) {
    on<InitializeMap>(_onInitializeMap);
    on<UpdateCurrentLocation>(_onUpdateCurrentLocation);
    on<MoveToLocation>(_onMoveToLocation);
    on<LoadTripMarkers>(_onLoadTripMarkers);
    on<LoadNearbyPoi>(_onLoadNearbyPoi);
    on<StartTrajectoryRecording>(_onStartTrajectoryRecording);
    on<StopTrajectoryRecording>(_onStopTrajectoryRecording);
    on<AddTrajectoryPoint>(_onAddTrajectoryPoint);
    on<ClearTrajectory>(_onClearTrajectory);
  }

  /// 处理初始化地图
  Future<void> _onInitializeMap(
    InitializeMap event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());
    try {
      // TODO: 初始化地图 SDK
      emit(const MapReady());
    } catch (e) {
      Logger.e('初始化地图失败: $e');
      emit(MapError('初始化地图失败: $e'));
    }
  }

  /// 处理更新当前位置
  void _onUpdateCurrentLocation(
    UpdateCurrentLocation event,
    Emitter<MapState> emit,
  ) {
    if (state is MapReady) {
      final currentState = state as MapReady;
      emit(currentState.copyWith(
        currentLatitude: event.latitude,
        currentLongitude: event.longitude,
      ));
    }
  }

  /// 处理移动地图到指定位置
  void _onMoveToLocation(
    MoveToLocation event,
    Emitter<MapState> emit,
  ) {
    if (state is MapReady) {
      final currentState = state as MapReady;
      emit(currentState.copyWith(
        currentLatitude: event.latitude,
        currentLongitude: event.longitude,
        zoom: event.zoom,
      ));
    }
  }

  /// 处理加载行程标记点
  Future<void> _onLoadTripMarkers(
    LoadTripMarkers event,
    Emitter<MapState> emit,
  ) async {
    try {
      final markers = await _mapService.getTripMarkers(event.tripId);
      if (state is MapReady) {
        final currentState = state as MapReady;
        emit(currentState.copyWith(markers: markers));
      }
    } catch (e) {
      Logger.e('加载行程标记点失败: $e');
    }
  }

  /// 处理加载附近 POI
  Future<void> _onLoadNearbyPoi(
    LoadNearbyPoi event,
    Emitter<MapState> emit,
  ) async {
    try {
      final pois = await _mapService.getNearbyPoi(
        category: event.category,
        latitude: event.latitude,
        longitude: event.longitude,
        radius: event.radius,
      );
      if (state is MapReady) {
        final currentState = state as MapReady;
        emit(currentState.copyWith(markers: pois));
      }
    } catch (e) {
      Logger.e('加载附近 POI 失败: $e');
    }
  }

  /// 处理开始轨迹记录
  void _onStartTrajectoryRecording(
    StartTrajectoryRecording event,
    Emitter<MapState> emit,
  ) {
    if (state is MapReady) {
      final currentState = state as MapReady;
      emit(currentState.copyWith(
        isRecording: true,
        trajectoryPoints: [],
      ));
    }
  }

  /// 处理停止轨迹记录
  void _onStopTrajectoryRecording(
    StopTrajectoryRecording event,
    Emitter<MapState> emit,
  ) {
    if (state is MapReady) {
      final currentState = state as MapReady;
      emit(currentState.copyWith(isRecording: false));
    }
  }

  /// 处理添加轨迹点
  void _onAddTrajectoryPoint(
    AddTrajectoryPoint event,
    Emitter<MapState> emit,
  ) {
    if (state is MapReady) {
      final currentState = state as MapReady;
      final newPoint = TrajectoryPoint(
        latitude: event.latitude,
        longitude: event.longitude,
        timestamp: event.timestamp,
      );
      emit(currentState.copyWith(
        trajectoryPoints: [...currentState.trajectoryPoints, newPoint],
      ));
    }
  }

  /// 处理清除轨迹
  void _onClearTrajectory(
    ClearTrajectory event,
    Emitter<MapState> emit,
  ) {
    if (state is MapReady) {
      final currentState = state as MapReady;
      emit(currentState.copyWith(
        trajectoryPoints: [],
        isRecording: false,
      ));
    }
  }
}
