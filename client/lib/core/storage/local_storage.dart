import 'dart:convert';

import 'package:hive/hive.dart';

import '../utils/logger.dart';

/// Hive 本地存储封装
/// 提供键值对形式的本地持久化存储
class LocalStorage {
  LocalStorage._();

  static late LocalStorage _instance;
  static LocalStorage get instance => _instance;

  /// 存储盒子名称
  static const String _boxName = 'wanderp_storage';

  late Box _box;

  /// 初始化本地存储
  static Future<void> init() async {
    _instance = LocalStorage._();
    _instance._box = await Hive.openBox(_boxName);
    Logger.i('本地存储初始化完成');
  }

  // ==================== 基础操作 ====================

  /// 保存字符串
  Future<void> setString(String key, String value) async {
    await _box.put(key, value);
  }

  /// 获取字符串
  String? getString(String key) {
    return _box.get(key) as String?;
  }

  /// 保存整数
  Future<void> setInt(String key, int value) async {
    await _box.put(key, value);
  }

  /// 获取整数
  int? getInt(String key) {
    return _box.get(key) as int?;
  }

  /// 保存布尔值
  Future<void> setBool(String key, bool value) async {
    await _box.put(key, value);
  }

  /// 获取布尔值
  bool? getBool(String key) {
    return _box.get(key) as bool?;
  }

  /// 保存双精度浮点数
  Future<void> setDouble(String key, double value) async {
    await _box.put(key, value);
  }

  /// 获取双精度浮点数
  double? getDouble(String key) {
    return _box.get(key) as double?;
  }

  /// 保存对象（JSON 序列化）
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _box.put(key, jsonEncode(value));
  }

  /// 获取对象（JSON 反序列化）
  Map<String, dynamic>? getObject(String key) {
    final value = _box.get(key);
    if (value == null) return null;
    if (value is String) {
      return jsonDecode(value) as Map<String, dynamic>;
    }
    return value as Map<String, dynamic>?;
  }

  /// 保存列表
  Future<void> setList(String key, List<dynamic> value) async {
    await _box.put(key, jsonEncode(value));
  }

  /// 获取列表
  List<dynamic>? getList(String key) {
    final value = _box.get(key);
    if (value == null) return null;
    if (value is String) {
      return jsonDecode(value) as List<dynamic>;
    }
    return value as List<dynamic>?;
  }

  // ==================== 删除操作 ====================

  /// 删除指定 key
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  /// 检查 key 是否存在
  bool containsKey(String key) {
    return _box.containsKey(key);
  }

  /// 清空所有数据
  Future<void> clear() async {
    await _box.clear();
  }

  /// 获取所有 keys
  List<String> get keys => _box.keys.cast<String>().toList();
}
