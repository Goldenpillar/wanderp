/// 应用环境枚举
enum Environment {
  development,
  staging,
  production,
}

/// 应用全局配置
/// 包含所有外部 API 地址、密钥等配置信息
class AppConfig {
  AppConfig._();

  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  /// 当前环境
  static late Environment environment;

  // ==================== API 配置 ====================

  /// 后端 API 基础地址
  late String apiBaseUrl;

  /// WebSocket 地址
  late String wsBaseUrl;

  /// MQTT Broker 地址
  late String mqttBrokerUrl;

  /// MQTT 端口
  late int mqttPort;

  /// MQTT 用户名
  late String mqttUsername;

  /// MQTT 密码
  late String mqttPassword;

  // ==================== 地图配置 ====================

  /// 高德地图 API Key（Android）
  late String amapAndroidKey;

  /// 高德地图 API Key（iOS）
  late String amapIosKey;

  /// 高德地图 Web 服务 Key
  late String amapWebKey;

  // ==================== 第三方服务 ====================

  /// 天气服务 API Key
  late String weatherApiKey;

  /// 翻译服务 API Key
  late String translateApiKey;

  /// 图片上传服务地址
  late String uploadBaseUrl;

  // ==================== 应用配置 ====================

  /// 应用版本号
  String get appVersion => '1.0.0';

  /// 分页默认大小
  int get defaultPageSize => 20;

  /// 请求超时时间（毫秒）
  int get connectTimeout => 15000;

  /// 接收超时时间（毫秒）
  int get receiveTimeout => 15000;

  /// 是否为调试模式
  bool get isDebug => environment != Environment.production;

  /// 初始化配置
  static Future<void> init(Environment env) async {
    environment = env;
    _instance = AppConfig._();
    _instance._loadConfig(env);
  }

  /// 根据环境加载配置
  void _loadConfig(Environment env) {
    switch (env) {
      case Environment.development:
        apiBaseUrl = 'https://dev-api.wanderp.com';
        wsBaseUrl = 'wss://dev-api.wanderp.com/ws';
        mqttBrokerUrl = 'dev-mqtt.wanderp.com';
        mqttPort = 8883;
        mqttUsername = 'dev_user';
        mqttPassword = 'dev_pass';
        amapAndroidKey = 'YOUR_DEV_AMAP_ANDROID_KEY';
        amapIosKey = 'YOUR_DEV_AMAP_IOS_KEY';
        amapWebKey = 'YOUR_DEV_AMAP_WEB_KEY';
        weatherApiKey = 'YOUR_DEV_WEATHER_API_KEY';
        translateApiKey = 'YOUR_DEV_TRANSLATE_API_KEY';
        uploadBaseUrl = 'https://dev-upload.wanderp.com';
        break;
      case Environment.staging:
        apiBaseUrl = 'https://staging-api.wanderp.com';
        wsBaseUrl = 'wss://staging-api.wanderp.com/ws';
        mqttBrokerUrl = 'staging-mqtt.wanderp.com';
        mqttPort = 8883;
        mqttUsername = 'staging_user';
        mqttPassword = 'staging_pass';
        amapAndroidKey = 'YOUR_STAGING_AMAP_ANDROID_KEY';
        amapIosKey = 'YOUR_STAGING_AMAP_IOS_KEY';
        amapWebKey = 'YOUR_STAGING_AMAP_WEB_KEY';
        weatherApiKey = 'YOUR_STAGING_WEATHER_API_KEY';
        translateApiKey = 'YOUR_STAGING_TRANSLATE_API_KEY';
        uploadBaseUrl = 'https://staging-upload.wanderp.com';
        break;
      case Environment.production:
        apiBaseUrl = 'https://api.wanderp.com';
        wsBaseUrl = 'wss://api.wanderp.com/ws';
        mqttBrokerUrl = 'mqtt.wanderp.com';
        mqttPort = 8883;
        mqttUsername = 'prod_user';
        mqttPassword = 'prod_pass';
        amapAndroidKey = 'YOUR_PROD_AMAP_ANDROID_KEY';
        amapIosKey = 'YOUR_PROD_AMAP_IOS_KEY';
        amapWebKey = 'YOUR_PROD_AMAP_WEB_KEY';
        weatherApiKey = 'YOUR_PROD_WEATHER_API_KEY';
        translateApiKey = 'YOUR_PROD_TRANSLATE_API_KEY';
        uploadBaseUrl = 'https://upload.wanderp.com';
        break;
    }
  }
}
