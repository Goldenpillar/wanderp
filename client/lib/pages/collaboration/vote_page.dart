import 'package:flutter/material.dart';

/// 投票决策页面
/// 用于行程中的集体投票决策
class VotePage extends StatelessWidget {
  const VotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投票决策'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateVoteDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 投票项 1
          _buildVoteCard(
            context,
            title: '午餐吃什么？',
            description: '大家投票决定今天的午餐',
            options: [
              _VoteOptionData(label: '火锅', votes: 3, isLeading: true),
              _VoteOptionData(label: '烧烤', votes: 2),
              _VoteOptionData(label: '日料', votes: 1),
            ],
            totalVotes: 6,
            isActive: true,
          ),
          const SizedBox(height: 16),

          // 投票项 2
          _buildVoteCard(
            context,
            title: '明天去哪个景点？',
            description: '选择明天上午的游览景点',
            options: [
              _VoteOptionData(label: '故宫', votes: 4, isLeading: true),
              _VoteOptionData(label: '天坛', votes: 2),
            ],
            totalVotes: 6,
            isActive: true,
          ),
          const SizedBox(height: 16),

          // 已结束的投票
          _buildVoteCard(
            context,
            title: '住宿选择',
            description: '已结束',
            options: [
              _VoteOptionData(label: '民宿', votes: 3, isLeading: true),
              _VoteOptionData(label: '酒店', votes: 2),
            ],
            totalVotes: 5,
            isActive: false,
          ),
        ],
      ),
    );
  }

  /// 构建投票卡片
  Widget _buildVoteCard(
    BuildContext context, {
    required String title,
    required String description,
    required List<_VoteOptionData> options,
    required int totalVotes,
    required bool isActive,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '进行中',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '已结束',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 选项列表
            ...options.map((option) {
              final percentage = totalVotes > 0
                  ? (option.votes / totalVotes * 100).toInt()
                  : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.label,
                            style: TextStyle(
                              fontWeight: option.isLeading
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            color: option.isLeading
                                ? Colors.blue
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${option.votes}票',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        option.isLeading ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              '共 $totalVotes 人参与投票',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示创建投票对话框
  void _showCreateVoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建投票'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '投票标题',
                hintText: '例如：午餐吃什么？',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: '选项 A',
                hintText: '输入选项内容',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText: '选项 B',
                hintText: '输入选项内容',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 创建投票
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}

/// 投票选项数据
class _VoteOptionData {
  final String label;
  final int votes;
  final bool isLeading;

  const _VoteOptionData({
    required this.label,
    required this.votes,
    this.isLeading = false,
  });
}
