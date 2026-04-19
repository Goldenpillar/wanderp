import '../core/network/api_client.dart';

/// 天气服务
/// 提供天气查询相关的 API 调用
class WeatherService {
  final ApiClient _api = ApiClient.instance;

  /// 获取当前天气
  /// [latitude] 纬度
  /// [longitude] 经度
  /// 返回当前天气信息（温度、湿度、天气状况等）
  Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    // TODO: 实现当前天气获取
    // final response = await _api.get('/weather/current', queryParameters: {
    //   'latitude': latitude,
    //   'longitude': longitude,
    // });
    // return response.data['data'];
    return {};
  }

  /// 获取天气预报
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [days] 预报天数（默认7天）
  Future<List<Map<String, dynamic>>> getForecast({
    required double latitude,
    required double longitude,
    int days = 7,
  }) async {
    // TODO: 实现天气预报获取
    // final response = await _api.get('/weather/forecast', queryParameters: {
    //   'latitude': latitude,
    //   'longitude': longitude,
    //   'days': days,
    // });
    // return response.data['data'] as List;
    return [];
  }

  /// 获取天气预警信息
  /// [latitude] 纬度
  /// [longitude] 经度
  Future<List<Map<String, dynamic>>> getAlerts({
    required double latitude,
    required double longitude,
  }) async {
    // TODO: 实现天气预警获取
    // final response = await _api.get('/weather/alerts', queryParameters: {
    //   'latitude': latitude,
    //   'longitude': longitude,
    // });
    // return response.data['data'] as List;
    return [];
  }

  /// 获取空气质量指数
  /// [latitude] 纬度
  /// [longitude] 经度
  Future<Map<String, dynamic>> getAirQuality({
    required double latitude,
    required double longitude,
  }) async {
    // TODO: 实现空气质量获取
    // final response = await _api.get('/weather/air-quality', queryParameters: {
    //   'latitude': latitude,
    //   'longitude': longitude,
    // });
    // return response.data['data'];
    return {};
  }

  /// 根据城市名称获取天气
  /// [cityName] 城市名称
  Future<Map<String, dynamic>> getWeatherByCity(String cityName) async {
    // TODO: 实现城市天气获取
    // final response = await _api.get('/weather/city/$cityName');
    // return response.data['data'];
    return {};
  }
}
