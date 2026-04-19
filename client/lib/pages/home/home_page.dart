import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes.dart';

/// 首页
/// 显示"今天去哪"推荐和快捷入口
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 当前选中的底部导航索引
  int _currentIndex = 0;

  /// 底部导航页面列表
  final List<Widget> _pages = const [
    _TodayPage(),
    _ExplorePage(),
    _MapShortcutPage(),
    _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '今天',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: '地图',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

/// "今天去哪"页面
class _TodayPage extends StatelessWidget {
  const _TodayPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今天去哪'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 跳转到通知页面
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索框
            TextField(
              decoration: InputDecoration(
                hintText: '搜索目的地、景点、美食...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () {
                    // TODO: 打开筛选面板
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 当前行程卡片
            _buildCurrentTripCard(context),
            const SizedBox(height: 24),

            // 天气组件占位
            _buildWeatherSection(context),
            const SizedBox(height: 24),

            // 今日推荐
            _buildTodayRecommendations(context),
          ],
        ),
      ),
      // 浮动创建按钮
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.tripCreate),
        icon: const Icon(Icons.add),
        label: const Text('创建行程'),
      ),
    );
  }

  /// 构建当前行程卡片
  Widget _buildCurrentTripCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '当前行程',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.tripList),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('暂无进行中的行程'),
          ],
        ),
      ),
    );
  }

  /// 构建天气区域
  Widget _buildWeatherSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '今日天气',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.wb_sunny, size: 48, color: Colors.amber[700]),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('25°C', style: TextStyle(fontSize: 24)),
                    Text('晴 | 适宜出行'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建今日推荐
  Widget _buildTodayRecommendations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '今日推荐',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // TODO: 接入推荐数据后替换为实际组件
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('根据您的偏好为您推荐...'),
          ),
        ),
      ],
    );
  }
}

/// 发现页面
class _ExplorePage extends StatelessWidget {
  const _ExplorePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发现')),
      body: const Center(child: Text('发现页面 - 待实现')),
    );
  }
}

/// 地图快捷入口页面
class _MapShortcutPage extends StatelessWidget {
  const _MapShortcutPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地图')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.map),
              child: const Text('打开地图'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 个人中心页面
class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 用户信息卡片
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 36),
                ),
                title: const Text('未登录'),
                subtitle: const Text('点击登录以使用更多功能'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.login),
              ),
            ),
            const SizedBox(height: 16),

            // 功能列表
            ListTile(
              leading: const Icon(Icons.flight_takeoff),
              title: const Text('我的行程'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.tripList),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('美食收藏'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.foodExplore),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('消费记录'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.expense),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('协作空间'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.invite),
            ),
          ],
        ),
      ),
    );
  }
}
