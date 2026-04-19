import 'package:flutter/material.dart';

/// 轨迹页面
/// 显示行程轨迹记录和回放
class TrajectoryPage extends StatelessWidget {
  const TrajectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('轨迹记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // TODO: 开始轨迹回放
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 轨迹地图区域
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Text('轨迹地图视图'),
              ),
            ),
          ),

          // 轨迹信息面板
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '轨迹统计',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('总距离', '0.0 km'),
                      _buildStatItem('总时间', '0:00'),
                      _buildStatItem('平均速度', '0 km/h'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 轨迹列表
                  Expanded(
                    child: ListView(
                      children: [
                        _buildTrajectoryItem(
                          '起点',
                          '39.9042, 116.4074',
                          '09:00',
                        ),
                        _buildTrajectoryItem(
                          '途经点 1',
                          '39.9100, 116.4100',
                          '09:30',
                        ),
                        _buildTrajectoryItem(
                          '终点',
                          '39.9200, 116.4200',
                          '10:00',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: 清除轨迹
                  },
                  child: const Text('清除轨迹'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 导出轨迹
                  },
                  child: const Text('导出轨迹'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  /// 构建轨迹项
  Widget _buildTrajectoryItem(String title, String coordinate, String time) {
    return ListTile(
      leading: const Icon(Icons.circle, size: 12),
      title: Text(title),
      subtitle: Text(coordinate),
      trailing: Text(time, style: const TextStyle(color: Colors.grey)),
    );
  }
}
