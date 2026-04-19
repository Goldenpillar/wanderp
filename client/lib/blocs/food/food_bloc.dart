import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/logger.dart';
import '../../models/restaurant.dart';
import '../../services/food_service.dart';
import 'food_event.dart';
import 'food_state.dart';

/// 美食 BLoC
/// 管理美食推荐和餐厅相关的状态
class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final FoodService _foodService;

  FoodBloc({FoodService? foodService})
      : _foodService = foodService ?? FoodService(),
        super(const FoodInitial()) {
    on<LoadFoodRecommendations>(_onLoadFoodRecommendations);
    on<LoadRestaurantDetail>(_onLoadRestaurantDetail);
    on<SearchRestaurants>(_onSearchRestaurants);
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadFavorites>(_onLoadFavorites);
    on<FilterByCuisine>(_onFilterByCuisine);
    on<SortByDistance>(_onSortByDistance);
    on<SortByRating>(_onSortByRating);
  }

  /// 处理加载美食推荐
  Future<void> _onLoadFoodRecommendations(
    LoadFoodRecommendations event,
    Emitter<FoodState> emit,
  ) async {
    emit(const FoodLoading());
    try {
      final restaurants = await _foodService.getRecommendations(
        tripId: event.tripId,
        latitude: event.latitude,
        longitude: event.longitude,
        cuisine: event.cuisine,
      );
      emit(FoodLoaded(restaurants: restaurants));
    } catch (e) {
      Logger.e('加载美食推荐失败: $e');
      emit(FoodError('加载美食推荐失败: $e'));
    }
  }

  /// 处理加载餐厅详情
  Future<void> _onLoadRestaurantDetail(
    LoadRestaurantDetail event,
    Emitter<FoodState> emit,
  ) async {
    emit(const FoodLoading());
    try {
      final restaurant = await _foodService.getRestaurantDetail(
        event.restaurantId,
      );
      emit(RestaurantDetailLoaded(restaurant));
    } catch (e) {
      Logger.e('加载餐厅详情失败: $e');
      emit(FoodError('加载餐厅详情失败: $e'));
    }
  }

  /// 处理搜索餐厅
  Future<void> _onSearchRestaurants(
    SearchRestaurants event,
    Emitter<FoodState> emit,
  ) async {
    emit(const FoodLoading());
    try {
      final restaurants = await _foodService.searchRestaurants(
        query: event.query,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(FoodLoaded(restaurants: restaurants));
    } catch (e) {
      Logger.e('搜索餐厅失败: $e');
      emit(FoodError('搜索餐厅失败: $e'));
    }
  }

  /// 处理收藏/取消收藏
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FoodState> emit,
  ) async {
    try {
      await _foodService.toggleFavorite(event.restaurantId);
      // 重新加载当前列表
      if (state is FoodLoaded) {
        final currentState = state as FoodLoaded;
        final updatedRestaurants = currentState.restaurants.map((r) {
          if (r.id == event.restaurantId) {
            return r.copyWith(isFavorite: !r.isFavorite);
          }
          return r;
        }).toList();
        emit(FoodLoaded(
          restaurants: updatedRestaurants,
          currentFilter: currentState.currentFilter,
          currentSort: currentState.currentSort,
        ));
      }
    } catch (e) {
      Logger.e('收藏操作失败: $e');
    }
  }

  /// 处理加载收藏列表
  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FoodState> emit,
  ) async {
    emit(const FoodLoading());
    try {
      final favorites = await _foodService.getFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      Logger.e('加载收藏列表失败: $e');
      emit(FoodError('加载收藏列表失败: $e'));
    }
  }

  /// 处理按菜系筛选
  void _onFilterByCuisine(
    FilterByCuisine event,
    Emitter<FoodState> emit,
  ) {
    if (state is FoodLoaded) {
      final currentState = state as FoodLoaded;
      final filtered = event.cuisine.isEmpty
          ? currentState.restaurants
          : currentState.restaurants
              .where((r) => r.cuisine == event.cuisine)
              .toList();
      emit(FoodLoaded(
        restaurants: filtered,
        currentFilter: event.cuisine,
        currentSort: currentState.currentSort,
      ));
    }
  }

  /// 处理按距离排序
  void _onSortByDistance(
    SortByDistance event,
    Emitter<FoodState> emit,
  ) {
    if (state is FoodLoaded) {
      final currentState = state as FoodLoaded;
      final sorted = List<Restaurant>.from(currentState.restaurants)
        ..sort((a, b) {
          final distA = a.distance ?? double.infinity;
          final distB = b.distance ?? double.infinity;
          return distA.compareTo(distB);
        });
      emit(FoodLoaded(
        restaurants: sorted,
        currentFilter: currentState.currentFilter,
        currentSort: 'distance',
      ));
    }
  }

  /// 处理按评分排序
  void _onSortByRating(
    SortByRating event,
    Emitter<FoodState> emit,
  ) {
    if (state is FoodLoaded) {
      final currentState = state as FoodLoaded;
      final sorted = List<Restaurant>.from(currentState.restaurants)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      emit(FoodLoaded(
        restaurants: sorted,
        currentFilter: currentState.currentFilter,
        currentSort: 'rating',
      ));
    }
  }
}
