import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../config/routes.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/collaboration/invite_page.dart';
import '../pages/collaboration/preference_page.dart';
import '../pages/collaboration/vote_page.dart';
import '../pages/expense/expense_page.dart';
import '../pages/expense/settlement_page.dart';
import '../pages/food/food_detail_page.dart';
import '../pages/food/food_explore_page.dart';
import '../pages/home/home_page.dart';
import '../pages/map/map_page.dart';
import '../pages/map/trajectory_page.dart';
import '../pages/settings/settings_page.dart';
import '../pages/trip/trip_create_page.dart';
import '../pages/trip/trip_detail_page.dart';
import '../pages/trip/trip_list_page.dart';

/// GoRouter 路由配置
class AppRouter {
  AppRouter._();

  /// 全局路由配置
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // TODO: 根据认证状态进行路由守卫
      // final authState = context.read<AuthBloc>().state;
      // final isAuthRoute = state.matchedLocation == AppRoutes.login ||
      //     state.matchedLocation == AppRoutes.register;
      // if (!authState.isAuthenticated && !isAuthRoute) {
      //   return AppRoutes.login;
      // }
      return null;
    },
    routes: [
      // ==================== 首页 ====================
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // ==================== 行程 ====================
      GoRoute(
        path: AppRoutes.tripList,
        name: 'tripList',
        builder: (context, state) => const TripListPage(),
      ),
      GoRoute(
        path: AppRoutes.tripCreate,
        name: 'tripCreate',
        builder: (context, state) => const TripCreatePage(),
      ),
      GoRoute(
        path: AppRoutes.tripDetail,
        name: 'tripDetail',
        builder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return TripDetailPage(tripId: tripId);
        },
      ),

      // ==================== 地图 ====================
      GoRoute(
        path: AppRoutes.map,
        name: 'map',
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: AppRoutes.trajectory,
        name: 'trajectory',
        builder: (context, state) => const TrajectoryPage(),
      ),

      // ==================== 美食 ====================
      GoRoute(
        path: AppRoutes.foodExplore,
        name: 'foodExplore',
        builder: (context, state) => const FoodExplorePage(),
      ),
      GoRoute(
        path: AppRoutes.foodDetail,
        name: 'foodDetail',
        builder: (context, state) {
          final restaurantId = state.pathParameters['id']!;
          return FoodDetailPage(restaurantId: restaurantId);
        },
      ),

      // ==================== 协作 ====================
      GoRoute(
        path: AppRoutes.invite,
        name: 'invite',
        builder: (context, state) => const InvitePage(),
      ),
      GoRoute(
        path: AppRoutes.preference,
        name: 'preference',
        builder: (context, state) => const PreferencePage(),
      ),
      GoRoute(
        path: AppRoutes.vote,
        name: 'vote',
        builder: (context, state) => const VotePage(),
      ),

      // ==================== 消费 ====================
      GoRoute(
        path: AppRoutes.expense,
        name: 'expense',
        builder: (context, state) => const ExpensePage(),
      ),
      GoRoute(
        path: AppRoutes.settlement,
        name: 'settlement',
        builder: (context, state) => const SettlementPage(),
      ),

      // ==================== 认证 ====================
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ==================== 设置 ====================
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面不存在')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('抱歉，您访问的页面不存在'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}
