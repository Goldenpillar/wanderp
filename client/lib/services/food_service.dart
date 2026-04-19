import '../models/restaurant.dart';
import '../core/network/api_client.dart';

/// 美食服务
/// 提供餐厅推荐、搜索等 API 调用
class FoodService {
  final ApiClient _api = ApiClient.instance;

  /// 获取美食推荐列表
  /// [tripId] 行程 ID（可选，用于获取行程相关的推荐）
  /// [latitude] 纬度（用于附近推荐）
  /// [longitude] 经度（用于附近推荐）
  /// [cuisine] 菜系筛选
  Future<List<Restaurant>> getRecommendations({
    String? tripId,
    double? latitude,
    double? longitude,
    String? cuisine,
  }) async {
    // TODO: 实现美食推荐获取
    // final response = await _api.get('/food/recommendations', queryParameters: {
    //   if (tripId != null) 'trip_id': tripId,
    //   if (latitude != null) 'latitude': latitude,
    //   if (longitude != null) 'longitude': longitude,
    //   if (cuisine != null) 'cuisine': cuisine,
    // });
    // final data = response.data['data'] as List;
    // return data.map((json) => Restaurant.fromJson(json)).toList();
    return [];
  }

  /// 获取餐厅详情
  /// [restaurantId] 餐厅唯一标识
  Future<Restaurant> getRestaurantDetail(String restaurantId) async {
    // TODO: 实现餐厅详情获取
    // final response = await _api.get('/food/restaurants/$restaurantId');
    // return Restaurant.fromJson(response.data['data']);
    throw UnimplementedError();
  }

  /// 搜索餐厅
  /// [query] 搜索关键词
  /// [latitude] 纬度（用于距离排序）
  /// [longitude] 经度（用于距离排序）
  Future<List<Restaurant>> searchRestaurants({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    // TODO: 实现餐厅搜索
    // final response = await _api.get('/food/search', queryParameters: {
    //   'query': query,
    //   if (latitude != null) 'latitude': latitude,
    //   if (longitude != null) 'longitude': longitude,
    // });
    // final data = response.data['data'] as List;
    // return data.map((json) => Restaurant.fromJson(json)).toList();
    return [];
  }

  /// 收藏/取消收藏餐厅
  /// [restaurantId] 餐厅唯一标识
  Future<void> toggleFavorite(String restaurantId) async {
    // TODO: 实现收藏切换
    // await _api.post('/food/restaurants/$restaurantId/favorite');
  }

  /// 获取收藏列表
  Future<List<Restaurant>> getFavorites() async {
    // TODO: 实现收藏列表获取
    // final response = await _api.get('/food/favorites');
    // final data = response.data['data'] as List;
    // return data.map((json) => Restaurant.fromJson(json)).toList();
    return [];
  }

  /// 获取餐厅评论列表
  /// [restaurantId] 餐厅唯一标识
  /// [page] 页码
  /// [pageSize] 每页数量
  Future<List<dynamic>> getReviews({
    required String restaurantId,
    int page = 1,
    int pageSize = 20,
  }) async {
    // TODO: 实现评论列表获取
    // final response = await _api.get('/food/restaurants/$restaurantId/reviews',
    //   queryParameters: {'page': page, 'page_size': pageSize},
    // );
    // return response.data['data'] as List;
    return [];
  }

  /// 提交餐厅评论
  /// [restaurantId] 餐厅唯一标识
  /// [rating] 评分（1-5）
  /// [content] 评论内容
  Future<void> submitReview({
    required String restaurantId,
    required int rating,
    required String content,
  }) async {
    // TODO: 实现评论提交
    // await _api.post('/food/restaurants/$restaurantId/reviews', data: {
    //   'rating': rating,
    //   'content': content,
    // });
  }

  /// 获取菜系列表
  Future<List<String>> getCuisines() async {
    // TODO: 实现菜系列表获取
    // final response = await _api.get('/food/cuisines');
    // return (response.data['data'] as List).cast<String>();
    return [];
  }
}
