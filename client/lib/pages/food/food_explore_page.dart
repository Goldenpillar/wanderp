import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/food/food_bloc.dart';
import '../../widgets/loading_widget.dart';

/// 美食探索页面
/// 展示美食推荐、搜索和筛选
class FoodExplorePage extends StatelessWidget {
  const FoodExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FoodBloc()..add(const LoadFoodRecommendations()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('美食探索'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: 打开搜索
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // TODO: 打开筛选
              },
            ),
          ],
        ),
        body: BlocBuilder<FoodBloc, FoodState>(
          builder: (context, state) {
            if (state is FoodLoading) {
              return const LoadingWidget();
            }
            if (state is FoodError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<FoodBloc>()
                          .add(const LoadFoodRecommendations()),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }
            if (state is FoodLoaded) {
              if (state.restaurants.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('暂无美食推荐'),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<FoodBloc>()
                      .add(const LoadFoodRecommendations());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = state.restaurants[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          // TODO: 跳转到餐厅详情
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // 餐厅图片
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: restaurant.coverImage != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: Image.network(
                                          restaurant.coverImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.restaurant,
                                        color: Colors.grey),
                              ),
                              const SizedBox(width: 12),
                              // 餐厅信息
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      restaurant.cuisine,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.star,
                                            size: 14,
                                            color: Colors.amber[700]),
                                        Text(
                                          '${restaurant.rating}',
                                          style: const TextStyle(
                                              fontSize: 12),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          restaurant.averageCostYuan,
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (restaurant.distance != null) ...[
                                          const Spacer(),
                                          Text(
                                            restaurant.distanceText,
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
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
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
