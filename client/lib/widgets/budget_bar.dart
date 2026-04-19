import 'package:flutter/material.dart';

/// 预算进度条组件
/// 用于展示行程预算的使用情况
class BudgetBar extends StatelessWidget {
  /// 已使用金额（分）
  final int usedBudget;

  /// 总预算（分）
  final int totalBudget;

  /// 预算标签
  final String? label;

  /// 是否显示详细数字
  final bool showDetails;

  /// 进度条高度
  final double height;

  /// 进度条圆角
  final double borderRadius;

  /// 颜色阈值（超过此比例变为警告色）
  final double warningThreshold;

  /// 颜色阈值（超过此比例变为危险色）
  final double dangerThreshold;

  const BudgetBar({
    super.key,
    required this.usedBudget,
    required this.totalBudget,
    this.label,
    this.showDetails = true,
    this.height = 8,
    this.borderRadius = 4,
    this.warningThreshold = 0.7,
    this.dangerThreshold = 0.9,
  });

  /// 使用百分比
  double get _percentage =>
      totalBudget > 0 ? (usedBudget / totalBudget).clamp(0.0, 1.0) : 0;

  /// 进度条颜色
  Color get _progressColor {
    if (_percentage >= dangerThreshold) return Colors.red;
    if (_percentage >= warningThreshold) return Colors.orange;
    return Colors.blue;
  }

  /// 格式化金额（元）
  String _formatMoney(int amountInCents) {
    return '¥${(amountInCents / 100).toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签行
        if (label != null || showDetails)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                if (showDetails) ...[
                  Text(
                    _formatMoney(usedBudget),
                    style: TextStyle(
                      color: _progressColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    ' / ${_formatMoney(totalBudget)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),

        // 进度条
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // 背景条
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                // 进度条
                FractionallySizedBox(
                  widthFactor: _percentage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: _progressColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 剩余预算
        if (showDetails && totalBudget > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '剩余 ${_formatMoney(totalBudget - usedBudget)}（${(_percentage * 100).toStringAsFixed(0)}%已用）',
              style: TextStyle(
                color: _percentage >= dangerThreshold
                    ? Colors.red
                    : Colors.grey,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}
