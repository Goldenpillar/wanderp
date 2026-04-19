import 'package:flutter/material.dart';

/// 餐厅推荐卡片组件
/// 用于展示美食推荐中的餐厅信息
class FoodCard extends StatelessWidget {
  /// 餐厅名称
  final String name;

  /// 菜系
  final String? cuisine;

  /// 评分
  final double rating;

  /// 人均消费
  final String averageCost;

  /// 封面图片 URL
  final String? imageUrl;

  /// 距离文本
  final String? distance;

  /// 推荐菜品
  final List<String>? recommendedDishes;

  /// 标签
  final List<String>? tags;

  /// 点击回调
  final VoidCallback? onTap;

  const FoodCard({
    super.key,
    required this.name,
    this.cuisine,
    this.rating = 0,
    required this.averageCost,
    this.imageUrl,
    this.distance,
    this.recommendedDishes,
    this.tags,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片
            if (imageUrl != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.restaurant, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
              ),

            // 信息区域
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称和距离
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (distance != null)
                        Text(
                          distance!,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // 菜系
                  if (cuisine != null)
                    Text(
                      cuisine!,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  const SizedBox(height: 8),

                  // 评分和价格
                  Row(
                    children: [
                      // 评分
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: Colors.amber[700]),
                          const SizedBox(width: 2),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // 人均
                      Text(
                        '人均 $averageCost',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  // 标签
                  if (tags != null && tags!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags!.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 10,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // 推荐菜品
                  if (recommendedDishes != null &&
                      recommendedDishes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '推荐：${recommendedDishes!.join('、')}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
