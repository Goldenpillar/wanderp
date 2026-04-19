/// 路由常量定义
class AppRoutes {
  AppRoutes._();

  // ==================== 首页 ====================
  static const String home = '/home';

  // ==================== 行程 ====================
  static const String tripList = '/trips';
  static const String tripCreate = '/trips/create';
  static const String tripDetail = '/trips/:id';

  // ==================== 地图 ====================
  static const String map = '/map';
  static const String trajectory = '/trajectory';

  // ==================== 美食 ====================
  static const String foodExplore = '/food';
  static const String foodDetail = '/food/:id';

  // ==================== 协作 ====================
  static const String invite = '/collab/invite';
  static const String preference = '/collab/preference';
  static const String vote = '/collab/vote';

  // ==================== 消费 ====================
  static const String expense = '/expense';
  static const String settlement = '/expense/settlement';

  // ==================== 认证 ====================
  static const String login = '/login';
  static const String register = '/register';

  // ==================== 设置 ====================
  static const String settings = '/settings';
}
