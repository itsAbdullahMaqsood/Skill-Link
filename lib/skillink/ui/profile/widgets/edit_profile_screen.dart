import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skilllink/models/user.dart' as sc;
import 'package:skilllink/services/google_geocoding_service.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/app_user.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/app_text_field.dart';
import 'package:skilllink/skillink/ui/core/ui/app_scaffold.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';
import 'package:skilllink/skillink/ui/profile/view_models/profile_view_model.dart';
import 'package:skilllink/skillink/utils/avatar_url_image.dart';
import 'package:skilllink/skillink/utils/validators.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  final _age = TextEditingController();
  final _pastExperience = TextEditingController();
  final _location = TextEditingController();
  final _geocoding = GoogleGeocodingService();

  String? _gender;
  File? _newProfilePic;
  bool _mapsLocationLoading = false;
  bool _seeded = false;
  bool _seedCallbackScheduled = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bio.dispose();
    _age.dispose();
    _pastExperience.dispose();
    _location.dispose();
    super.dispose();
  }

  void _seed(sc.UserModel? labour, AppUser appUser) {
    if (labour != null) {
      _name.text =
          labour.fullName.isNotEmpty ? labour.fullName : appUser.name;
      _phone.text = labour.phoneNumber.isNotEmpty
          ? labour.phoneNumber
          : appUser.phone;
      _bio.text = (labour.bio ?? '').trim();
      final age = labour.age;
      _age.text = age > 0 ? '$age' : '';
      _pastExperience.text = (labour.pastExperience ?? '').trim();
      _location.text = labour.location.isNotEmpty
          ? labour.location
          : appUser.address.city;
      final g = labour.gender.trim().toLowerCase();
      if (const {'male', 'female', 'other'}.contains(g)) {
        _gender = g;
      }
    } else {
      _name.text = appUser.name;
      _phone.text = appUser.phone;
      _location.text = appUser.address.city;
    }
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (x == null || !mounted) return;
      setState(() => _newProfilePic = File(x.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not pick image')),
        );
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
        setState(() => _location.text = addr.trim());
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final g = _gender?.trim().toLowerCase();
    final gender = const {'male', 'female', 'other'}.contains(g)
        ? g!
        : 'other';
    final ageParsed = int.tryParse(_age.text.trim());
    await ref.read(profileViewModelProvider.notifier).save(
          name: _name.text.trim(),
          phone: Validators.normalizePhone(_phone.text.trim()),
          location: _location.text.trim(),
          bio: _bio.text.trim(),
          age: ageParsed,
          gender: gender,
          pastExperience: _pastExperience.text.trim(),
          profilePic: _newProfilePic,
        );
    if (!mounted) return;
    final err = ref.read(profileViewModelProvider).errorMessage;
    if (err == null) {
      setState(() => _newProfilePic = null);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;
    final labourAsync = ref.watch(currentLabourUserProvider);
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

    if (user != null &&
        !labourAsync.isLoading &&
        !_seeded &&
        !_seedCallbackScheduled) {
      _seedCallbackScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _seeded) return;
        _seeded = true;
        _seed(ref.read(currentLabourUserProvider).valueOrNull, user);
        setState(() {});
      });
    }

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

    if (labourAsync.isLoading) {
      return AppScaffold(
        title: 'Edit profile',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final labour = labourAsync.valueOrNull;
    final avatarUrl = _newProfilePic != null
        ? null
        : (labour?.profileImageUrl.isNotEmpty == true
            ? labour!.profileImageUrl
            : user.avatarUrl);

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
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.border,
                          child: _newProfilePic != null
                              ? ClipOval(
                                  child: Image.file(
                                    _newProfilePic!,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (avatarUrl != null && avatarUrl.isNotEmpty)
                                  ? ClipOval(
                                      child: accountAvatarSquare(
                                        avatarUrl,
                                        size: 96,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 48,
                                      color: AppColors.textMuted,
                                    ),
                        ),
                        Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _pickProfilePhoto,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _bio,
                    label: 'Bio (optional)',
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _pastExperience,
                    label: 'Past experience (optional)',
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _age,
                    label: 'Age (optional)',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null;
                      final n = int.tryParse(t);
                      if (n == null) return 'Enter a valid number';
                      if (n < 1 || n > 120) return 'Enter a realistic age';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_gender ?? 'unset'),
                    initialValue: _gender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _gender = v),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Select gender' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _location,
                    label: 'Location',
                    textInputAction: TextInputAction.done,
                    validator: (v) => Validators.required(v, 'Location'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed:
                        _mapsLocationLoading ? null : _useGoogleMapsLocation,
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
