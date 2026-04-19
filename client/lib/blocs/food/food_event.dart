import 'package:equatable/equatable.dart';

/// 美食 BLoC 事件基类
abstract class FoodEvent extends Equatable {
  const FoodEvent();

  @override
  List<Object?> get props => [];
}

/// 加载美食推荐列表
class LoadFoodRecommendations extends FoodEvent {
  final String? tripId;
  final double? latitude;
  final double? longitude;
  final String? cuisine;

  const LoadFoodRecommendations({
    this.tripId,
    this.latitude,
    this.longitude,
    this.cuisine,
  });

  @override
  List<Object?> get props => [tripId, latitude, longitude, cuisine];
}

/// 加载餐厅详情
class LoadRestaurantDetail extends FoodEvent {
  final String restaurantId;

  const LoadRestaurantDetail(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

/// 搜索餐厅
class SearchRestaurants extends FoodEvent {
  final String query;
  final double? latitude;
  final double? longitude;

  const SearchRestaurants({
    required this.query,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [query, latitude, longitude];
}

/// 收藏/取消收藏餐厅
class ToggleFavorite extends FoodEvent {
  final String restaurantId;

  const ToggleFavorite(this.restaurantId);

  @override
  List<Object?> get props => [restaurantId];
}

/// 加载收藏列表
class LoadFavorites extends FoodEvent {
  const LoadFavorites();
}

/// 按菜系筛选
class FilterByCuisine extends FoodEvent {
  final String cuisine;

  const FilterByCuisine(this.cuisine);

  @override
  List<Object?> get props => [cuisine];
}

/// 按距离排序
class SortByDistance extends FoodEvent {
  final double latitude;
  final double longitude;

  const SortByDistance({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

/// 按评分排序
class SortByRating extends FoodEvent {
  const SortByRating();
}
