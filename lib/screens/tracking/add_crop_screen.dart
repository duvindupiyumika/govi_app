import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../features/tracking/data/crop_activity_repository.dart';
import '../../features/tracking/data/crop_plan_repository.dart';
import '../../features/tracking/data/crop_task_repository.dart';
import '../../features/tracking/domain/crop_activity.dart';
import '../../features/tracking/domain/crop_lifecycle_service.dart';
import '../../features/tracking/domain/crop_plan.dart';
import '../profile/theme_provider.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _landSizeController = TextEditingController();
  final _locationController = TextEditingController();
  final _planRepository = CropPlanRepository();
  final _taskRepository = CropTaskRepository();
  final _activityRepository = CropActivityRepository();
  final _lifecycleService = CropLifecycleService();
  final _uuid = const Uuid();

  String _cropName = 'Brinjal';
  DateTime _startDate = DateTime.now();
  bool _isSaving = false;

  static const _crops = [
    'Brinjal',
    'Chilli',
    'Pumpkin',
    'Carrot',
    'Tomato',
    'Beans',
    'Bitter Gourd',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_locationController.text.isNotEmpty) return;

    final profile = context.read<ThemeProvider>().profile;
    _locationController.text = profile.location ?? '';
    _landSizeController.text = profile.landSize?.toString() ?? '';
  }

  @override
  void dispose() {
    _landSizeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _saveCrop() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final id = _uuid.v4();
    final landSize = double.tryParse(_landSizeController.text.trim());
    final harvestDate = _lifecycleService.harvestDateFor(_cropName, _startDate);
    final plan = CropPlan(
      id: id,
      cropName: _cropName,
      location: _locationController.text.trim(),
      landSize: landSize,
      startDate: _startDate,
      expectedHarvestDate: harvestDate,
      expectedYieldKg: _lifecycleService.expectedYieldFor(_cropName, landSize),
      updatedAt: DateTime.now(),
    );

    await _planRepository.save(plan.id, plan);
    for (final task in _lifecycleService.generateTasks(plan)) {
      await _taskRepository.save(task.id, task);
    }
    await _activityRepository.save(
      '${plan.id}_created',
      CropActivity(
        id: '${plan.id}_created',
        cropPlanId: plan.id,
        title: 'Started tracking $_cropName',
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Crop'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _cropName,
                decoration: const InputDecoration(
                  labelText: 'Crop',
                  border: OutlineInputBorder(),
                ),
                items: _crops
                    .map(
                      (crop) =>
                          DropdownMenuItem(value: crop, child: Text(crop)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _cropName = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landSizeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Land size (acres)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.square_foot),
                ),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return null;
                  final parsed = double.tryParse(trimmed);
                  return parsed == null || parsed <= 0
                      ? 'Enter a valid land size'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickStartDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  'Start: ${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveCrop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Start Tracking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
