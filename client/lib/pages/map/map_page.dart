import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/map/map_bloc.dart';
import '../../core/constants.dart';
import '../../widgets/loading_widget.dart';

/// 地图页面
/// 显示地图、标记点、路线等
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc()..add(const InitializeMap()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('地图'),
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                // TODO: 定位到当前位置
              },
            ),
            IconButton(
              icon: const Icon(Icons.layers),
              onPressed: () {
                // TODO: 切换地图图层
              },
            ),
          ],
        ),
        body: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoading || state is MapInitial) {
              return const LoadingWidget();
            }
            if (state is MapError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<MapBloc>().add(const InitializeMap()),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }
            if (state is MapReady) {
              return Stack(
                children: [
                  // 地图视图占位
                  Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text('高德地图视图'),
                    ),
                  ),

                  // 搜索栏
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 4,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '搜索地点',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              // TODO: 清除搜索
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 轨迹记录按钮
                  if (state.isRecording)
                    Positioned(
                      bottom: 120,
                      right: 16,
                      child: FloatingActionButton(
                        heroTag: 'stop',
                        backgroundColor: Colors.red,
                        onPressed: () {
                          context
                              .read<MapBloc>()
                              .add(const StopTrajectoryRecording());
                        },
                        child: const Icon(Icons.stop),
                      ),
                    ),

                  // 底部信息面板
                  if (state.markers.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Text(
                          '共 ${state.markers.length} 个标记点',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'record',
          onPressed: () {
            final state = context.read<MapBloc>().state;
            if (state is MapReady && !state.isRecording) {
              context.read<MapBloc>().add(const StartTrajectoryRecording());
            }
          },
          child: const Icon(Icons.fiber_manual_record),
        ),
      ),
    );
  }
}
