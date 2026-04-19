import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/trip/trip_bloc.dart';
import '../../config/routes.dart';
import '../../widgets/loading_widget.dart';

/// 行程列表页面
class TripListPage extends StatelessWidget {
  const TripListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TripBloc()..add(const LoadTrips()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('我的行程'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // TODO: 打开筛选
              },
            ),
          ],
        ),
        body: BlocBuilder<TripBloc, TripState>(
          builder: (context, state) {
            if (state is TripLoading) {
              return const LoadingWidget();
            }
            if (state is TripError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<TripBloc>().add(const LoadTrips()),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }
            if (state is TripsLoaded) {
              if (state.trips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flight_takeoff,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('还没有行程'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.push(AppRoutes.tripCreate),
                        child: const Text('创建第一个行程'),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TripBloc>().add(const RefreshTrips());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.trips.length,
                  itemBuilder: (context, index) {
                    final trip = state.trips[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => context.push(
                          AppRoutes.tripDetail
                              .replaceAll(':id', trip.id),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    trip.destination,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '${trip.startDate.month}/${trip.startDate.day} - ${trip.endDate.month}/${trip.endDate.day}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${trip.days}天',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.tripCreate),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
