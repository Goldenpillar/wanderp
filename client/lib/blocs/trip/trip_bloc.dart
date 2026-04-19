import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/logger.dart';
import '../../models/trip.dart';
import '../../models/activity.dart';
import '../../services/trip_service.dart';
import 'trip_event.dart';
import 'trip_state.dart';

/// 行程 BLoC
/// 管理行程相关的状态
class TripBloc extends Bloc<TripEvent, TripState> {
  final TripService _tripService;

  TripBloc({TripService? tripService})
      : _tripService = tripService ?? TripService(),
        super(const TripInitial()) {
    on<LoadTrips>(_onLoadTrips);
    on<RefreshTrips>(_onRefreshTrips);
    on<LoadTripDetail>(_onLoadTripDetail);
    on<CreateTrip>(_onCreateTrip);
    on<UpdateTrip>(_onUpdateTrip);
    on<DeleteTrip>(_onDeleteTrip);
    on<AddActivity>(_onAddActivity);
    on<RemoveActivity>(_onRemoveActivity);
    on<UpdateBudget>(_onUpdateBudget);
  }

  /// 处理加载行程列表
  Future<void> _onLoadTrips(
    LoadTrips event,
    Emitter<TripState> emit,
  ) async {
    emit(const TripLoading());
    try {
      final trips = await _tripService.getTrips();
      emit(TripsLoaded(trips: trips));
    } catch (e) {
      Logger.e('加载行程列表失败: $e');
      emit(TripError('加载行程列表失败: $e'));
    }
  }

  /// 处理刷新行程列表
  Future<void> _onRefreshTrips(
    RefreshTrips event,
    Emitter<TripState> emit,
  ) async {
    try {
      final trips = await _tripService.getTrips();
      emit(TripsLoaded(trips: trips));
    } catch (e) {
      Logger.e('刷新行程列表失败: $e');
      emit(TripError('刷新行程列表失败: $e'));
    }
  }

  /// 处理加载行程详情
  Future<void> _onLoadTripDetail(
    LoadTripDetail event,
    Emitter<TripState> emit,
  ) async {
    emit(const TripLoading());
    try {
      final trip = await _tripService.getTripDetail(event.tripId);
      final activities = await _tripService.getActivities(event.tripId);
      emit(TripDetailLoaded(trip: trip, activities: activities));
    } catch (e) {
      Logger.e('加载行程详情失败: $e');
      emit(TripError('加载行程详情失败: $e'));
    }
  }

  /// 处理创建行程
  Future<void> _onCreateTrip(
    CreateTrip event,
    Emitter<TripState> emit,
  ) async {
    emit(const TripLoading());
    try {
      await _tripService.createTrip(event.tripData);
      final trips = await _tripService.getTrips();
      emit(TripsLoaded(trips: trips));
    } catch (e) {
      Logger.e('创建行程失败: $e');
      emit(TripError('创建行程失败: $e'));
    }
  }

  /// 处理更新行程
  Future<void> _onUpdateTrip(
    UpdateTrip event,
    Emitter<TripState> emit,
  ) async {
    try {
      await _tripService.updateTrip(event.tripId, event.tripData);
      final trip = await _tripService.getTripDetail(event.tripId);
      final activities = await _tripService.getActivities(event.tripId);
      emit(TripDetailLoaded(trip: trip, activities: activities));
    } catch (e) {
      Logger.e('更新行程失败: $e');
      emit(TripError('更新行程失败: $e'));
    }
  }

  /// 处理删除行程
  Future<void> _onDeleteTrip(
    DeleteTrip event,
    Emitter<TripState> emit,
  ) async {
    try {
      await _tripService.deleteTrip(event.tripId);
      final trips = await _tripService.getTrips();
      emit(TripsLoaded(trips: trips));
    } catch (e) {
      Logger.e('删除行程失败: $e');
      emit(TripError('删除行程失败: $e'));
    }
  }

  /// 处理添加活动
  Future<void> _onAddActivity(
    AddActivity event,
    Emitter<TripState> emit,
  ) async {
    try {
      await _tripService.addActivity(event.tripId, event.activityData);
      final trip = await _tripService.getTripDetail(event.tripId);
      final activities = await _tripService.getActivities(event.tripId);
      emit(TripDetailLoaded(trip: trip, activities: activities));
    } catch (e) {
      Logger.e('添加活动失败: $e');
      emit(TripError('添加活动失败: $e'));
    }
  }

  /// 处理移除活动
  Future<void> _onRemoveActivity(
    RemoveActivity event,
    Emitter<TripState> emit,
  ) async {
    try {
      await _tripService.removeActivity(event.tripId, event.activityId);
      final trip = await _tripService.getTripDetail(event.tripId);
      final activities = await _tripService.getActivities(event.tripId);
      emit(TripDetailLoaded(trip: trip, activities: activities));
    } catch (e) {
      Logger.e('移除活动失败: $e');
      emit(TripError('移除活动失败: $e'));
    }
  }

  /// 处理更新预算
  Future<void> _onUpdateBudget(
    UpdateBudget event,
    Emitter<TripState> emit,
  ) async {
    try {
      await _tripService.updateBudget(event.tripId, event.budget);
      final trip = await _tripService.getTripDetail(event.tripId);
      final activities = await _tripService.getActivities(event.tripId);
      emit(TripDetailLoaded(trip: trip, activities: activities));
    } catch (e) {
      Logger.e('更新预算失败: $e');
      emit(TripError('更新预算失败: $e'));
    }
  }
}
