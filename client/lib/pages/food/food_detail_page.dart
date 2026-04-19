import 'package:flutter/material.dart';

/// 餐厅详情页面
/// 展示餐厅的详细信息、评论和推荐菜品
class FoodDetailPage extends StatelessWidget {
  /// 餐厅 ID
  final String restaurantId;

  const FoodDetailPage({super.key, required this.restaurantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 可折叠的 AppBar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('餐厅名称'),
              background: Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.restaurant, size: 64, color: Colors.grey),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: 收藏/取消收藏
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: 分享
                },
              ),
            ],
          ),

          // 基本信息
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 评分和价格
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[700]),
                          const Text('4.5'),
                          const SizedBox(width: 4),
                          const Text('128条评价',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        '人均 ¥85',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 地址和营业时间
                  const ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('餐厅地址（待加载）'),
                    dense: true,
                  ),
                  const ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text('营业时间：10:00 - 22:00'),
                    dense: true,
                  ),
                  const ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('联系电话：待加载'),
                    dense: true,
                  ),
                  const Divider(),

                  // 推荐菜品
                  const Text(
                    '推荐菜品',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildDishChip('招牌菜 1'),
                        _buildDishChip('招牌菜 2'),
                        _buildDishChip('招牌菜 3'),
                        _buildDishChip('招牌菜 4'),
                      ],
                    ),
                  ),
                  const Divider(),

                  // 用户评论
                  const Text(
                    '用户评价',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildReviewItem(),
                  _buildReviewItem(),
                ],
              ),
            ),
          ),
        ],
      ),
      // 底部操作栏
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: 添加到行程
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('加入行程'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: 导航到餐厅
                  },
                  icon: const Icon(Icons.navigation),
                  label: const Text('导航前往'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建菜品标签
  Widget _buildDishChip(String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(name),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// 构建评论项
  Widget _buildReviewItem() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 16),
                const SizedBox(width: 8),
                const Text('用户名',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      size: 14,
                      color: index < 4
                          ? Colors.amber[700]
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('评论内容待加载，这里将展示用户对餐厅的真实评价...'),
          ],
        ),
      ),
    );
  }
}
