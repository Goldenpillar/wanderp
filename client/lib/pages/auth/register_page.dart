import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../config/routes.dart';

/// 注册页面
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  /// 表单 Key
  final _formKey = GlobalKey<FormState>();

  /// 用户名控制器
  final _usernameController = TextEditingController();

  /// 昵称控制器
  final _nicknameController = TextEditingController();

  /// 邮箱控制器
  final _emailController = TextEditingController();

  /// 密码控制器
  final _passwordController = TextEditingController();

  /// 确认密码控制器
  final _confirmPasswordController = TextEditingController();

  /// 是否隐藏密码
  bool _obscurePassword = true;

  /// 是否同意协议
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 注册
  void _register() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先同意用户协议')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          RegisterRequested(
            username: _usernameController.text,
            password: _passwordController.text,
            email: _emailController.text,
            nickname: _nicknameController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('注册')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 用户名
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: '用于登录',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入用户名';
                      }
                      if (value.length < 3) {
                        return '用户名至少3个字符';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 昵称
                  TextFormField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: '昵称',
                      prefixIcon: Icon(Icons.badge_outlined),
                      hintText: '显示名称',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入昵称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 邮箱
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '邮箱',
                      prefixIcon: Icon(Icons.email_outlined),
                      hintText: '用于找回密码',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入邮箱';
                      }
                      // 简单邮箱验证
                      if (!value.contains('@')) {
                        return '请输入有效的邮箱地址';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 密码
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: '密码',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      hintText: '至少8位，包含字母和数字',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入密码';
                      }
                      if (value.length < 8) {
                        return '密码至少8位';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 确认密码
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    decoration: const InputDecoration(
                      labelText: '确认密码',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请确认密码';
                      }
                      if (value != _passwordController.text) {
                        return '两次密码不一致';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 同意协议
                  CheckboxListTile(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() => _agreedToTerms = value ?? false);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: RichText(
                      text: const TextSpan(
                        text: '我已阅读并同意',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        children: [
                          TextSpan(
                            text: '《用户协议》',
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(text: '和'),
                          TextSpan(
                            text: '《隐私政策》',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 注册按钮
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed:
                            state is AuthLoading ? null : _register,
                        child: state is AuthLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Text('注册'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 登录入口
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('已有账号？'),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('立即登录'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
