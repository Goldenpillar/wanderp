/// 餐厅模型
/// 描述美食推荐和餐厅信息
class Restaurant {
  /// 餐厅唯一标识
  final String id;

  /// 餐厅名称
  final String name;

  /// 餐厅描述
  final String? description;

  /// 封面图片 URL
  final String? coverImage;

  /// 图片列表
  final List<String> images;

  /// 菜系类型（如：川菜、粤菜、日料等）
  final String cuisine;

  /// 人均消费（分）
  final int averageCost;

  /// 评分（1-5）
  final double rating;

  /// 评论数量
  final int reviewCount;

  /// 纬度
  final double? latitude;

  /// 经度
  final double? longitude;

  /// 地址
  final String? address;

  /// 联系电话
  final String? phone;

  /// 营业时间
  final String? businessHours;

  /// 推荐菜品列表
  final List<String> recommendedDishes;

  /// 标签列表（如：必吃、网红、老字号等）
  final List<String> tags;

  /// 是否收藏
  final bool isFavorite;

  /// 距离当前位置（米）
  final double? distance;

  /// 所属行程 ID（如果是从行程中获取的）
  final String? tripId;

  /// 排序序号
  final int? sortOrder;

  /// 人均消费格式化（元）
  String get averageCostYuan => '¥${(averageCost / 100).toStringAsFixed(0)}';

  /// 距离格式化
  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1000) {
      return '${distance!.toStringAsFixed(0)}m';
    }
    return '${(distance! / 1000).toStringAsFixed(1)}km';
  }

  Restaurant({
    required this.id,
    required this.name,
    this.description,
    this.coverImage,
    this.images = const [],
    required this.cuisine,
    required this.averageCost,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.latitude,
    this.longitude,
    this.address,
    this.phone,
    this.businessHours,
    this.recommendedDishes = const [],
    this.tags = const [],
    this.isFavorite = false,
    this.distance,
    this.tripId,
    this.sortOrder,
  });

  /// 从 JSON 创建
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      cuisine: json['cuisine'] as String? ?? '',
      averageCost: json['average_cost'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      businessHours: json['business_hours'] as String?,
      recommendedDishes:
          (json['recommended_dishes'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isFavorite: json['is_favorite'] as bool? ?? false,
      distance: (json['distance'] as num?)?.toDouble(),
      tripId: json['trip_id'] as String?,
      sortOrder: json['sort_order'] as int?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_image': coverImage,
      'images': images,
      'cuisine': cuisine,
      'average_cost': averageCost,
      'rating': rating,
      'review_count': reviewCount,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone': phone,
      'business_hours': businessHours,
      'recommended_dishes': recommendedDishes,
      'tags': tags,
      'is_favorite': isFavorite,
      'distance': distance,
      'trip_id': tripId,
      'sort_order': sortOrder,
    };
  }

  /// 复制并修改
  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImage,
    List<String>? images,
    String? cuisine,
    int? averageCost,
    double? rating,
    int? reviewCount,
    double? latitude,
    double? longitude,
    String? address,
    String? phone,
    String? businessHours,
    List<String>? recommendedDishes,
    List<String>? tags,
    bool? isFavorite,
    double? distance,
    String? tripId,
    int? sortOrder,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      images: images ?? this.images,
      cuisine: cuisine ?? this.cuisine,
      averageCost: averageCost ?? this.averageCost,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      businessHours: businessHours ?? this.businessHours,
      recommendedDishes: recommendedDishes ?? this.recommendedDishes,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      distance: distance ?? this.distance,
      tripId: tripId ?? this.tripId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
