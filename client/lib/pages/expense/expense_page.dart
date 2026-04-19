import 'package:flutter/material.dart';

/// 消费管理页面
/// 记录和查看行程中的消费
class ExpensePage extends StatelessWidget {
  const ExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消费管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              // TODO: 查看消费统计
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 消费概览卡片
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '总消费',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  '¥2,580.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text(
                          '我垫付',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '¥1,280.00',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          '待收款',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '¥480.00',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          '待付款',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '¥320.00',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 消费列表
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 日期分组
                _buildDateHeader('今天'),
                _buildExpenseItem(
                  '午餐 - 火锅',
                  '¥256.00',
                  '张三 付',
                  Icons.restaurant,
                ),
                _buildExpenseItem(
                  '故宫门票',
                  '¥120.00',
                  '我 付',
                  Icons.ticket,
                ),
                _buildExpenseItem(
                  '出租车',
                  '¥45.00',
                  '我 付',
                  Icons.local_taxi,
                ),

                _buildDateHeader('昨天'),
                _buildExpenseItem(
                  '酒店住宿',
                  '¥680.00',
                  '李四 付',
                  Icons.hotel,
                ),
                _buildExpenseItem(
                  '晚餐 - 烤鸭',
                  '¥380.00',
                  '我 付',
                  Icons.restaurant,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddExpenseDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建日期头
  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        date,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// 构建消费项
  Widget _buildExpenseItem(
    String title,
    String amount,
    String payer,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(title),
        subtitle: Text(payer, style: const TextStyle(fontSize: 12)),
        trailing: Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }

  /// 显示添加消费对话框
  void _showAddExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '记一笔',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: '金额',
                prefixText: '¥',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: '描述',
                hintText: '消费说明',
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: '付款人',
                hintText: '谁付的钱',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 保存消费记录
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
