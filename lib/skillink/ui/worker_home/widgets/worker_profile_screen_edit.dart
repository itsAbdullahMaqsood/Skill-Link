import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skilllink/models/user.dart' as sc;
import 'package:skilllink/services/google_geocoding_service.dart';
import 'package:skilllink/skillink/config/app_constants.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/worker_repository.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/empty_state.dart';
import 'package:skilllink/skillink/ui/core/ui/loading_shimmer.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';
import 'package:skilllink/skillink/ui/worker_home/view_models/worker_profile_view_model.dart';
import 'package:skilllink/skillink/ui/worker_home/widgets/worker_profile_shared.dart';

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

  final _geocoding = GoogleGeocodingService();
  bool _mapsLocationLoading = false;

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
    _locationCtrl.text = (labour?.location ?? w.location ?? '').trim();
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

  Future<void> _useGoogleMapsLocation() async {
    if (_mapsLocationLoading) return;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required for this.'),
        ),
      );
      return;
    }

    setState(() => _mapsLocationLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      final addr = await _geocoding.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      if (!mounted) return;
      setState(() => _mapsLocationLoading = false);
      if (addr != null && addr.trim().isNotEmpty) {
        setState(() => _locationCtrl.text = addr.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not resolve address. Add GOOGLE_MAPS_API_KEY to .env '
              'and enable the Geocoding API for that key.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _mapsLocationLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location.')),
      );
    }
  }

  Future<void> _pickAvatar() => _pickImage(
    ImageSource.gallery,
    (f) => setState(() => _newProfilePic = f),
  );

  Future<void> _pickCnicFront() =>
      _pickImage(ImageSource.gallery, (f) => setState(() => _newCnicFront = f));

  Future<void> _pickCnicBack() =>
      _pickImage(ImageSource.gallery, (f) => setState(() => _newCnicBack = f));

  void _onGenderChanged(String? value) {
    if (!mounted) return;
    setState(() => _gender = value);
  }

  void _onServicesChanged(List<_ServiceOption> list) {
    if (!mounted) return;
    setState(() => _selectedServiceIds = list.map((e) => e.id).toList());
  }

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
      selectedServiceIds: _selectedServiceIds
          .where((e) => e.trim().isNotEmpty)
          .toList(),
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

    ref.listen(workerProfileViewModelProvider.select((s) => s.errorMessage), (
      _,
      msg,
    ) {
      if (msg != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(msg)));
        vm.clearError();
      }
    });

    ref.listen(workerProfileViewModelProvider.select((s) => s.saveSuccess), (
      _,
      ok,
    ) {
      if (ok) {
        if (!mounted) return;
        vm.clearSaveSuccess();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Profile updated'),
              backgroundColor: AppColors.success,
            ),
          );
        setState(() {
          _newProfilePic = null;
          _newCnicFront = null;
          _newCnicBack = null;
        });
        context.pop();
      }
    });

    if (state.worker != null) _seedControllers(state.worker!, labour);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Edit profile', style: AppTypography.headlineMedium),
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
              onRefresh: vm.refresh,
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
    final serviceCatalog =
        serviceIdToName.entries
            .map((e) => _ServiceOption(id: e.key, name: e.value))
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    for (final id in _selectedServiceIds) {
      if (!serviceCatalog.any((s) => s.id == id)) {
        serviceCatalog.add(
          _ServiceOption(
            id: id,
            name: serviceIdToName[id] ?? _shortIdLabel(id),
          ),
        );
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
            WorkerProfileWarningBanner(rating: w.rating),

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
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '${w.rating.toStringAsFixed(1)}  (${w.reviewCount} reviews)',
                  style: AppTypography.bodyMedium,
                ),
                if (w.verificationStatus) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          WorkerAccountStatusRow(labour: labour),
          const SizedBox(height: 16),
          if (labour != null && labour.email.trim().isNotEmpty)
            Card(
              clipBehavior: Clip.antiAlias,
              child: WorkerProfileInfoTile(
                icon: Icons.email_outlined,
                label: 'Email (read-only)',
                value: labour.email.trim(),
              ),
            ),
          if (labour != null && labour.email.trim().isNotEmpty)
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
          AppTextField(label: 'Location', controller: _locationCtrl),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _mapsLocationLoading ? null : _useGoogleMapsLocation,
            icon: _mapsLocationLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_outlined, size: 20),
            label: Text(
              _mapsLocationLoading
                  ? 'Fetching…'
                  : 'Use current location (Google Maps)',
            ),
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
              Expanded(
                child: _GenderDropdown(
                  value: _gender,
                  onChanged: _onGenderChanged,
                ),
              ),
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
            onChanged: _onServicesChanged,
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
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Save changes',
            isLoading: state.isSaving,
            onPressed: state.isSaving ? null : () => _onSave(vm),
          ),
        ],
      ),
    );
  }

  static String _shortIdLabel(String id) {
    if (id.isEmpty) return 'Service';
    final tail = id.length > 6 ? id.substring(id.length - 6) : id;
    return 'Skill ··$tail';
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
            placeholder: const Icon(
              Icons.person_rounded,
              size: 40,
              color: AppColors.primary,
            ),
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
              child: const Icon(
                Icons.photo_camera_outlined,
                size: 14,
                color: Colors.white,
              ),
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
          key: ValueKey(value ?? 'unset'),
          initialValue: value,
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Male')),
            DropdownMenuItem(value: 'female', child: Text('Female')),
            DropdownMenuItem(value: 'other', child: Text('Other')),
          ],
          onChanged: onChanged,
          decoration: const InputDecoration(hintText: 'Select'),
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
      preview = CachedNetworkImage(
        imageUrl: existingUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _loadErrorPlaceholder(context),
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_camera_outlined,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pickedFile != null
                                  ? 'Replace'
                                  : (existingUrl != null &&
                                            existingUrl!.isNotEmpty
                                        ? 'Update'
                                        : 'Upload'),
                              style: const TextStyle(
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
        Icon(Icons.badge_outlined, color: AppColors.textMuted, size: 28),
        const SizedBox(height: 4),
        Text(
          'Tap to upload',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    ),
  );

  Widget _loadErrorPlaceholder(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: AppColors.textMuted,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            'Could not load image',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    ),
  );
}
