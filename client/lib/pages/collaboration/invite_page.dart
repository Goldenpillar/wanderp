import 'package:flutter/material.dart';

/// 邀请成员页面
/// 用于邀请其他用户加入行程协作
class InvitePage extends StatelessWidget {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('邀请成员')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 邀请方式
            const Text(
              '邀请方式',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 通过用户名搜索
            TextField(
              decoration: InputDecoration(
                hintText: '搜索用户名或手机号',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.person_search),
                  onPressed: () {
                    // TODO: 搜索用户
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 快捷邀请方式
            const Text(
              '快捷邀请',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 邀请链接
            Card(
              child: ListTile(
                leading: const Icon(Icons.link),
                title: const Text('复制邀请链接'),
                subtitle: const Text('通过链接邀请好友加入行程'),
                trailing: const Icon(Icons.copy),
                onTap: () {
                  // TODO: 复制邀请链接
                },
              ),
            ),

            // 微信邀请
            Card(
              child: ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text('微信邀请'),
                subtitle: const Text('通过微信分享邀请'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 微信分享
                },
              ),
            ),

            // 二维码邀请
            Card(
              child: ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('二维码邀请'),
                subtitle: const Text('展示二维码让好友扫码加入'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: 显示二维码
                },
              ),
            ),

            const SizedBox(height: 24),

            // 已邀请成员列表
            const Text(
              '已邀请成员',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 成员列表占位
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无已邀请的成员'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
