import '../blocs/map/map_state.dart';
import '../core/network/api_client.dart';

/// 地图服务
/// 提供地图相关的 API 调用和地图功能
class MapService {
  final ApiClient _api = ApiClient.instance;

  /// 获取行程标记点
  /// [tripId] 行程唯一标识
  /// 返回行程中所有活动/餐厅的标记点
  Future<List<MapMarker>> getTripMarkers(String tripId) async {
    // TODO: 实现行程标记点获取
    // final response = await _api.get('/trips/$tripId/markers');
    // final data = response.data['data'] as List;
    // return data.map((json) => MapMarker(
    //   id: json['id'],
    //   title: json['title'],
    //   latitude: json['latitude'],
    //   longitude: json['longitude'],
    //   snippet: json['snippet'],
    //   iconUrl: json['icon_url'],
    // )).toList();
    return [];
  }

  /// 获取附近 POI（兴趣点）
  /// [category] POI 类别（如：restaurant, hotel, attraction）
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [radius] 搜索半径（米）
  Future<List<MapMarker>> getNearbyPoi({
    required String category,
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    // TODO: 实现附近 POI 搜索
    // final response = await _api.get('/map/nearby', queryParameters: {
    //   'category': category,
    //   'latitude': latitude,
    //   'longitude': longitude,
    //   'radius': radius ?? 1000,
    // });
    // final data = response.data['data'] as List;
    // return data.map((json) => MapMarker(
    //   id: json['id'],
    //   title: json['name'],
    //   latitude: json['location']['lat'],
    //   longitude: json['location']['lng'],
    //   snippet: json['address'],
    // )).toList();
    return [];
  }

  /// 搜索地点
  /// [query] 搜索关键词
  /// [latitude] 中心点纬度
  /// [longitude] 中心点经度
  Future<List<MapMarker>> searchPlace({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    // TODO: 实现地点搜索
    // final response = await _api.get('/map/search', queryParameters: {
    //   'query': query,
    //   'latitude': latitude,
    //   'longitude': longitude,
    // });
    // final data = response.data['data'] as List;
    // return data.map((json) => MapMarker(
    //   id: json['id'],
    //   title: json['name'],
    //   latitude: json['location']['lat'],
    //   longitude: json['location']['lng'],
    // )).toList();
    return [];
  }

  /// 获取路线规划
  /// [startLat] 起点纬度
  /// [startLng] 起点经度
  /// [endLat] 终点纬度
  /// [endLng] 终点经度
  /// [waypoints] 途经点列表
  Future<Map<String, dynamic>> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    List<Map<String, double>>? waypoints,
  }) async {
    // TODO: 实现路线规划
    // final response = await _api.post('/map/route', data: {
    //   'origin': {'lat': startLat, 'lng': startLng},
    //   'destination': {'lat': endLat, 'lng': endLng},
    //   'waypoints': waypoints,
    // });
    // return response.data['data'];
    return {};
  }

  /// 保存轨迹
  /// [tripId] 行程唯一标识
  /// [points] 轨迹点列表
  Future<void> saveTrajectory(
    String tripId,
    List<Map<String, dynamic>> points,
  ) async {
    // TODO: 实现轨迹保存
    // await _api.post('/trips/$tripId/trajectory', data: {
    //   'points': points,
    // });
  }

  /// 获取行程轨迹
  /// [tripId] 行程唯一标识
  Future<List<Map<String, dynamic>>> getTrajectory(String tripId) async {
    // TODO: 实现轨迹获取
    // final response = await _api.get('/trips/$tripId/trajectory');
    // return response.data['data'] as List;
    return [];
  }

  /// 地理编码（地址 -> 坐标）
  Future<Map<String, double>?> geocode(String address) async {
    // TODO: 实现地理编码
    // final response = await _api.get('/map/geocode', queryParameters: {
    //   'address': address,
    // });
    // final data = response.data['data'];
    // return {'latitude': data['lat'], 'longitude': data['lng']};
    return null;
  }

  /// 逆地理编码（坐标 -> 地址）
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    // TODO: 实现逆地理编码
    // final response = await _api.get('/map/reverse-geocode', queryParameters: {
    //   'latitude': latitude,
    //   'longitude': longitude,
    // });
    // return response.data['data']['address'];
    return null;
  }
}
