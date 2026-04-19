import '../core/network/api_client.dart';
import '../models/user.dart';

/// 认证服务
/// 提供用户认证相关的 API 调用
class AuthService {
  final ApiClient _api = ApiClient.instance;

  /// 用户登录
  /// [username] 用户名
  /// [password] 密码
  /// 返回 Token 信息
  Future<Map<String, String>> login({
    required String username,
    required String password,
  }) async {
    // TODO: 实现用户登录
    // final response = await _api.post('/auth/login', data: {
    //   'username': username,
    //   'password': password,
    // });
    // return {
    //   'access_token': response.data['data']['access_token'],
    //   'refresh_token': response.data['data']['refresh_token'],
    // };
    return {};
  }

  /// 用户注册
  /// [username] 用户名
  /// [password] 密码
  /// [email] 邮箱
  /// [nickname] 昵称
  Future<void> register({
    required String username,
    required String password,
    required String email,
    required String nickname,
  }) async {
    // TODO: 实现用户注册
    // await _api.post('/auth/register', data: {
    //   'username': username,
    //   'password': password,
    //   'email': email,
    //   'nickname': nickname,
    // });
  }

  /// 用户登出
  Future<void> logout() async {
    // TODO: 实现用户登出
    // await _api.post('/auth/logout');
  }

  /// 获取用户信息
  Future<User> getUserProfile() async {
    // TODO: 实现获取用户信息
    // final response = await _api.get('/auth/profile');
    // return User.fromJson(response.data['data']);
    throw UnimplementedError();
  }

  /// 更新用户信息
  /// [profileData] 需要更新的用户信息
  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    // TODO: 实现更新用户信息
    // final response = await _api.put('/auth/profile', data: profileData);
    // return User.fromJson(response.data['data']);
    throw UnimplementedError();
  }

  /// 修改密码
  /// [oldPassword] 旧密码
  /// [newPassword] 新密码
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // TODO: 实现修改密码
    // await _api.put('/auth/password', data: {
    //   'old_password': oldPassword,
    //   'new_password': newPassword,
    // });
  }

  /// 重置密码（通过邮箱）
  /// [email] 注册邮箱
  Future<void> resetPassword({required String email}) async {
    // TODO: 实现重置密码
    // await _api.post('/auth/reset-password', data: {'email': email});
  }

  /// 刷新 Token
  /// [refreshToken] 刷新令牌
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    // TODO: 实现 Token 刷新
    // final response = await _api.post('/auth/refresh', data: {
    //   'refresh_token': refreshToken,
    // });
    // return {
    //   'access_token': response.data['data']['access_token'],
    //   'refresh_token': response.data['data']['refresh_token'],
    // };
    return {};
  }

  /// 第三方登录（微信）
  /// [code] 微信授权码
  Future<Map<String, String>> loginWithWechat(String code) async {
    // TODO: 实现微信登录
    // final response = await _api.post('/auth/wechat', data: {'code': code});
    // return {
    //   'access_token': response.data['data']['access_token'],
    //   'refresh_token': response.data['data']['refresh_token'],
    // };
    return {};
  }

  /// 上传头像
  /// [filePath] 本地文件路径
  Future<String> uploadAvatar(String filePath) async {
    // TODO: 实现头像上传
    // final formData = FormData.fromMap({
    //   'avatar': await MultipartFile.fromFile(filePath),
    // });
    // final response = await _api.upload('/auth/avatar', formData: formData);
    // return response.data['data']['url'];
    return '';
  }
}
