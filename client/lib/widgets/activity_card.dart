import 'package:flutter/material.dart';

/// 活动/景点卡片组件
/// 用于展示行程中的活动或景点信息
class ActivityCard extends StatelessWidget {
  /// 活动名称
  final String title;

  /// 活动描述
  final String? description;

  /// 活动类型图标
  final IconData icon;

  /// 开始时间
  final String? startTime;

  /// 评分
  final double? rating;

  /// 预估费用
  final String? cost;

  /// 封面图片 URL
  final String? imageUrl;

  /// 点击回调
  final VoidCallback? onTap;

  /// 收藏回调
  final VoidCallback? onFavorite;

  /// 是否已收藏
  final bool isFavorite;

  const ActivityCard({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.place,
    this.startTime,
    this.rating,
    this.cost,
    this.imageUrl,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧图标/图片
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            icon,
                            color: Colors.blue,
                            size: 32,
                          ),
                        ),
                      )
                    : Icon(icon, color: Colors.blue, size: 32),
              ),
              const SizedBox(width: 12),

              // 右侧信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onFavorite != null)
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: isFavorite ? Colors.red : Colors.grey,
                            ),
                            onPressed: onFavorite,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),

                    // 描述
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const Spacer(),

                    // 底部信息
                    Row(
                      children: [
                        if (startTime != null) ...[
                          Icon(Icons.access_time,
                              size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            startTime!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (rating != null) ...[
                          Icon(Icons.star,
                              size: 12, color: Colors.amber[700]),
                          const SizedBox(width: 2),
                          Text(
                            rating.toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (cost != null)
                          Text(
                            cost!,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
