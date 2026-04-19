import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/preference_provider.dart';

/// 偏好收集页面
/// 收集成员的旅行偏好，用于智能推荐
class PreferencePage extends ConsumerStatefulWidget {
  const PreferencePage({super.key});

  @override
  ConsumerState<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends ConsumerState<PreferencePage> {
  /// 选中的旅行风格
  final Set<String> _selectedStyles = {};

  /// 选中的饮食偏好
  final Set<String> _selectedFoods = {};

  /// 预算等级
  int _budgetLevel = 3;

  /// 获取图标
  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'mountain':
        return Icons.terrain;
      case 'beach':
        return Icons.beach_access;
      case 'museum':
        return Icons.museum;
      case 'restaurant':
        return Icons.restaurant;
      case 'nature':
        return Icons.park;
      case 'city':
        return Icons.location_city;
      case 'shopping':
        return Icons.shopping_bag;
      case 'camera':
        return Icons.camera_alt;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final styleOptions = ref.watch(travelStyleOptionsProvider);
    final cuisineOptions = ref.watch(cuisineOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('旅行偏好')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 旅行风格
          const Text(
            '旅行风格（可多选）',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: styleOptions.map((option) {
              final isSelected = _selectedStyles.contains(option['id']);
              return FilterChip(
                label: Text(option['label']!),
                avatar: Icon(_getIcon(option['icon']!)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStyles.add(option['id']!);
                    } else {
                      _selectedStyles.remove(option['id']!);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 饮食偏好
          const Text(
            '饮食偏好（可多选）',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cuisineOptions.map((option) {
              final isSelected = _selectedFoods.contains(option['id']);
              return FilterChip(
                label: Text(option['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFoods.add(option['id']!);
                    } else {
                      _selectedFoods.remove(option['id']!);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 预算等级
          const Text(
            '预算偏好',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('经济'),
              Expanded(
                child: Slider(
                  value: _budgetLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _getBudgetLabel(_budgetLevel),
                  onChanged: (value) {
                    setState(() => _budgetLevel = value.toInt());
                  },
                ),
              ),
              const Text('豪华'),
            ],
          ),
          Text(
            _getBudgetLabel(_budgetLevel),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // 提交按钮
          ElevatedButton(
            onPressed: () {
              // TODO: 提交偏好
              Navigator.of(context).pop();
            },
            child: const Text('保存偏好'),
          ),
        ],
      ),
    );
  }

  /// 获取预算等级标签
  String _getBudgetLabel(int level) {
    switch (level) {
      case 1:
        return '非常经济';
      case 2:
        return '比较经济';
      case 3:
        return '适中';
      case 4:
        return '比较舒适';
      case 5:
        return '豪华';
      default:
        return '适中';
    }
  }
}
