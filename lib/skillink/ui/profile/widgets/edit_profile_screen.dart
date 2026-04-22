import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/domain/models/structured_address.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/app_scaffold.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/profile/view_models/profile_view_model.dart';
import 'package:skilllink/skillink/utils/validators.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _street;
  late final TextEditingController _area;
  late final TextEditingController _city;
  late final TextEditingController _postalCode;
  var _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final u = ref.read(authViewModelProvider).user;
    _name = TextEditingController(text: u?.name ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
    _street = TextEditingController(text: u?.address.street ?? '');
    _area = TextEditingController(text: u?.address.area ?? '');
    _city = TextEditingController(text: u?.address.city ?? '');
    _postalCode = TextEditingController(text: u?.address.postalCode ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _street.dispose();
    _area.dispose();
    _city.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(profileViewModelProvider.notifier).save(
          name: _name.text.trim(),
          phone: Validators.normalizePhone(_phone.text.trim()),
          address: StructuredAddress(
            street: _street.text.trim(),
            area: _area.text.trim(),
            city: _city.text.trim(),
            postalCode: _postalCode.text.trim(),
          ),
        );
    if (!mounted) return;
    final err = ref.read(profileViewModelProvider).errorMessage;
    if (err == null) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;
    final ui = ref.watch(profileViewModelProvider);
    final vm = ref.read(profileViewModelProvider.notifier);

    ref.listen(profileViewModelProvider.select((s) => s.errorMessage),
        (prev, msg) {
      if (msg == null || msg == prev) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
        );
      vm.clearError();
    });

    if (user == null) {
      return AppScaffold(
        title: 'Edit profile',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'You need to be signed in to edit your profile.',
              style: AppTypography.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: 'Edit profile',
      body: SafeArea(
        child: AutofillGroup(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _name,
                    label: 'Full name',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: (v) {
                      final req = Validators.required(v, 'Name');
                      if (req != null) return req;
                      if ((v ?? '').trim().length < 2) {
                        return 'Enter at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _phone,
                    label: 'Phone',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    validator: (v) => Validators.phone(v),
                  ),
                  const SizedBox(height: 8),
                  Text('Address', style: AppTypography.titleLarge),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _street,
                    label: 'Street',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.streetAddressLine1],
                    validator: (v) => Validators.required(v, 'Street'),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _area,
                    label: 'Area',
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.required(v, 'Area'),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _city,
                    label: 'City',
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.addressCity],
                    validator: (v) => Validators.required(v, 'City'),
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _postalCode,
                    label: 'Postal code',
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.postalCode],
                    validator: (v) => Validators.required(v, 'Postal code'),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Save changes',
                    isLoading: ui.isSaving,
                    onPressed: ui.isSaving ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
