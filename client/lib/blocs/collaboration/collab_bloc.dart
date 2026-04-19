import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/logger.dart';
import '../../services/collab_service.dart';
import 'collab_event.dart';
import 'collab_state.dart';

/// 协作 BLoC
/// 管理多人协作、实时同步相关的状态
class CollabBloc extends Bloc<CollabEvent, CollabState> {
  final CollabService _collabService;

  CollabBloc({CollabService? collabService})
      : _collabService = collabService ?? CollabService(),
        super(const CollabInitial()) {
    on<ConnectRoom>(_onConnectRoom);
    on<DisconnectRoom>(_onDisconnectRoom);
    on<InviteMember>(_onInviteMember);
    on<RemoveMember>(_onRemoveMember);
    on<SubmitPreference>(_onSubmitPreference);
    on<CreateVote>(_onCreateVote);
    on<CastVote>(_onCastVote);
    on<LoadMembers>(_onLoadMembers);
    on<LoadVotes>(_onLoadVotes);
    on<MessageReceived>(_onMessageReceived);
  }

  /// 处理连接协作房间
  Future<void> _onConnectRoom(
    ConnectRoom event,
    Emitter<CollabState> emit,
  ) async {
    emit(const CollabConnecting());
    try {
      await _collabService.connect(event.tripId);

      // 监听实时消息
      _collabService.onMessage.listen((message) {
        add(MessageReceived(message));
      });

      // 加载成员和投票
      final members = await _collabService.getMembers(event.tripId);
      final votes = await _collabService.getVotes(event.tripId);

      emit(CollabConnected(
        tripId: event.tripId,
        members: members,
        votes: votes,
      ));
    } catch (e) {
      Logger.e('连接协作房间失败: $e');
      emit(CollabError('连接协作房间失败: $e'));
    }
  }

  /// 处理断开协作房间
  Future<void> _onDisconnectRoom(
    DisconnectRoom event,
    Emitter<CollabState> emit,
  ) async {
    try {
      await _collabService.disconnect();
      emit(const CollabDisconnected());
    } catch (e) {
      Logger.e('断开协作房间失败: $e');
    }
  }

  /// 处理邀请成员
  Future<void> _onInviteMember(
    InviteMember event,
    Emitter<CollabState> emit,
  ) async {
    try {
      await _collabService.inviteMember(event.tripId, event.userId);
      // 重新加载成员列表
      add(LoadMembers(event.tripId));
    } catch (e) {
      Logger.e('邀请成员失败: $e');
      emit(CollabError('邀请成员失败: $e'));
    }
  }

  /// 处理移除成员
  Future<void> _onRemoveMember(
    RemoveMember event,
    Emitter<CollabState> emit,
  ) async {
    try {
      await _collabService.removeMember(event.tripId, event.userId);
      add(LoadMembers(event.tripId));
    } catch (e) {
      Logger.e('移除成员失败: $e');
      emit(CollabError('移除成员失败: $e'));
    }
  }

  /// 处理提交偏好
  Future<void> _onSubmitPreference(
    SubmitPreference event,
    Emitter<CollabState> emit,
  ) async {
    try {
      await _collabService.submitPreference(event.tripId, event.preferences);
      emit(const CollabOperationSuccess('偏好提交成功'));
    } catch (e) {
      Logger.e('提交偏好失败: $e');
      emit(CollabError('提交偏好失败: $e'));
    }
  }

  /// 处理创建投票
  Future<void> _onCreateVote(
    CreateVote event,
    Emitter<CollabState> emit,
  ) async {
    try {
      await _collabService.createVote(
        tripId: event.tripId,
        title: event.title,
        description: event.description,
        options: event.options,
      );
      add(LoadVotes(event.tripId));
    } catch (e) {
      Logger.e('创建投票失败: $e');
      emit(CollabError('创建投票失败: $e'));
    }
  }

  /// 处理投票
  Future<void> _onCastVote(
    CastVote event,
    Emitter<CollabState> emit,
  ) async {
    try {
      await _collabService.castVote(event.voteId, event.optionId);
      if (state is CollabConnected) {
        final currentState = state as CollabConnected;
        add(LoadVotes(currentState.tripId));
      }
    } catch (e) {
      Logger.e('投票失败: $e');
      emit(CollabError('投票失败: $e'));
    }
  }

  /// 处理加载成员列表
  Future<void> _onLoadMembers(
    LoadMembers event,
    Emitter<CollabState> emit,
  ) async {
    try {
      final members = await _collabService.getMembers(event.tripId);
      if (state is CollabConnected) {
        final currentState = state as CollabConnected;
        emit(currentState.copyWith(members: members));
      }
    } catch (e) {
      Logger.e('加载成员列表失败: $e');
    }
  }

  /// 处理加载投票列表
  Future<void> _onLoadVotes(
    LoadVotes event,
    Emitter<CollabState> emit,
  ) async {
    try {
      final votes = await _collabService.getVotes(event.tripId);
      if (state is CollabConnected) {
        final currentState = state as CollabConnected;
        emit(currentState.copyWith(votes: votes));
      }
    } catch (e) {
      Logger.e('加载投票列表失败: $e');
    }
  }

  /// 处理接收实时消息
  void _onMessageReceived(
    MessageReceived event,
    Emitter<CollabState> emit,
  ) {
    if (state is CollabConnected) {
      final currentState = state as CollabConnected;
      emit(currentState.copyWith(
        messages: [...currentState.messages, event.message],
      ));
    }
  }
}
