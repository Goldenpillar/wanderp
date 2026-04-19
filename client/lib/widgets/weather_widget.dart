import 'package:flutter/material.dart';

/// 天气数据模型
class WeatherData {
  /// 温度
  final double temperature;

  /// 天气状况描述
  final String description;

  /// 天气图标
  final IconData icon;

  /// 湿度
  final int? humidity;

  /// 风速
  final String? wind;

  /// 城市名称
  final String? city;

  /// 是否适合出行
  final bool isGoodForTravel;

  const WeatherData({
    required this.temperature,
    required this.description,
    required this.icon,
    this.humidity,
    this.wind,
    this.city,
    this.isGoodForTravel = true,
  });
}

/// 天气组件
/// 显示当前天气信息和出行建议
class WeatherWidget extends StatelessWidget {
  /// 天气数据
  final WeatherData weather;

  /// 是否显示详细信息
  final bool showDetails;

  /// 是否紧凑模式
  final bool compact;

  /// 点击回调
  final VoidCallback? onTap;

  const WeatherWidget({
    super.key,
    required this.weather,
    this.showDetails = true,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactWidget(context);
    }
    return _buildFullWidget(context);
  }

  /// 构建完整天气组件
  Widget _buildFullWidget(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 天气图标
              Icon(
                weather.icon,
                size: 48,
                color: _getWeatherColor(),
              ),
              const SizedBox(width: 16),

              // 天气信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.toStringAsFixed(0)}°C',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      weather.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (weather.city != null)
                      Text(
                        weather.city!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              // 详细信息和出行建议
              if (showDetails)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (weather.humidity != null)
                      Text(
                        '湿度 ${weather.humidity}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    if (weather.wind != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        weather.wind!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: weather.isGoodForTravel
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        weather.isGoodForTravel ? '适宜出行' : '注意天气',
                        style: TextStyle(
                          color: weather.isGoodForTravel
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建紧凑天气组件
  Widget _buildCompactWidget(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              weather.icon,
              size: 20,
              color: _getWeatherColor(),
            ),
            const SizedBox(width: 4),
            Text(
              '${weather.temperature.toStringAsFixed(0)}°',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据天气状况获取颜色
  Color _getWeatherColor() {
    final desc = weather.description.toLowerCase();
    if (desc.contains('晴')) return Colors.amber[700]!;
    if (desc.contains('云') || desc.contains('阴')) return Colors.grey[600]!;
    if (desc.contains('雨')) return Colors.blue[700]!;
    if (desc.contains('雪')) return Colors.lightBlue[700]!;
    return Colors.grey[600]!;
  }
}
