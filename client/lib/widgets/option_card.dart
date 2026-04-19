import 'package:flutter/material.dart';

/// 选项卡片组件
/// 用于投票决策中的 A/B/C 选项展示
class OptionCard extends StatelessWidget {
  /// 选项标签（A/B/C）
  final String label;

  /// 选项标题
  final String title;

  /// 选项描述
  final String? description;

  /// 选项图片 URL
  final String? imageUrl;

  /// 是否被选中
  final bool isSelected;

  /// 是否为领先选项
  final bool isLeading;

  /// 投票百分比
  final double? percentage;

  /// 投票数
  final int? voteCount;

  /// 点击回调
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.label,
    required this.title,
    this.description,
    this.imageUrl,
    this.isSelected = false,
    this.isLeading = false,
    this.percentage,
    this.voteCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 选项标签
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue
                      : isLeading
                          ? Colors.blue[100]
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 选项内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight:
                            isLeading ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
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
                  ],
                ),
              ),

              // 投票结果
              if (percentage != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${percentage!.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLeading ? Colors.blue : Colors.grey,
                      ),
                    ),
                    if (voteCount != null)
                      Text(
                        '${voteCount}票',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],

              // 选中标记
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }
}
