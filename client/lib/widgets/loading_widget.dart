import 'package:flutter/material.dart';

/// 加载组件
/// 提供多种加载状态的展示
class LoadingWidget extends StatelessWidget {
  /// 加载提示文字
  final String? message;

  /// 加载类型
  final LoadingType type;

  const LoadingWidget({
    super.key,
    this.message,
    this.type = LoadingType.spinner,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case LoadingType.spinner:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ],
          ),
        );
      case LoadingType.shimmer:
        return _buildShimmerLoading();
      case LoadingType.skeleton:
        return _buildSkeletonLoading();
    }
  }

  /// 构建骨架屏加载效果
  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 模拟标题
          _buildSkeletonBox(width: double.infinity, height: 20),
          const SizedBox(height: 16),
          // 模拟卡片列表
          for (int i = 0; i < 5; i++) ...[
            _buildSkeletonCard(),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  /// 构建骨架卡片
  Widget _buildSkeletonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildSkeletonBox(width: 60, height: 60, isCircle: false),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  _buildSkeletonBox(width: 120, height: 12),
                  const SizedBox(height: 8),
                  _buildSkeletonBox(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建骨架占位块
  Widget _buildSkeletonBox({
    required double width,
    required double height,
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: isCircle ? null : BorderRadius.circular(4),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  /// 构建微光加载效果
  Widget _buildShimmerLoading() {
    // TODO: 使用 shimmer 包实现更精美的加载效果
    return _buildSkeletonLoading();
  }
}

/// 加载类型枚举
enum LoadingType {
  /// 圆形进度指示器
  spinner,

  /// 微光效果
  shimmer,

  /// 骨架屏
  skeleton,
}
