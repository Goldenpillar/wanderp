import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/preference.dart';

/// 偏好状态
class PreferenceState {
  /// 当前偏好设置
  final Preference? preference;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? errorMessage;

  const PreferenceState({
    this.preference,
    this.isLoading = false,
    this.errorMessage,
  });

  PreferenceState copyWith({
    Preference? preference,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PreferenceState(
      preference: preference ?? this.preference,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// 偏好状态管理 Notifier
class PreferenceNotifier extends StateNotifier<PreferenceState> {
  PreferenceNotifier() : super(const PreferenceState());

  /// 加载用户偏好
  Future<void> loadPreference(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: 从 API 加载用户偏好
      // final preference = await _api.get('/preferences/$userId');
      // state = PreferenceState(
      //   preference: Preference.fromJson(preference.data['data']),
      // );
      state = const PreferenceState();
    } catch (e) {
      state = PreferenceState(errorMessage: '加载偏好失败: $e');
    }
  }

  /// 更新偏好
  Future<void> updatePreference(Preference preference) async {
    state = state.copyWith(isLoading: true);
    try {
      // TODO: 调用 API 更新偏好
      // await _api.put('/preferences/${preference.id}', data: preference.toJson());
      state = PreferenceState(preference: preference);
    } catch (e) {
      state = PreferenceState(
        preference: state.preference,
        errorMessage: '更新偏好失败: $e',
      );
    }
  }

  /// 更新旅行风格
  void updateTravelStyles(List<String> styles) {
    if (state.preference != null) {
      state = PreferenceState(
        preference: state.preference!.copyWith(travelStyles: styles),
      );
    }
  }

  /// 更新饮食偏好
  void updateTastePrefs(List<String> foods) {
    if (state.preference != null) {
      state = PreferenceState(
        preference: state.preference!.copyWith(tastePrefs: foods),
      );
    }
  }

  /// 更新预算等级
  void updateBudgetLevel(int level) {
    if (state.preference != null) {
      state = PreferenceState(
        preference: state.preference!.copyWith(budgetLevel: level),
      );
    }
  }

  /// 清除偏好
  void clearPreference() {
    state = const PreferenceState();
  }
}

/// 偏好 Provider
final preferenceProvider =
    StateNotifierProvider<PreferenceNotifier, PreferenceState>((ref) {
  return PreferenceNotifier();
});

/// 旅行风格选项 Provider
final travelStyleOptionsProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'id': 'adventure', 'label': '冒险探索', 'icon': 'mountain'},
    {'id': 'relax', 'label': '休闲度假', 'icon': 'beach'},
    {'id': 'culture', 'label': '文化历史', 'icon': 'museum'},
    {'id': 'food', 'label': '美食之旅', 'icon': 'restaurant'},
    {'id': 'nature', 'label': '自然风光', 'icon': 'nature'},
    {'id': 'city', 'label': '城市观光', 'icon': 'city'},
    {'id': 'shopping', 'label': '购物血拼', 'icon': 'shopping'},
    {'id': 'photo', 'label': '摄影采风', 'icon': 'camera'},
  ];
});

/// 菜系选项 Provider
final cuisineOptionsProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'id': 'chinese', 'label': '中餐'},
    {'id': 'western', 'label': '西餐'},
    {'id': 'japanese', 'label': '日料'},
    {'id': 'korean', 'label': '韩餐'},
    {'id': 'thai', 'label': '泰国菜'},
    {'id': 'italian', 'label': '意大利菜'},
    {'id': 'french', 'label': '法国菜'},
    {'id': 'indian', 'label': '印度菜'},
    {'id': 'seafood', 'label': '海鲜'},
    {'id': 'bbq', 'label': '烧烤'},
    {'id': 'hotpot', 'label': '火锅'},
    {'id': 'dessert', 'label': '甜品'},
  ];
});
