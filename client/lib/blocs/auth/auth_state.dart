import 'package:equatable/equatable.dart';

import '../../models/user.dart';

/// 认证 BLoC 状态基类
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// 加载中
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// 已认证
class AuthAuthenticated extends AuthState {
  final User user;
  final String accessToken;

  const AuthAuthenticated({required this.user, required this.accessToken});

  /// 是否已认证
  bool get isAuthenticated => true;

  @override
  List<Object?> get props => [user, accessToken];
}

/// 未认证
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  /// 是否已认证
  bool get isAuthenticated => false;
}

/// 认证错误
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
