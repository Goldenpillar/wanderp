/// 用户模型
/// 描述应用用户的基本信息
class User {
  /// 用户唯一标识
  final String id;

  /// 用户名
  final String username;

  /// 昵称
  final String nickname;

  /// 头像 URL
  final String? avatar;

  /// 邮箱
  final String? email;

  /// 手机号
  final String? phone;

  /// 性别
  final String? gender;

  /// 生日
  final DateTime? birthday;

  /// 个人简介
  final String? bio;

  /// 所在城市
  final String? city;

  /// 旅行偏好标签
  final List<String> travelPreferences;

  /// 已参加的行程数量
  final int tripCount;

  /// 是否已验证邮箱
  final bool isEmailVerified;

  /// 是否已验证手机
  final bool isPhoneVerified;

  /// 创建时间
  final DateTime createdAt;

  /// 最后登录时间
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.username,
    required this.nickname,
    this.avatar,
    this.email,
    this.phone,
    this.gender,
    this.birthday,
    this.bio,
    this.city,
    this.travelPreferences = const [],
    this.tripCount = 0,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// 从 JSON 创建
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'] as String)
          : null,
      bio: json['bio'] as String?,
      city: json['city'] as String?,
      travelPreferences:
          (json['travel_preferences'] as List<dynamic>?)?.cast<String>() ?? [],
      tripCount: json['trip_count'] as int? ?? 0,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar,
      'email': email,
      'phone': phone,
      'gender': gender,
      'birthday': birthday?.toIso8601String(),
      'bio': bio,
      'city': city,
      'travel_preferences': travelPreferences,
      'trip_count': tripCount,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  /// 复制并修改
  User copyWith({
    String? id,
    String? username,
    String? nickname,
    String? avatar,
    String? email,
    String? phone,
    String? gender,
    DateTime? birthday,
    String? bio,
    String? city,
    List<String>? travelPreferences,
    int? tripCount,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      travelPreferences: travelPreferences ?? this.travelPreferences,
      tripCount: tripCount ?? this.tripCount,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
