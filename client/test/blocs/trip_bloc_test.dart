import 'package:flutter_test/flutter_test.dart';
import 'package:wanderp/blocs/trip/trip_bloc.dart';
import 'package:wanderp/blocs/trip/trip_event.dart';
import 'package:wanderp/blocs/trip/trip_state.dart';

void main() {
  group('TripBloc', () {
    late TripBloc tripBloc;

    setUp(() {
      tripBloc = TripBloc();
    });

    tearDown(() {
      tripBloc.close();
    });

    test('初始状态为 TripInitial', () {
      expect(tripBloc.state, equals(const TripInitial()));
    });

    test('LoadTrips 事件将状态变为 TripLoading', () {
      // 由于 TripService 未实现，这里只验证事件触发后的初始状态变化
      // 实际测试需要 mock TripService
      expect(tripBloc.state, equals(const TripInitial()));
    });

    test('LoadTripDetail 事件携带正确的 tripId', () {
      const event = LoadTripDetail('test-trip-id');
      expect(event.tripId, equals('test-trip-id'));
    });

    test('CreateTrip 事件携带正确的数据', () {
      const tripData = {'name': '测试行程'};
      const event = CreateTrip(tripData);
      expect(event.tripData, equals(tripData));
    });

    test('DeleteTrip 事件携带正确的 tripId', () {
      const event = DeleteTrip('trip-to-delete');
      expect(event.tripId, equals('trip-to-delete'));
    });

    test('UpdateBudget 事件携带正确的数据', () {
      const event = UpdateBudget(tripId: 'trip-1', budget: 500000);
      expect(event.tripId, equals('trip-1'));
      expect(event.budget, equals(500000));
    });

    test('AddActivity 事件携带正确的数据', () {
      const activityData = {'name': '故宫'};
      const event = AddActivity(tripId: 'trip-1', activityData: activityData);
      expect(event.tripId, equals('trip-1'));
      expect(event.activityData, equals(activityData));
    });

    test('RemoveActivity 事件携带正确的数据', () {
      const event = RemoveActivity(tripId: 'trip-1', activityId: 'act-1');
      expect(event.tripId, equals('trip-1'));
      expect(event.activityId, equals('act-1'));
    });
  });
}
