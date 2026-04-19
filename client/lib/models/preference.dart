/// 偏好类型枚举
enum PreferenceCategory {
  /// 旅行风格
  travelStyle,

  /// 饮食偏好
  food,

  /// 住宿偏好
  accommodation,

  /// 交通偏好
  transport,

  /// 预算偏好
  budget,

  /// 活动偏好
  activity,
}

/// 偏好选项模型
/// 描述一个可选的偏好项
class PreferenceOption {
  /// 选项标识
  final String id;

  /// 选项名称
  final String label;

  /// 选项图标
  final String? icon;

  /// 选项描述
  final String? description;

  /// 选项图片 URL
  final String? imageUrl;

  const PreferenceOption({
    required this.id,
    required this.label,
    this.icon,
    this.description,
    this.imageUrl,
  });
}

/// 用户偏好模型
/// 描述用户的旅行偏好设置
class Preference {
  /// 偏好唯一标识
  final String id;

  /// 用户 ID
  final String userId;

  /// 行程 ID（如果与行程关联）
  final String? tripId;

  /// 旅行风格偏好（如：冒险、休闲、文化、美食等）
  final List<String> travelStyles;

  /// 饮食偏好（如：辣、清淡、素食等）
  final List<String> tastePrefs;

  /// 住宿偏好（如：酒店、民宿、青旅等）
  final List<String> accommodationPreferences;

  /// 交通偏好（如：自驾、公共交通、步行等）
  final List<String> transportPreferences;

  /// 预算等级（1-5，1为最经济）
  final int budgetLevel;

  /// 活动偏好（如：徒步、潜水、购物等）
  final List<String> activityPreferences;

  /// 特殊需求（如：无障碍、带小孩、带宠物等）
  final List<String> specialNeeds;

  /// 每日预算上限（分）
  final int? dailyBudget;

  /// 更新时间
  final DateTime updatedAt;

  Preference({
    required this.id,
    required this.userId,
    this.tripId,
    this.travelStyles = const [],
    this.tastePrefs = const [],
    this.accommodationPreferences = const [],
    this.transportPreferences = const [],
    this.budgetLevel = 3,
    this.activityPreferences = const [],
    this.specialNeeds = const [],
    this.dailyBudget,
    required this.updatedAt,
  });

  /// 从 JSON 创建
  factory Preference.fromJson(Map<String, dynamic> json) {
    return Preference(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tripId: json['trip_id'] as String?,
      travelStyles:
          (json['travel_styles'] as List<dynamic>?)?.cast<String>() ?? [],
      tastePrefs:
          (json['taste_prefs'] as List<dynamic>?)?.cast<String>() ?? [],
      accommodationPreferences: (json['accommodation_preferences'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      transportPreferences: (json['transport_preferences'] as List<dynamic>?)
              ?.cast<String>() ??
          [],
      budgetLevel: json['budget_level'] as int? ?? 3,
      activityPreferences:
          (json['activity_preferences'] as List<dynamic>?)?.cast<String>() ?? [],
      specialNeeds:
          (json['special_needs'] as List<dynamic>?)?.cast<String>() ?? [],
      dailyBudget: json['daily_budget'] as int?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trip_id': tripId,
      'travel_styles': travelStyles,
      'taste_prefs': tastePrefs,
      'accommodation_preferences': accommodationPreferences,
      'transport_preferences': transportPreferences,
      'budget_level': budgetLevel,
      'activity_preferences': activityPreferences,
      'special_needs': specialNeeds,
      'daily_budget': dailyBudget,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  Preference copyWith({
    String? id,
    String? userId,
    String? tripId,
    List<String>? travelStyles,
    List<String>? tastePrefs,
    List<String>? accommodationPreferences,
    List<String>? transportPreferences,
    int? budgetLevel,
    List<String>? activityPreferences,
    List<String>? specialNeeds,
    int? dailyBudget,
    DateTime? updatedAt,
  }) {
    return Preference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      travelStyles: travelStyles ?? this.travelStyles,
      tastePrefs: tastePrefs ?? this.tastePrefs,
      accommodationPreferences:
          accommodationPreferences ?? this.accommodationPreferences,
      transportPreferences: transportPreferences ?? this.transportPreferences,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      activityPreferences: activityPreferences ?? this.activityPreferences,
      specialNeeds: specialNeeds ?? this.specialNeeds,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
