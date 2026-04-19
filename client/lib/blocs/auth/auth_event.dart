import 'package:equatable/equatable.dart';

/// 认证 BLoC 事件基类
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// 登录
class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

/// 注册
class RegisterRequested extends AuthEvent {
  final String username;
  final String password;
  final String email;
  final String nickname;

  const RegisterRequested({
    required this.username,
    required this.password,
    required this.email,
    required this.nickname,
  });

  @override
  List<Object?> get props => [username, password, email, nickname];
}

/// 登出
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// 检查认证状态
class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

/// 更新用户信息
class UpdateUserProfile extends AuthEvent {
  final Map<String, dynamic> profileData;

  const UpdateUserProfile(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

/// 修改密码
class ChangePassword extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePassword({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

/// 重置密码
class ResetPassword extends AuthEvent {
  final String email;

  const ResetPassword(this.email);

  @override
  List<Object?> get props => [email];
}
