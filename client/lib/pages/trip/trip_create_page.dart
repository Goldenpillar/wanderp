import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/trip/trip_bloc.dart';
import '../../config/routes.dart';

/// 创建行程页面
class TripCreatePage extends StatefulWidget {
  const TripCreatePage({super.key});

  @override
  State<TripCreatePage> createState() => _TripCreatePageState();
}

class _TripCreatePageState extends State<TripCreatePage> {
  /// 表单 Key
  final _formKey = GlobalKey<FormState>();

  /// 行程名称控制器
  final _nameController = TextEditingController();

  /// 目的地控制器
  final _destinationController = TextEditingController();

  /// 描述控制器
  final _descriptionController = TextEditingController();

  /// 出发日期
  DateTime? _startDate;

  /// 返回日期
  DateTime? _endDate;

  /// 预算
  final _budgetController = TextEditingController();

  /// 是否正在提交
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  /// 选择日期
  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? DateTime.now())
        : (_startDate ?? DateTime.now()).add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  /// 提交创建
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择出行日期')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<TripBloc>().add(
          CreateTrip({
            'name': _nameController.text,
            'destination': _destinationController.text,
            'description': _descriptionController.text,
            'start_date': _startDate!.toIso8601String(),
            'end_date': _endDate!.toIso8601String(),
            'budget': _budgetController.text.isNotEmpty
                ? (double.parse(_budgetController.text) * 100).toInt()
                : null,
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripOperationSuccess || state is TripsLoaded) {
          setState(() => _isSubmitting = false);
          context.pop();
        } else if (state is TripError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('创建行程'),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('创建'),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 行程名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '行程名称',
                  hintText: '给行程起个名字',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入行程名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 目的地
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: '目的地',
                  hintText: '你要去哪里？',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入目的地';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 出行日期
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '出发日期',
                        ),
                        child: Text(
                          _startDate != null
                              ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
                              : '选择出发日期',
                          style: TextStyle(
                            color: _startDate != null
                                ? null
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '返回日期',
                        ),
                        child: Text(
                          _endDate != null
                              ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
                              : '选择返回日期',
                          style: TextStyle(
                            color: _endDate != null ? null : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 行程描述
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '行程描述',
                  hintText: '简单描述一下这次旅行',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // 预算
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: '总预算（元）',
                  hintText: '预计花费多少',
                  prefixText: '¥',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),

              // 创建按钮
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('创建行程'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
