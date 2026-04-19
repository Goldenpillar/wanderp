/// 行程状态枚举
enum TripStatus {
  /// 草稿
  draft,

  /// 进行中
  active,

  /// 已完成
  completed,

  /// 已取消
  cancelled,
}

/// 行程模型
/// 描述一次旅行的完整信息
class Trip {
  /// 行程唯一标识
  final String id;

  /// 行程名称
  final String name;

  /// 行程描述
  final String? description;

  /// 封面图片 URL
  final String? coverImage;

  /// 目的地
  final String destination;

  /// 出发日期
  final DateTime startDate;

  /// 返回日期
  final DateTime endDate;

  /// 行程状态
  final TripStatus status;

  /// 创建者用户 ID
  final String creatorId;

  /// 参与成员 ID 列表
  final List<String> memberIds;

  /// 总预算（分）
  final int? budget;

  /// 已用预算（分）
  final int? usedBudget;

  /// 天数
  int get days {
    return endDate.difference(startDate).inDays + 1;
  }

  /// 是否正在进行中
  bool get isActive => status == TripStatus.active;

  /// 是否已完成
  bool get isCompleted => status == TripStatus.completed;

  /// 剩余预算（分）
  int? get remainingBudget =>
      (budget != null && usedBudget != null) ? budget! - usedBudget! : null;

  /// 预算使用百分比
  double? get budgetUsagePercent {
    if (budget == null || budget == 0) return null;
    return (usedBudget ?? 0) / budget!;
  }

  Trip({
    required this.id,
    required this.name,
    this.description,
    this.coverImage,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.status = TripStatus.draft,
    required this.creatorId,
    this.memberIds = const [],
    this.budget,
    this.usedBudget,
  });

  /// 从 JSON 创建
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: TripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripStatus.draft,
      ),
      creatorId: json['creator_id'] as String,
      memberIds: (json['member_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      budget: json['budget'] as int?,
      usedBudget: json['used_budget'] as int?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_image': coverImage,
      'destination': destination,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status.name,
      'creator_id': creatorId,
      'member_ids': memberIds,
      'budget': budget,
      'used_budget': usedBudget,
    };
  }

  /// 复制并修改
  Trip copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImage,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    TripStatus? status,
    String? creatorId,
    List<String>? memberIds,
    int? budget,
    int? usedBudget,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      budget: budget ?? this.budget,
      usedBudget: usedBudget ?? this.usedBudget,
    );
  }

  @override
  String toString() => 'Trip(id: $id, name: $name, destination: $destination)';
}
