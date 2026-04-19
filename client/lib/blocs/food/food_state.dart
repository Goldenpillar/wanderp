import 'package:equatable/equatable.dart';

import '../../models/restaurant.dart';

/// 美食 BLoC 状态基类
abstract class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class FoodInitial extends FoodState {
  const FoodInitial();
}

/// 加载中
class FoodLoading extends FoodState {
  const FoodLoading();
}

/// 美食推荐列表加载成功
class FoodLoaded extends FoodState {
  final List<Restaurant> restaurants;
  final String? currentFilter;
  final String? currentSort;

  const FoodLoaded({
    required this.restaurants,
    this.currentFilter,
    this.currentSort,
  });

  @override
  List<Object?> get props => [restaurants, currentFilter, currentSort];
}

/// 餐厅详情加载成功
class RestaurantDetailLoaded extends FoodState {
  final Restaurant restaurant;

  const RestaurantDetailLoaded(this.restaurant);

  @override
  List<Object?> get props => [restaurant];
}

/// 收藏列表加载成功
class FavoritesLoaded extends FoodState {
  final List<Restaurant> favorites;

  const FavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

/// 美食操作失败
class FoodError extends FoodState {
  final String message;

  const FoodError(this.message);

  @override
  List<Object?> get props => [message];
}
