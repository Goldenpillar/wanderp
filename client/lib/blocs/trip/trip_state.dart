import 'package:equatable/equatable.dart';

import '../../models/trip.dart';
import '../../models/activity.dart';

/// 行程 BLoC 状态基类
abstract class TripState extends Equatable {
  const TripState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class TripInitial extends TripState {
  const TripInitial();
}

/// 加载中
class TripLoading extends TripState {
  const TripLoading();
}

/// 行程列表加载成功
class TripsLoaded extends TripState {
  final List<Trip> trips;

  const TripsLoaded({required this.trips});

  @override
  List<Object?> get props => [trips];
}

/// 行程详情加载成功
class TripDetailLoaded extends TripState {
  final Trip trip;
  final List<Activity> activities;

  const TripDetailLoaded({required this.trip, required this.activities});

  @override
  List<Object?> get props => [trip, activities];
}

/// 行程操作成功
class TripOperationSuccess extends TripState {
  final String message;

  const TripOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// 行程操作失败
class TripError extends TripState {
  final String message;

  const TripError(this.message);

  @override
  List<Object?> get props => [message];
}
