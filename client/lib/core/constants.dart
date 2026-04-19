/// 全局常量定义
class AppConstants {
  AppConstants._();

  // ==================== 应用信息 ====================

  /// 应用名称
  static const String appName = 'WanderP';

  /// 应用包名
  static const String packageName = 'com.wanderp.app';

  // ==================== 存储 Key ====================

  /// 访问令牌
  static const String keyAccessToken = 'access_token';

  /// 刷新令牌
  static const String keyRefreshToken = 'refresh_token';

  /// 用户信息
  static const String keyUserInfo = 'user_info';

  /// 主题模式
  static const String keyThemeMode = 'theme_mode';

  /// 语言设置
  static const String keyLanguage = 'language';

  /// 首次启动标记
  static const String keyFirstLaunch = 'first_launch';

  /// 当前行程 ID
  static const String keyCurrentTripId = 'current_trip_id';

  // ==================== 分页 ====================

  /// 默认页码
  static const int defaultPage = 1;

  /// 默认每页数量
  static const int defaultPageSize = 20;

  /// 最大每页数量
  static const int maxPageSize = 100;

  // ==================== 地图 ====================

  /// 默认地图缩放级别
  static const double defaultMapZoom = 15.0;

  /// 默认地图中心（北京天安门）
  static const double defaultMapCenterLat = 39.9042;
  static const double defaultMapCenterLng = 116.4074;

  /// 定位更新最小距离（米）
  static const double locationUpdateDistance = 10.0;

  // ==================== 协作 ====================

  /// WebSocket 重连间隔（秒）
  static const int wsReconnectInterval = 5;

  /// WebSocket 最大重连次数
  static const int wsMaxReconnectAttempts = 10;

  /// MQTT 保持连接间隔（秒）
  static const int mqttKeepAlive = 60;

  // ==================== 消费 ====================

  /// 支持的货币列表
  static const List<String> supportedCurrencies = ['CNY', 'USD', 'EUR', 'JPY', 'GBP'];

  /// 默认货币
  static const String defaultCurrency = 'CNY';

  // ==================== 正则表达式 ====================

  /// 邮箱正则
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// 手机号正则（中国大陆）
  static final RegExp phoneRegex = RegExp(
    r'^1[3-9]\d{9}$',
  );

  /// 密码正则（至少8位，包含字母和数字）
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
  );

  // ==================== 动画 ====================

  /// 页面过渡动画时长
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  /// 按钮点击动画时长
  static const Duration buttonAnimationDuration = Duration(milliseconds: 150);

  // ==================== 尺寸 ====================

  /// 默认边距
  static const double defaultPadding = 16.0;

  /// 小边距
  static const double smallPadding = 8.0;

  /// 大边距
  static const double largePadding = 24.0;

  /// 卡片圆角
  static const double cardBorderRadius = 12.0;

  /// 按钮圆角
  static const double buttonBorderRadius = 8.0;

  /// 图标大小
  static const double defaultIconSize = 24.0;
}
