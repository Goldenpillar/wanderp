/// 消费类型枚举
enum ExpenseType {
  /// 餐饮
  food,

  /// 交通
  transport,

  /// 住宿
  accommodation,

  /// 门票
  ticket,

  /// 购物
  shopping,

  /// 娱乐
  entertainment,

  /// 其他
  other,
}

/// 消费模型
/// 描述行程中的消费记录
class Expense {
  /// 消费唯一标识
  final String id;

  /// 所属行程 ID
  final String tripId;

  /// 消费名称/描述
  final String title;

  /// 消费金额（分）
  final int amount;

  /// 货币类型
  final String currency;

  /// 消费类型
  final ExpenseType type;

  /// 付款人用户 ID
  final String payerId;

  /// 付款人昵称
  final String payerName;

  /// 参与分摊的成员 ID 列表
  final List<String> splitMemberIds;

  /// 消费日期
  final DateTime expenseDate;

  /// 备注
  final String? notes;

  /// 凭证图片列表
  final List<String> receiptImages;

  /// 关联的活动/餐厅 ID
  final String? referenceId;

  /// 创建时间
  final DateTime createdAt;

  /// 金额格式化（元）
  String get amountYuan {
    return '¥${(amount / 100).toStringAsFixed(2)}';
  }

  /// 每人分摊金额（分）
  int get splitAmount {
    if (splitMemberIds.isEmpty) return amount;
    return amount ~/ splitMemberIds.length;
  }

  /// 每人分摊金额格式化（元）
  String get splitAmountYuan {
    return '¥${(splitAmount / 100).toStringAsFixed(2)}';
  }

  Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    this.currency = 'CNY',
    this.type = ExpenseType.other,
    required this.payerId,
    required this.payerName,
    this.splitMemberIds = const [],
    required this.expenseDate,
    this.notes,
    this.receiptImages = const [],
    this.referenceId,
    required this.createdAt,
  });

  /// 从 JSON 创建
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      title: json['title'] as String,
      amount: json['amount'] as int,
      currency: json['currency'] as String? ?? 'CNY',
      type: ExpenseType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ExpenseType.other,
      ),
      payerId: json['payer_id'] as String,
      payerName: json['payer_name'] as String,
      splitMemberIds:
          (json['split_member_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      expenseDate: DateTime.parse(json['expense_date'] as String),
      notes: json['notes'] as String?,
      receiptImages:
          (json['receipt_images'] as List<dynamic>?)?.cast<String>() ?? [],
      referenceId: json['reference_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'title': title,
      'amount': amount,
      'currency': currency,
      'type': type.name,
      'payer_id': payerId,
      'payer_name': payerName,
      'split_member_ids': splitMemberIds,
      'expense_date': expenseDate.toIso8601String(),
      'notes': notes,
      'receipt_images': receiptImages,
      'reference_id': referenceId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 复制并修改
  Expense copyWith({
    String? id,
    String? tripId,
    String? title,
    int? amount,
    String? currency,
    ExpenseType? type,
    String? payerId,
    String? payerName,
    List<String>? splitMemberIds,
    DateTime? expenseDate,
    String? notes,
    List<String>? receiptImages,
    String? referenceId,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      payerId: payerId ?? this.payerId,
      payerName: payerName ?? this.payerName,
      splitMemberIds: splitMemberIds ?? this.splitMemberIds,
      expenseDate: expenseDate ?? this.expenseDate,
      notes: notes ?? this.notes,
      receiptImages: receiptImages ?? this.receiptImages,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
