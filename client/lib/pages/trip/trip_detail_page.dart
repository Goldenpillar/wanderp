import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/trip/trip_bloc.dart';
import '../../widgets/loading_widget.dart';

/// 行程详情页面（骨架视图）
/// 展示行程的完整信息，包括日程安排、活动、消费等
class TripDetailPage extends StatelessWidget {
  /// 行程 ID
  final String tripId;

  const TripDetailPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripBloc()..add(LoadTripDetail(tripId)),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('行程详情'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: '概览'),
                Tab(text: '日程'),
                Tab(text: '美食'),
                Tab(text: '消费'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  // TODO: 分享行程
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  // TODO: 处理菜单操作
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('编辑行程'),
                  ),
                  const PopupMenuItem(
                    value: 'invite',
                    child: Text('邀请成员'),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Text('导出行程'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('删除行程'),
                  ),
                ],
              ),
            ],
          ),
          body: BlocBuilder<TripBloc, TripState>(
            builder: (context, state) {
              if (state is TripLoading) {
                return const LoadingWidget();
              }
              if (state is TripError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<TripBloc>()
                            .add(LoadTripDetail(tripId)),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                );
              }
              if (state is TripDetailLoaded) {
                return TabBarView(
                  children: [
                    _buildOverviewTab(context, state),
                    _buildScheduleTab(context, state),
                    _buildFoodTab(context),
                    _buildExpenseTab(context),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  /// 构建概览 Tab
  Widget _buildOverviewTab(BuildContext context, TripDetailLoaded state) {
    final trip = state.trip;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行程封面
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: trip.coverImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      trip.coverImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Icon(Icons.image, size: 48, color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 16),

          // 行程基本信息
          Text(
            trip.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (trip.description != null) ...[
            const SizedBox(height: 8),
            Text(
              trip.description!,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
          const SizedBox(height: 16),

          // 信息卡片
          Row(
            children: [
              _buildInfoChip(
                Icons.location_on,
                trip.destination,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.calendar_today,
                '${trip.days}天',
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.group,
                '${trip.memberIds.length + 1}人',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 预算进度
          if (trip.budget != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '预算使用',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: trip.budgetUsagePercent ?? 0,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '已用 ¥${((trip.usedBudget ?? 0) / 100).toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          '总预算 ¥${(trip.budget! / 100).toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }

  /// 构建日程 Tab
  Widget _buildScheduleTab(BuildContext context, TripDetailLoaded state) {
    if (state.activities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无日程安排'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.activities.length,
      itemBuilder: (context, index) {
        final activity = state.activities[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.place, color: Colors.blue),
            title: Text(activity.name),
            subtitle: Text(
              '${activity.startTime.hour}:${activity.startTime.minute.toString().padLeft(2, '0')} - ${activity.type.name}',
            ),
            trailing: activity.estimatedCost != null
                ? Text(
                    '¥${(activity.estimatedCost! / 100).toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.orange),
                  )
                : null,
          ),
        );
      },
    );
  }

  /// 构建美食 Tab
  Widget _buildFoodTab(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('美食推荐 - 待实现'),
        ],
      ),
    );
  }

  /// 构建消费 Tab
  Widget _buildExpenseTab(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('消费记录 - 待实现'),
        ],
      ),
    );
  }
}
