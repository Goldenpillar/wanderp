import '../core/network/api_client.dart';
import '../models/trip.dart';
import '../models/activity.dart';

/// 行程服务
/// 提供行程相关的 API 调用
class TripService {
  final ApiClient _api = ApiClient.instance;

  /// 获取行程列表
  /// 返回当前用户的所有行程
  Future<List<Trip>> getTrips() async {
    // TODO: 实现行程列表获取
    // final response = await _api.get('/trips');
    // final data = response.data['data'] as List;
    // return data.map((json) => Trip.fromJson(json)).toList();
    return [];
  }

  /// 获取行程详情
  /// [tripId] 行程唯一标识
  Future<Trip> getTripDetail(String tripId) async {
    // TODO: 实现行程详情获取
    // final response = await _api.get('/trips/$tripId');
    // return Trip.fromJson(response.data['data']);
    throw UnimplementedError();
  }

  /// 创建行程
  /// [tripData] 行程数据（名称、目的地、日期等）
  Future<Trip> createTrip(Map<String, dynamic> tripData) async {
    // TODO: 实现行程创建
    // final response = await _api.post('/trips', data: tripData);
    // return Trip.fromJson(response.data['data']);
    throw UnimplementedError();
  }

  /// 更新行程
  /// [tripId] 行程唯一标识
  /// [tripData] 需要更新的行程数据
  Future<Trip> updateTrip(String tripId, Map<String, dynamic> tripData) async {
    // TODO: 实现行程更新
    // final response = await _api.put('/trips/$tripId', data: tripData);
    // return Trip.fromJson(response.data['data']);
    throw UnimplementedError();
  }

  /// 删除行程
  /// [tripId] 行程唯一标识
  Future<void> deleteTrip(String tripId) async {
    // TODO: 实现行程删除
    // await _api.delete('/trips/$tripId');
    throw UnimplementedError();
  }

  /// 获取行程下的活动列表
  /// [tripId] 行程唯一标识
  Future<List<Activity>> getActivities(String tripId) async {
    // TODO: 实现活动列表获取
    // final response = await _api.get('/trips/$tripId/activities');
    // final data = response.data['data'] as List;
    // return data.map((json) => Activity.fromJson(json)).toList();
    return [];
  }

  /// 添加活动到行程
  /// [tripId] 行程唯一标识
  /// [activityData] 活动数据
  Future<Activity> addActivity(
    String tripId,
    Map<String, dynamic> activityData,
  ) async {
    // TODO: 实现活动添加
    // final response = await _api.post('/trips/$tripId/activities', data: activityData);
    // return Activity.fromJson(response.data['data']);
    throw UnimplementedError();
  }

  /// 移除行程中的活动
  /// [tripId] 行程唯一标识
  /// [activityId] 活动唯一标识
  Future<void> removeActivity(String tripId, String activityId) async {
    // TODO: 实现活动移除
    // await _api.delete('/trips/$tripId/activities/$activityId');
    throw UnimplementedError();
  }

  /// 更新行程预算
  /// [tripId] 行程唯一标识
  /// [budget] 预算金额（分）
  Future<void> updateBudget(String tripId, int budget) async {
    // TODO: 实现预算更新
    // await _api.put('/trips/$tripId/budget', data: {'budget': budget});
    throw UnimplementedError();
  }

  /// 邀请成员加入行程
  /// [tripId] 行程唯一标识
  /// [userId] 被邀请的用户 ID
  Future<void> inviteMember(String tripId, String userId) async {
    // TODO: 实现成员邀请
    // await _api.post('/trips/$tripId/members', data: {'user_id': userId});
    throw UnimplementedError();
  }

  /// 获取行程成员列表
  /// [tripId] 行程唯一标识
  Future<List<dynamic>> getMembers(String tripId) async {
    // TODO: 实现成员列表获取
    // final response = await _api.get('/trips/$tripId/members');
    // return response.data['data'] as List;
    return [];
  }
}
