import 'package:equatable/equatable.dart';

/// 行程 BLoC 事件基类
abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

/// 加载行程列表
class LoadTrips extends TripEvent {
  const LoadTrips();
}

/// 刷新行程列表
class RefreshTrips extends TripEvent {
  const RefreshTrips();
}

/// 加载行程详情
class LoadTripDetail extends TripEvent {
  final String tripId;

  const LoadTripDetail(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

/// 创建行程
class CreateTrip extends TripEvent {
  final Map<String, dynamic> tripData;

  const CreateTrip(this.tripData);

  @override
  List<Object?> get props => [tripData];
}

/// 更新行程
class UpdateTrip extends TripEvent {
  final String tripId;
  final Map<String, dynamic> tripData;

  const UpdateTrip({required this.tripId, required this.tripData});

  @override
  List<Object?> get props => [tripId, tripData];
}

/// 删除行程
class DeleteTrip extends TripEvent {
  final String tripId;

  const DeleteTrip(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

/// 添加活动到行程
class AddActivity extends TripEvent {
  final String tripId;
  final Map<String, dynamic> activityData;

  const AddActivity({required this.tripId, required this.activityData});

  @override
  List<Object?> get props => [tripId, activityData];
}

/// 从行程中移除活动
class RemoveActivity extends TripEvent {
  final String tripId;
  final String activityId;

  const RemoveActivity({required this.tripId, required this.activityId});

  @override
  List<Object?> get props => [tripId, activityId];
}

/// 更新行程预算
class UpdateBudget extends TripEvent {
  final String tripId;
  final int budget;

  const UpdateBudget({required this.tripId, required this.budget});

  @override
  List<Object?> get props => [tripId, budget];
}
