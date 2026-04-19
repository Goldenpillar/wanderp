import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';

/// 设置页面
/// 应用设置和个人信息管理
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // 个人信息区域
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 36),
                ),
                title: const Text('用户名'),
                subtitle: const Text('user@example.com'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 跳转到个人信息编辑
                },
              ),
            ),
          ),

          const Divider(),

          // 通用设置
          _buildSectionHeader('通用设置'),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('深色模式'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: 切换主题
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('语言'),
            subtitle: const Text('简体中文'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 语言设置
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('通知设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 通知设置
            },
          ),

          const Divider(),

          // 地图设置
          _buildSectionHeader('地图设置'),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('默认地图类型'),
            subtitle: const Text('标准地图'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 地图类型选择
            },
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('距离单位'),
            subtitle: const Text('公里'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 距离单位选择
            },
          ),

          const Divider(),

          // 数据管理
          _buildSectionHeader('数据管理'),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('离线数据'),
            subtitle: const Text('管理离线地图和数据'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 离线数据管理
            },
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('清除缓存'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 清除缓存
            },
          ),

          const Divider(),

          // 关于
          _buildSectionHeader('关于'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('关于 WanderP'),
            subtitle: const Text('版本 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 关于页面
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('用户协议'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 用户协议
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('隐私政策'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 隐私政策
            },
          ),

          const SizedBox(height: 16),

          // 退出登录
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('退出登录'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 显示退出登录确认对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 执行退出登录
              context.go(AppRoutes.login);
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
