import 'package:flutter_test/flutter_test.dart';
import 'package:wanderp/models/trip.dart';

void main() {
  group('Trip 模型', () {
    test('创建行程实例', () {
      final trip = Trip(
        id: '1',
        name: '北京之旅',
        destination: '北京',
        startDate: DateTime(2024, 10, 1),
        endDate: DateTime(2024, 10, 5),
        creatorId: 'user-1',
        budget: 500000,
        usedBudget: 200000,
      );

      expect(trip.id, equals('1'));
      expect(trip.name, equals('北京之旅'));
      expect(trip.destination, equals('北京'));
      expect(trip.days, equals(5));
      expect(trip.isActive, isFalse);
      expect(trip.isCompleted, isFalse);
    });

    test('计算剩余预算', () {
      final trip = Trip(
        id: '1',
        name: '测试行程',
        destination: '上海',
        startDate: DateTime(2024, 10, 1),
        endDate: DateTime(2024, 10, 3),
        creatorId: 'user-1',
        budget: 300000,
        usedBudget: 120000,
      );

      expect(trip.remainingBudget, equals(180000));
      expect(trip.budgetUsagePercent, closeTo(0.4, 0.01));
    });

    test('JSON 序列化和反序列化', () {
      final trip = Trip(
        id: '1',
        name: '上海之旅',
        description: '魔都探索',
        destination: '上海',
        startDate: DateTime(2024, 10, 1),
        endDate: DateTime(2024, 10, 4),
        status: TripStatus.active,
        creatorId: 'user-1',
        memberIds: ['user-2', 'user-3'],
        budget: 400000,
        usedBudget: 150000,
      );

      final json = trip.toJson();
      final restored = Trip.fromJson(json);

      expect(restored.id, equals(trip.id));
      expect(restored.name, equals(trip.name));
      expect(restored.description, equals(trip.description));
      expect(restored.destination, equals(trip.destination));
      expect(restored.status, equals(TripStatus.active));
      expect(restored.memberIds, equals(['user-2', 'user-3']));
      expect(restored.budget, equals(400000));
      expect(restored.usedBudget, equals(150000));
    });

    test('copyWith 正确复制并修改', () {
      final trip = Trip(
        id: '1',
        name: '原始行程',
        destination: '北京',
        startDate: DateTime(2024, 10, 1),
        endDate: DateTime(2024, 10, 3),
        creatorId: 'user-1',
      );

      final updated = trip.copyWith(
        name: '更新后的行程',
        budget: 200000,
      );

      expect(updated.id, equals('1')); // 未修改
      expect(updated.name, equals('更新后的行程')); // 已修改
      expect(updated.destination, equals('北京')); // 未修改
      expect(updated.budget, equals(200000)); // 已修改
    });

    test('行程天数计算', () {
      final trip1 = Trip(
        id: '1',
        name: '一日游',
        destination: '北京',
        startDate: DateTime(2024, 10, 1),
        endDate: DateTime(2024, 10, 1),
        creatorId: 'user-1',
      );
      expect(trip1.days, equals(1));

      final trip2 = Trip(
        id: '2',
        name: '三日游',
        destination: '上海',
        startDate: DateTime(2024, 10, 1),
        endDate: DateTime(2024, 10, 3),
        creatorId: 'user-1',
      );
      expect(trip2.days, equals(3));
    });
  });
}
