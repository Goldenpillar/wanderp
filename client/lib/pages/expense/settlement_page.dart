import 'package:flutter/material.dart';

/// 费用结算页面
/// 显示成员之间的费用分摊和结算方案
class SettlementPage extends StatelessWidget {
  const SettlementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('费用结算')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 结算概览
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '结算概览',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('总消费'),
                      Text('¥2,580.00',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('人均'),
                      Text('¥860.00',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('成员数'),
                      Text('3人'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 结算方案
          const Text(
            '推荐结算方案',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '以下是最优的转账方案，最少转账次数',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),

          _buildSettlementItem(
            from: '李四',
            to: '我',
            amount: '¥480.00',
          ),
          _buildSettlementItem(
            from: '王五',
            to: '我',
            amount: '¥320.00',
          ),
          _buildSettlementItem(
            from: '王五',
            to: '李四',
            amount: '¥60.00',
          ),

          const SizedBox(height: 24),

          // 成员明细
          const Text(
            '成员明细',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildMemberDetail(
            name: '我',
            paid: '¥1,280.00',
            share: '¥860.00',
            balance: '+¥420.00',
            isPositive: true,
          ),
          _buildMemberDetail(
            name: '李四',
            paid: '¥680.00',
            share: '¥860.00',
            balance: '-¥180.00',
            isPositive: false,
          ),
          _buildMemberDetail(
            name: '王五',
            paid: '¥620.00',
            share: '¥860.00',
            balance: '-¥240.00',
            isPositive: false,
          ),

          const SizedBox(height: 32),

          // 结算按钮
          ElevatedButton(
            onPressed: () {
              // TODO: 标记已结算
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('确认全部已结算'),
          ),
        ],
      ),
    );
  }

  /// 构建结算项
  Widget _buildSettlementItem({
    required String from,
    required String to,
    required String amount,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.red[50],
              child: Text(
                from[0],
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$from 转给 $to',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建成员明细
  Widget _buildMemberDetail({
    required String name,
    required String paid,
    required String share,
    required String balance,
    required bool isPositive,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(child: Text(name)),
            Text('付$paid', style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Text('摊$share', style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Text(
              balance,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
