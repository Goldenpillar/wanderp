import 'dart:async';

import '../blocs/collaboration/collab_state.dart';
import '../core/network/api_client.dart';
import '../core/utils/logger.dart';
import '../models/user.dart';
import '../models/preference.dart';

/// 协作服务
/// 基于 Yjs 的实时协作服务，提供多人同步编辑能力
class CollabService {
  final ApiClient _api = ApiClient.instance;

  /// WebSocket 连接
  // WebSocketChannel? _webSocketChannel;

  /// 消息流控制器
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// 消息流
  Stream<Map<String, dynamic>> get onMessage => _messageController.stream;

  /// 是否已连接
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// 连接协作房间
  /// [tripId] 行程唯一标识
  Future<void> connect(String tripId) async {
    // TODO: 实现 WebSocket 连接
    // final wsUrl = '${AppConfig.instance.wsBaseUrl}/collab/$tripId';
    // _webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
    //
    // _webSocketChannel!.stream.listen(
    //   (data) {
    //     final message = jsonDecode(data as String) as Map<String, dynamic>;
    //     _messageController.add(message);
    //   },
    //   onDone: () {
    //     _isConnected = false;
    //     Logger.i('协作连接已断开');
    //   },
    //   onError: (error) {
    //     _isConnected = false;
    //     Logger.e('协作连接错误: $error');
    //   },
    // );
    //
    // _isConnected = true;
    Logger.i('连接协作房间: $tripId');
  }

  /// 断开协作房间
  Future<void> disconnect() async {
    // TODO: 实现断开连接
    // await _webSocketChannel?.sink.close();
    // _webSocketChannel = null;
    _isConnected = false;
    Logger.i('已断开协作连接');
  }

  /// 发送消息
  /// [message] 消息内容
  Future<void> sendMessage(Map<String, dynamic> message) async {
    // TODO: 实现消息发送
    // if (_webSocketChannel != null && _isConnected) {
    //   _webSocketChannel!.sink.add(jsonEncode(message));
    // }
    Logger.d('发送协作消息: $message');
  }

  /// 邀请成员
  /// [tripId] 行程唯一标识
  /// [userId] 被邀请的用户 ID
  Future<void> inviteMember(String tripId, String userId) async {
    // TODO: 实现成员邀请
    // await _api.post('/collab/$tripId/invite', data: {'user_id': userId});
  }

  /// 移除成员
  /// [tripId] 行程唯一标识
  /// [userId] 被移除的用户 ID
  Future<void> removeMember(String tripId, String userId) async {
    // TODO: 实现成员移除
    // await _api.post('/collab/$tripId/remove', data: {'user_id': userId});
  }

  /// 获取成员列表
  /// [tripId] 行程唯一标识
  Future<List<User>> getMembers(String tripId) async {
    // TODO: 实现成员列表获取
    // final response = await _api.get('/collab/$tripId/members');
    // final data = response.data['data'] as List;
    // return data.map((json) => User.fromJson(json)).toList();
    return [];
  }

  /// 提交偏好
  /// [tripId] 行程唯一标识
  /// [preferences] 偏好数据
  Future<void> submitPreference(
    String tripId,
    Map<String, dynamic> preferences,
  ) async {
    // TODO: 实现偏好提交
    // await _api.post('/collab/$tripId/preferences', data: preferences);
    // 同时通过 WebSocket 广播偏好变更
    await sendMessage({
      'type': 'preference_update',
      'trip_id': tripId,
      'data': preferences,
    });
  }

  /// 获取所有成员偏好
  /// [tripId] 行程唯一标识
  Future<List<Preference>> getPreferences(String tripId) async {
    // TODO: 实现偏好列表获取
    // final response = await _api.get('/collab/$tripId/preferences');
    // final data = response.data['data'] as List;
    // return data.map((json) => Preference.fromJson(json)).toList();
    return [];
  }

  /// 创建投票
  /// [tripId] 行程唯一标识
  /// [title] 投票标题
  /// [description] 投票描述
  /// [options] 投票选项列表
  Future<void> createVote({
    required String tripId,
    required String title,
    required String description,
    required List<String> options,
  }) async {
    // TODO: 实现投票创建
    // await _api.post('/collab/$tripId/votes', data: {
    //   'title': title,
    //   'description': description,
    //   'options': options,
    // });
  }

  /// 投票
  /// [voteId] 投票唯一标识
  /// [optionId] 选项唯一标识
  Future<void> castVote(String voteId, String optionId) async {
    // TODO: 实现投票
    // await _api.post('/collab/votes/$voteId/cast', data: {
    //   'option_id': optionId,
    // });
  }

  /// 获取投票列表
  /// [tripId] 行程唯一标识
  Future<List<Vote>> getVotes(String tripId) async {
    // TODO: 实现投票列表获取
    // final response = await _api.get('/collab/$tripId/votes');
    // final data = response.data['data'] as List;
    // return data.map((json) => Vote.fromJson(json)).toList();
    return [];
  }

  /// 同步行程变更（Yjs CRDT）
  /// [tripId] 行程唯一标识
  /// [update] Yjs 更新数据
  Future<void> syncTripUpdate(String tripId, List<int> update) async {
    // TODO: 实现 Yjs CRDT 同步
    // await _api.post('/collab/$tripId/sync', data: {
    //   'update': update,
    // });
  }

  /// 获取行程同步状态
  /// [tripId] 行程唯一标识
  Future<List<int>> getSyncState(String tripId) async {
    // TODO: 实现同步状态获取
    // final response = await _api.get('/collab/$tripId/sync-state');
    // return response.data['data']['update'];
    return [];
  }

  /// 释放资源
  void dispose() {
    _messageController.close();
  }
}
