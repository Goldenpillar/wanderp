import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'config/app_config.dart';

/// 应用程序入口
void main() async {
  // 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive 本地存储
  await Hive.initFlutter();

  // 初始化应用配置（根据环境选择）
  await AppConfig.init(Environment.production);

  // 启动应用
  runApp(
    const ProviderScope(
      child: WanderPApp(),
    ),
  );
}
