import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skilllink/models/user.dart' as sc;
import 'package:skilllink/router/app_router.dart' as app_router;
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/domain/models/review.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/worker_home/view_models/worker_profile_view_model.dart';

class WorkerProfileEditScreen extends ConsumerStatefulWidget {
  const WorkerProfileEditScreen({super.key});

  @override
  ConsumerState<WorkerProfileEditScreen> createState() =>
      _WorkerProfileEditScreenState();
}

class _WorkerProfileEditScreenState
    extends ConsumerState<WorkerProfileEditScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _seeded = false;

  String? _gender;

  List<String> _selectedServiceIds = const [];

  File? _newProfilePic;
  File? _newCnicFront;
  File? _newCnicBack;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _experienceCtrl.dispose();
    _ageCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _seedControllers(Worker w, sc.UserModel? labour) {
    if (_seeded) return;
    _seeded = true;
    _nameCtrl.text = w.name;
    _phoneCtrl.text = w.phone;
    _bioCtrl.text = w.bio ?? '';
    _experienceCtrl.text = (labour?.pastExperience ?? '').trim();
    _locationCtrl.text = (labour?.location ?? '').trim();
    final age = labour?.age ?? 0;
    _ageCtrl.text = age > 0 ? age.toString() : '';
    final g = (labour?.gender ?? '').trim().toLowerCase();
    if (const {'male', 'female', 'other'}.contains(g)) _gender = g;
    _selectedServiceIds = List<String>.from(w.skillTypes);
  }

  Future<void> _pickImage(
    ImageSource source,
    void Function(File) onPicked,
  ) async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(source: source, imageQuality: 85);
      if (x == null || !mounted) return;
      onPicked(File(x.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Could not pick image')));
    }
  }

  Future<void> _pickAvatar() => _pickImage(
        ImageSource.gallery,
        (f) => setState(() => _newProfilePic = f),
      );

  Future<void> _pickCnicFront() => _pickImage(
        ImageSource.gallery,
        (f) => setState(() => _newCnicFront = f),
      );

  Future<void> _pickCnicBack() => _pickImage(
        ImageSource.gallery,
        (f) => setState(() => _newCnicBack = f),
      );

  void _onSave(WorkerProfileViewModel vm) {
    final form = _formKey.currentState;
    if (form != null && !form.validate()) return;

    final input = WorkerProfileInput(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      pastExperience: _experienceCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      gender: _gender,
      age: int.tryParse(_ageCtrl.text.trim()),
      selectedServiceIds:
          _selectedServiceIds.where((e) => e.trim().isNotEmpty).toList(),
      profilePic: _newProfilePic,
      cnicFront: _newCnicFront,
      cnicBack: _newCnicBack,
    );
    vm.updateProfile(input);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workerProfileViewModelProvider);
    final vm = ref.read(workerProfileViewModelProvider.notifier);
    final serviceMap =
        ref.watch(labourServiceIdToNameProvider).valueOrNull ?? const {};
    final labour = ref.watch(currentLabourUserProvider).valueOrNull;

    ref.listen(
      workerProfileViewModelProvider.select((s) => s.errorMessage),
      (_, msg) {
        if (msg != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(msg)));
          vm.clearError();
        }
      },
    );

    ref.listen(
      workerProfileViewModelProvider.select((s) => s.saveSuccess),
      (_, ok) {
        if (ok) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text('Profile updated'),
              backgroundColor: AppColors.success,
            ));
          setState(() {
            _newProfilePic = null;
            _newCnicFront = null;
            _newCnicBack = null;
          });
        }
      },
    );

    if (state.worker != null) _seedControllers(state.worker!, labour);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('My Profile', style: AppTypography.headlineMedium),
      ),
      body: state.isLoading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingShimmer(height: 300),
            )
          : state.worker == null
              ? const EmptyState(
                  icon: Icons.person_off_outlined,
                  title: 'Profile unavailable',
                  subtitle: 'Could not load your profile.',
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(currentLabourUserProvider);
                    await vm.refresh();
                  },
                  child: _body(state, vm, serviceMap, labour),
                ),
    );
  }

  Widget _body(
    WorkerProfileState state,
    WorkerProfileViewModel vm,
    Map<String, String> serviceIdToName,
    sc.UserModel? labour,
  ) {
    final w = state.worker!;
    final serviceLabels = resolveWorkerServiceLabels(
      w,
      idToName: serviceIdToName,
    );
    final serviceCatalog = serviceIdToName.entries
        .map((e) => _ServiceOption(id: e.key, name: e.value))
        .toList()
      ..sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    for (final id in _selectedServiceIds) {
      if (!serviceCatalog.any((s) => s.id == id)) {
        serviceCatalog.add(_ServiceOption(
          id: id,
          name: serviceIdToName[id] ?? _shortIdLabel(id),
        ));
      }
    }
    final selectedOptions = serviceCatalog
        .where((s) => _selectedServiceIds.contains(s.id))
        .toList();

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (w.rating < AppConstants.lowRatingWarningThreshold &&
              w.reviewCount > 0)
            _WarningBanner(rating: w.rating),

          Center(
            child: _AvatarPicker(
              existingUrl: w.avatarUrl,
              pickedFile: _newProfilePic,
              onTap: _pickAvatar,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    size: 18, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  '${w.rating.toStringAsFixed(1)}  (${w.reviewCount} reviews)',
                  style: AppTypography.bodyMedium,
                ),
                if (w.verificationStatus) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.verified_rounded,
                      size: 16, color: AppColors.primary),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Wrap(
              spacing: 6,
              alignment: WrapAlignment.center,
              children: [
                for (final label in serviceLabels)
                  Chip(
                    label: Text(
                      label,
                      style: AppTypography.labelMedium
                          .copyWith(color: AppColors.primary),
                    ),
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide.none,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _WorkerStatusRow(labour: labour),
          const SizedBox(height: 16),

          _ReadOnlyInfoCard(worker: w, labour: labour),
          const SizedBox(height: 16),

          AppTextField(
            label: 'Full Name',
            controller: _nameCtrl,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Phone',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Location',
            controller: _locationCtrl,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Age',
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return null;
                    final n = int.tryParse(s);
                    if (n == null || n < 1 || n > 150) return '1–150';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _GenderDropdown(
                value: _gender,
                onChanged: (v) => setState(() => _gender = v),
              )),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Bio',
            controller: _bioCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Past Experience',
            controller: _experienceCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _ServicesPicker(
            catalog: serviceCatalog,
            selected: selectedOptions,
            onChanged: (list) => setState(
              () => _selectedServiceIds = list.map((e) => e.id).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text('CNIC Scans', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _CnicPickerTile(
                  label: 'CNIC Front',
                  existingUrl: labour?.cnicFrontUrl,
                  pickedFile: _newCnicFront,
                  onTap: _pickCnicFront,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CnicPickerTile(
                  label: 'CNIC Back',
                  existingUrl: labour?.cnicBackUrl,
                  pickedFile: _newCnicBack,
                  onTap: _pickCnicBack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Save Changes',
            isLoading: state.isSaving,
            onPressed: state.isSaving ? null : () => _onSave(vm),
          ),

          const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('Notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.notifications),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.helpSupport),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.danger),
                title: Text(
                  'Log out',
                  style:
                      AppTypography.titleLarge.copyWith(color: AppColors.danger),
                ),
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        Text('Reviews Received', style: AppTypography.titleLarge),
        const SizedBox(height: 10),
        if (state.reviews.isEmpty)
          const EmptyState(
            icon: Icons.rate_review_outlined,
            title: 'No reviews yet',
            subtitle: 'Reviews from homeowners will appear here.',
          )
        else
          for (final r in state.reviews) ...[
            _ReviewTile(review: r),
            const SizedBox(height: 8),
          ],
      ],
      ),
    );
  }

  static String _shortIdLabel(String id) {
    if (id.isEmpty) return 'Service';
    final tail = id.length > 6 ? id.substring(id.length - 6) : id;
    return 'Skill ··$tail';
  }

  Future<void> _logout(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await ref.read(authViewModelProvider.notifier).signOut();
    await app_router.reloadSkillPrefs(container);
    if (!context.mounted) return;
    context.go(app_router.skillTypePath);
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.danger, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your recent rating is ${rating.toStringAsFixed(1)}. '
              'Account will be suspended below '
              '${AppConstants.suspensionThreshold.toStringAsFixed(1)}.',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 2),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Anonymous Homeowner',
                  style: AppTypography.titleLarge),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= review.rating.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: AppColors.accent,
                    ),
                ],
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.comment!, style: AppTypography.bodyMedium),
          ],
          const SizedBox(height: 4),
          Text(
            _daysAgo(review.createdAt),
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  static String _daysAgo(DateTime dt) {
    final days = DateTime.now().difference(dt).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }
}

class _WorkerStatusRow extends StatelessWidget {
  const _WorkerStatusRow({required this.labour});

  final sc.UserModel? labour;

  @override
  Widget build(BuildContext context) {
    final u = labour;
    if (u == null) return const SizedBox.shrink();

    final status = u.status.trim();
    final verified = u.verified;
    final chips = <Widget>[
      _StatusPill(
        icon: Icons.construction_rounded,
        label: 'Worker',
        background: AppColors.primary.withValues(alpha: 0.08),
        foreground: AppColors.primary,
      ),
      if (status.isNotEmpty)
        _StatusPill(
          icon: status.toLowerCase() == 'approved'
              ? Icons.check_circle_outline_rounded
              : Icons.hourglass_top_rounded,
          label: _capitalize(status),
          background: (status.toLowerCase() == 'approved'
                  ? AppColors.success
                  : AppColors.warning)
              .withValues(alpha: 0.10),
          foreground: status.toLowerCase() == 'approved'
              ? AppColors.success
              : AppColors.warning,
        ),
      if (verified)
        _StatusPill(
          icon: Icons.verified_rounded,
          label: 'Verified',
          background: AppColors.success.withValues(alpha: 0.10),
          foreground: AppColors.success,
        ),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: chips,
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyInfoCard extends StatelessWidget {
  const _ReadOnlyInfoCard({required this.worker, required this.labour});

  final Worker worker;
  final sc.UserModel? labour;

  @override
  Widget build(BuildContext context) {
    final email = (labour?.email ?? worker.email).trim();
    if (email.isEmpty) return const SizedBox.shrink();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: _InfoRow(
        icon: Icons.email_outlined,
        label: 'Email',
        value: email,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textMuted),
      title: Text(
        label,
        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
      ),
      subtitle: Text(value, style: AppTypography.bodyMedium),
      dense: true,
    );
  }
}


class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.existingUrl,
    required this.pickedFile,
    required this.onTap,
  });

  final String? existingUrl;
  final File? pickedFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          RoundAvatar(
            url: existingUrl,
            pickedFile: pickedFile,
            radius: 44,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            placeholder: const Icon(Icons.person_rounded,
                size: 40, color: AppColors.primary),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: const Icon(Icons.photo_camera_outlined,
                  size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  const _GenderDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Select',
          ),
        ),
      ],
    );
  }
}

class _ServiceOption {
  const _ServiceOption({required this.id, required this.name});
  final String id;
  final String name;
}

class _ServicesPicker extends StatelessWidget {
  const _ServicesPicker({
    required this.catalog,
    required this.selected,
    required this.onChanged,
  });

  final List<_ServiceOption> catalog;
  final List<_ServiceOption> selected;
  final ValueChanged<List<_ServiceOption>> onChanged;

  @override
  Widget build(BuildContext context) {
    if (catalog.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Services', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          TextField(
            enabled: false,
            decoration: const InputDecoration(hintText: 'Loading services…'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Services', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        DropdownSearch<_ServiceOption>.multiSelection(
          items: catalog,
          selectedItems: selected,
          onChanged: onChanged,
          itemAsString: (s) => s.name,
          compareFn: (a, b) => a.id == b.id,
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: 'Select one or more services',
            ),
          ),
          popupProps: const PopupPropsMultiSelection.menu(
            showSearchBox: true,
            showSelectedItems: true,
          ),
        ),
      ],
    );
  }
}

class _CnicPickerTile extends StatelessWidget {
  const _CnicPickerTile({
    required this.label,
    required this.existingUrl,
    required this.pickedFile,
    required this.onTap,
  });

  final String label;
  final String? existingUrl;
  final File? pickedFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget preview;
    if (pickedFile != null) {
      preview = Image.file(pickedFile!, fit: BoxFit.cover);
    } else if (existingUrl != null && existingUrl!.isNotEmpty) {
      preview = Image.network(
        existingUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    } else {
      preview = _placeholder(context);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    preview,
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.photo_camera_outlined,
                                size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Replace',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.badge_outlined,
                color: AppColors.textMuted, size: 28),
            const SizedBox(height: 4),
            Text(
              'Tap to upload',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
}
