/// 活动类型枚举
enum ActivityType {
  /// 景点
  attraction,

  /// 活动
  event,

  /// 住宿
  accommodation,

  /// 交通
  transport,

  /// 购物
  shopping,

  /// 其他
  other,
}

/// 活动选项模型
/// 描述活动的可选方案（如不同票种、套餐等）
class ActivityOption {
  /// 选项标签（如"成人票"、"VIP套餐"）
  final String label;

  /// 选项描述
  final String? description;

  /// 选项费用（分）
  final int? cost;

  /// 选项持续时间（分钟）
  final int? duration;

  const ActivityOption({
    required this.label,
    this.description,
    this.cost,
    this.duration,
  });

  factory ActivityOption.fromJson(Map<String, dynamic> json) {
    return ActivityOption(
      label: json['label'] as String,
      description: json['description'] as String?,
      cost: json['cost'] as int?,
      duration: json['duration'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'description': description,
      'cost': cost,
      'duration': duration,
    };
  }

  ActivityOption copyWith({
    String? label,
    String? description,
    int? cost,
    int? duration,
  }) {
    return ActivityOption(
      label: label ?? this.label,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      duration: duration ?? this.duration,
    );
  }
}

/// 活动/景点模型
/// 描述行程中的单个活动或景点
class Activity {
  /// 活动唯一标识
  final String id;

  /// 所属行程 ID
  final String tripId;

  /// 活动名称
  final String name;

  /// 活动描述
  final String? description;

  /// 活动类型
  final ActivityType type;

  /// 活动封面图片 URL
  final String? coverImage;

  /// 图片列表
  final List<String> images;

  /// 开始时间
  final DateTime startTime;

  /// 结束时间
  final DateTime? endTime;

  /// 预计花费（分）
  final int? estimatedCost;

  /// 实际花费（分）
  final int? actualCost;

  /// 纬度
  final double? latitude;

  /// 经度
  final double? longitude;

  /// 地址
  final String? address;

  /// 评分（1-5）
  final double? rating;

  /// 备注
  final String? notes;

  /// 排序序号
  final int sortOrder;

  /// 所属日期（行程中的第几天）
  final int dayIndex;

  /// 标签列表
  final List<String> tags;

  /// 活动选项列表（如不同票种、套餐等）
  final List<ActivityOption> options;

  /// 持续时间
  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }

  Activity({
    required this.id,
    required this.tripId,
    required this.name,
    this.description,
    this.type = ActivityType.attraction,
    this.coverImage,
    this.images = const [],
    required this.startTime,
    this.endTime,
    this.estimatedCost,
    this.actualCost,
    this.latitude,
    this.longitude,
    this.address,
    this.rating,
    this.notes,
    this.sortOrder = 0,
    this.dayIndex = 1,
    this.tags = const [],
    this.options = const [],
  });

  /// 从 JSON 创建
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.attraction,
      ),
      coverImage: json['cover_image'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      estimatedCost: json['estimated_cost'] as int?,
      actualCost: json['actual_cost'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      dayIndex: json['day_index'] as int? ?? 1,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => ActivityOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'name': name,
      'description': description,
      'type': type.name,
      'cover_image': coverImage,
      'images': images,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'estimated_cost': estimatedCost,
      'actual_cost': actualCost,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'rating': rating,
      'notes': notes,
      'sort_order': sortOrder,
      'day_index': dayIndex,
      'tags': tags,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }

  /// 复制并修改
  Activity copyWith({
    String? id,
    String? tripId,
    String? name,
    String? description,
    ActivityType? type,
    String? coverImage,
    List<String>? images,
    DateTime? startTime,
    DateTime? endTime,
    int? estimatedCost,
    int? actualCost,
    double? latitude,
    double? longitude,
    String? address,
    double? rating,
    String? notes,
    int? sortOrder,
    int? dayIndex,
    List<String>? tags,
    List<ActivityOption>? options,
  }) {
    return Activity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      coverImage: coverImage ?? this.coverImage,
      images: images ?? this.images,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      dayIndex: dayIndex ?? this.dayIndex,
      tags: tags ?? this.tags,
      options: options ?? this.options,
    );
  }
}
