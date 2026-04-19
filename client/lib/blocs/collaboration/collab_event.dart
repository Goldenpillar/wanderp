import 'package:equatable/equatable.dart';

/// 协作 BLoC 事件基类
abstract class CollabEvent extends Equatable {
  const CollabEvent();

  @override
  List<Object?> get props => [];
}

/// 连接协作房间
class ConnectRoom extends CollabEvent {
  final String tripId;

  const ConnectRoom(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

/// 断开协作房间
class DisconnectRoom extends CollabEvent {
  const DisconnectRoom();
}

/// 邀请成员
class InviteMember extends CollabEvent {
  final String tripId;
  final String userId;

  const InviteMember({required this.tripId, required this.userId});

  @override
  List<Object?> get props => [tripId, userId];
}

/// 移除成员
class RemoveMember extends CollabEvent {
  final String tripId;
  final String userId;

  const RemoveMember({required this.tripId, required this.userId});

  @override
  List<Object?> get props => [tripId, userId];
}

/// 提交偏好
class SubmitPreference extends CollabEvent {
  final String tripId;
  final Map<String, dynamic> preferences;

  const SubmitPreference({required this.tripId, required this.preferences});

  @override
  List<Object?> get props => [tripId, preferences];
}

/// 创建投票
class CreateVote extends CollabEvent {
  final String tripId;
  final String title;
  final String description;
  final List<String> options;

  const CreateVote({
    required this.tripId,
    required this.title,
    required this.description,
    required this.options,
  });

  @override
  List<Object?> get props => [tripId, title, description, options];
}

/// 投票
class CastVote extends CollabEvent {
  final String voteId;
  final String optionId;

  const CastVote({required this.voteId, required this.optionId});

  @override
  List<Object?> get props => [voteId, optionId];
}

/// 加载成员列表
class LoadMembers extends CollabEvent {
  final String tripId;

  const LoadMembers(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

/// 加载投票列表
class LoadVotes extends CollabEvent {
  final String tripId;

  const LoadVotes(this.tripId);

  @override
  List<Object?> get props => [tripId];
}

/// 接收实时消息
class MessageReceived extends CollabEvent {
  final Map<String, dynamic> message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
