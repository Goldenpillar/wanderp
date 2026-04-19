import 'package:equatable/equatable.dart';

import '../../models/user.dart';
import '../../models/preference.dart';

/// 投票选项模型
class VoteOption {
  final String id;
  final String label;
  final String? imageUrl;
  final int voteCount;
  final List<String> voterIds;

  const VoteOption({
    required this.id,
    required this.label,
    this.imageUrl,
    this.voteCount = 0,
    this.voterIds = const [],
  });
}

/// 投票模型
class Vote {
  final String id;
  final String tripId;
  final String title;
  final String description;
  final List<VoteOption> options;
  final String creatorId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;

  const Vote({
    required this.id,
    required this.tripId,
    required this.title,
    required this.description,
    required this.options,
    required this.creatorId,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
  });

  /// 获取得票最多的选项
  VoteOption? get leadingOption {
    if (options.isEmpty) return null;
    return options.reduce((a, b) => a.voteCount >= b.voteCount ? a : b);
  }
}

/// 协作 BLoC 状态基类
abstract class CollabState extends Equatable {
  const CollabState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class CollabInitial extends CollabState {
  const CollabInitial();
}

/// 连接中
class CollabConnecting extends CollabState {
  const CollabConnecting();
}

/// 已连接
class CollabConnected extends CollabState {
  final String tripId;
  final List<User> members;
  final List<Preference> preferences;
  final List<Vote> votes;
  final List<Map<String, dynamic>> messages;

  const CollabConnected({
    required this.tripId,
    this.members = const [],
    this.preferences = const [],
    this.votes = const [],
    this.messages = const [],
  });

  /// 在线成员数
  int get memberCount => members.length;

  /// 是否有未读消息
  bool get hasUnreadMessages => messages.isNotEmpty;

  @override
  List<Object?> get props => [tripId, members, preferences, votes, messages];

  /// 复制并修改
  CollabConnected copyWith({
    String? tripId,
    List<User>? members,
    List<Preference>? preferences,
    List<Vote>? votes,
    List<Map<String, dynamic>>? messages,
  }) {
    return CollabConnected(
      tripId: tripId ?? this.tripId,
      members: members ?? this.members,
      preferences: preferences ?? this.preferences,
      votes: votes ?? this.votes,
      messages: messages ?? this.messages,
    );
  }
}

/// 已断开
class CollabDisconnected extends CollabState {
  const CollabDisconnected();
}

/// 协作操作成功
class CollabOperationSuccess extends CollabState {
  final String message;

  const CollabOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// 协作错误
class CollabError extends CollabState {
  final String message;

  const CollabError(this.message);

  @override
  List<Object?> get props => [message];
}
