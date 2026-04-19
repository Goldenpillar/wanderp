import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import '../../core/utils/logger.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// 认证 BLoC
/// 管理用户登录、注册、登出等认证状态
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<ChangePassword>(_onChangePassword);
    on<ResetPassword>(_onResetPassword);
  }

  /// 处理登录请求
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authService.login(
        username: event.username,
        password: event.password,
      );

      // 保存 Token
      await LocalStorage.instance.setString('access_token', result['access_token']);
      await LocalStorage.instance.setString('refresh_token', result['refresh_token']);

      // 获取用户信息
      final user = await _authService.getUserProfile();
      emit(AuthAuthenticated(user: user, accessToken: result['access_token']));
    } catch (e) {
      Logger.e('登录失败: $e');
      emit(AuthError('登录失败: $e'));
    }
  }

  /// 处理注册请求
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authService.register(
        username: event.username,
        password: event.password,
        email: event.email,
        nickname: event.nickname,
      );
      // 注册成功后自动登录
      add(LoginRequested(
        username: event.username,
        password: event.password,
      ));
    } catch (e) {
      Logger.e('注册失败: $e');
      emit(AuthError('注册失败: $e'));
    }
  }

  /// 处理登出请求
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.logout();
    } catch (e) {
      Logger.e('登出失败: $e');
    } finally {
      // 清除本地存储
      await LocalStorage.instance.remove('access_token');
      await LocalStorage.instance.remove('refresh_token');
      await LocalStorage.instance.remove('user_info');
      emit(const AuthUnauthenticated());
    }
  }

  /// 处理检查认证状态
  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final token = LocalStorage.instance.getString('access_token');
    if (token == null || token.isEmpty) {
      emit(const AuthUnauthenticated());
      return;
    }

    try {
      final user = await _authService.getUserProfile();
      emit(AuthAuthenticated(user: user, accessToken: token));
    } catch (e) {
      // Token 无效，清除并跳转到登录
      await LocalStorage.instance.remove('access_token');
      await LocalStorage.instance.remove('refresh_token');
      emit(const AuthUnauthenticated());
    }
  }

  /// 处理更新用户信息
  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authService.updateProfile(event.profileData);
      if (state is AuthAuthenticated) {
        final currentState = state as AuthAuthenticated;
        emit(AuthAuthenticated(
          user: user,
          accessToken: currentState.accessToken,
        ));
      }
    } catch (e) {
      Logger.e('更新用户信息失败: $e');
      emit(AuthError('更新用户信息失败: $e'));
    }
  }

  /// 处理修改密码
  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.changePassword(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      );
      // 密码修改成功，需要重新登录
      emit(const AuthUnauthenticated());
    } catch (e) {
      Logger.e('修改密码失败: $e');
      emit(AuthError('修改密码失败: $e'));
    }
  }

  /// 处理重置密码
  Future<void> _onResetPassword(
    ResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authService.resetPassword(email: event.email);
      emit(const AuthUnauthenticated());
    } catch (e) {
      Logger.e('重置密码失败: $e');
      emit(AuthError('重置密码失败: $e'));
    }
  }
}
