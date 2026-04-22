import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/repositories/iot_repository.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/iot_monitor/view_models/appliances_list_view_model.dart';
import 'package:skilllink/skillink/ui/iot_monitor/widgets/anomaly_visuals.dart';

class AddApplianceSheet extends ConsumerStatefulWidget {
  const AddApplianceSheet({super.key});

  @override
  ConsumerState<AddApplianceSheet> createState() => _AddApplianceSheetState();
}

class _AddApplianceSheetState extends ConsumerState<AddApplianceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _deviceCtrl = TextEditingController();

  String? _selectedType;
  bool _submitting = false;
  String? _errorMessage;

  static const List<({String id, String label})> _types = [
    (id: 'ac', label: 'AC'),
    (id: 'fridge', label: 'Fridge'),
    (id: 'heater', label: 'Heater'),
    (id: 'washer', label: 'Washer'),
    (id: 'oven', label: 'Oven'),
    (id: 'tv', label: 'TV'),
  ];

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _deviceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_selectedType == null) {
      setState(() => _errorMessage = 'Pick an appliance type first.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final err = await ref
        .read(appliancesListViewModelProvider.notifier)
        .addAppliance(AddApplianceInput(
          type: _selectedType!,
          brand: _brandCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          iotDeviceId: _deviceCtrl.text.trim(),
        ));

    if (!mounted) return;
    if (err != null) {
      setState(() {
        _submitting = false;
        _errorMessage = err;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Add Appliance', style: AppTypography.headlineMedium),
              const SizedBox(height: 6),
              Text(
                'Pair your ESP32 smart plug and start tracking real-time '
                'power draw.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 20),
              Text('Type', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in _types) _TypeChip(
                    label: t.label,
                    icon: AnomalyVisuals.iconForApplianceType(t.id),
                    selected: _selectedType == t.id,
                    onTap: () => setState(() => _selectedType = t.id),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'Brand',
                controller: _brandCtrl,
                hint: 'Haier, Dawlance, Orient…',
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Enter the brand.'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Model',
                controller: _modelCtrl,
                hint: '1.5 Ton Inverter',
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Enter the model.'
                    : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'ESP32 Device ID',
                controller: _deviceCtrl,
                hint: 'esp32_001',
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Enter the device ID printed on your smart plug.'
                    : null,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Add Appliance',
                onPressed: _submit,
                isLoading: _submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
