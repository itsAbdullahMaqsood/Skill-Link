import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilllink/Widgets/auth_back_scope.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/core/storage/token_storage.dart';
import 'package:skilllink/models/signup_models.dart';
import 'package:skilllink/router/app_router.dart' as app_router;
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/google_geocoding_service.dart';
import 'package:skilllink/services/signup_api_service.dart';
import 'package:skilllink/skillink/data/repositories/skillchain_auth_repository.dart';
import 'package:skilllink/skillink/ui/core/themes/app_colors.dart';
import 'package:skilllink/skillink/ui/core/themes/app_typography.dart';
import 'package:skilllink/skillink/ui/core/ui/primary_button.dart';

class SignupProfilePage extends StatefulWidget {
  const SignupProfilePage({
    super.key,
    required this.email,
    required this.tempToken,
  });

  final String email;
  final String tempToken;

  @override
  State<SignupProfilePage> createState() => _SignupProfilePageState();
}

class _SignupProfilePageState extends State<SignupProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _api = SignupApiService();
  final _authService = AuthService();
  final _tokenStorage = TokenStorage();
  final _geocoding = GoogleGeocodingService();

  final _fullNameController = TextEditingController();
  late final TextEditingController _emailDisplayController;
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _educationController = TextEditingController();
  final _pastExperienceController = TextEditingController();

  String? _gender;
  List<SkillItem> _offeringSkills = [];
  List<SkillItem> _learningSkills = [];
  List<SkillItem> _labourServiceCatalog = [];
  List<SkillItem> _labourSelectedServices = [];
  List<File> _certificates = [];

  File? _profilePic;
  File? _portfolio;
  File? _resume;

  bool _isLoading = false;
  String? _errorMessage;
  List<SkillItem>? _skillsCache;
  bool _skillsLoading = true;
  String? _skillsError;
  bool _labourServicesLoading = false;
  String? _labourServicesError;

  bool _labour = false;
  bool _labourWorker = false;
  bool _mapsLocationLoading = false;
  File? _cnicFront;
  File? _cnicBack;

  @override
  void initState() {
    super.initState();
    _emailDisplayController = TextEditingController(text: widget.email);
    _locationController.text = '';
    _boot();
  }

  Future<void> _boot() async {
    final p = await SharedPreferences.getInstance();
    final labour = p.getString(app_router.skillTypePrefKey) == 'labour';
    final labourWorker = labour && p.getString(kLabourRolePrefKey) == 'worker';
    if (!mounted) return;
    setState(() {
      _labour = labour;
      _labourWorker = labourWorker;
      if (labour) _skillsLoading = false;
      if (labourWorker) _labourServicesLoading = true;
    });
    if (!labour) {
      _loadSkills();
    } else if (labourWorker) {
      _loadLabourServices();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailDisplayController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _educationController.dispose();
    _pastExperienceController.dispose();
    super.dispose();
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
        setState(() => _locationController.text = addr.trim());
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

  Future<void> _loadLabourServices() async {
    if (mounted) {
      setState(() {
        _labourServicesLoading = true;
        _labourServicesError = null;
      });
    }
    try {
      final list =
          await _api.fetchActiveLabourServices(widget.tempToken.trim());
      if (!mounted) return;
      setState(() {
        _labourServiceCatalog = list;
        _labourServicesLoading = false;
        _labourServicesError =
            list.isEmpty ? 'No services available. Try again later.' : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _labourServicesLoading = false;
        _labourServicesError = 'Failed to load services';
        _labourServiceCatalog = [];
      });
    }
  }

  Future<void> _loadSkills() async {
    if (_skillsCache != null && !_skillsLoading) return;
    if (mounted) {
      setState(() {
        _skillsLoading = true;
        _skillsError = null;
      });
    }
    try {
      final list = await _api.getSkills();
      if (mounted) {
        setState(() {
          _skillsCache = list;
          _skillsLoading = false;
          _skillsError = list.isEmpty ? 'No skills loaded' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _skillsLoading = false;
          _skillsError = 'Failed to load skills';
          _skillsCache = [];
        });
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x != null && mounted) {
      setState(() => _profilePic = File(x.path));
    }
  }

  Future<void> _pickCnicFront() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x != null && mounted) {
      setState(() => _cnicFront = File(x.path));
    }
  }

  Future<void> _pickCnicBack() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x != null && mounted) {
      setState(() => _cnicBack = File(x.path));
    }
  }

  Future<void> _pickPortfolio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null && mounted) {
      setState(() => _portfolio = File(result.files.single.path!));
    }
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null && mounted) {
      setState(() => _resume = File(result.files.single.path!));
    }
  }

  Future<void> _pickCertificates() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result != null && result.files.any((f) => f.path != null) && mounted) {
      setState(() {
        for (final f in result.files) {
          if (f.path != null) _certificates.add(File(f.path!));
        }
      });
    }
  }

  void _removeCertificate(File f) {
    setState(() => _certificates.remove(f));
  }

  Future<void> _submit() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;
    if (_labour) {
      if (_cnicFront == null || _cnicBack == null) {
        setState(
          () => _errorMessage = 'CNIC front and back images are required',
        );
        return;
      }
      if (_labourWorker) {
        if (_labourSelectedServices.isEmpty) {
          setState(
            () => _errorMessage = 'Select at least one service you offer',
          );
          return;
        }
      }
    } else {
      if (_offeringSkills.isEmpty) {
        setState(() => _errorMessage = 'Select at least one offering skill');
        return;
      }
      if (_learningSkills.isEmpty) {
        setState(() => _errorMessage = 'Select at least one learning skill');
        return;
      }
    }
    final age = int.tryParse(_ageController.text.trim());
    final phone = _phoneNumberController.text.trim();
    if (age == null || age < 1 || age > 150) {
      setState(() => _errorMessage = 'Enter a valid age (1–150)');
      return;
    }
    if (phone.isEmpty) {
      setState(() => _errorMessage = 'Phone number is required');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _api.signup(
        token: widget.tempToken,
        email: widget.email,
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phoneNumber: phone,
        age: age,
        gender: _gender ?? 'other',
        location: _locationController.text.trim(),
        offeringSkills: _labour
            ? (_labourWorker
                ? _labourSelectedServices.map((e) => e.id).join(',')
                : '')
            : _offeringSkills.map((e) => e.id).join(','),
        learningSkills: _labour
            ? ''
            : _learningSkills.map((e) => e.id).join(','),
        education: _educationController.text.trim().isEmpty
            ? null
            : _educationController.text.trim(),
        pastExperience: (_labour && !_labourWorker)
            ? null
            : (_pastExperienceController.text.trim().isEmpty
                ? null
                : _pastExperienceController.text.trim()),
        profilePic: _profilePic,
        portfolio: _portfolio,
        resume: _resume,
        certificate: _certificates,
        cnicFront: _labour ? _cnicFront : null,
        cnicBack: _labour ? _cnicBack : null,
      );

      if (!mounted) return;
      final container = ProviderScope.containerOf(context, listen: false);
      await _authService.persistAuthFromSignup(
        res,
        labourBackend: _labour,
      );
      await _tokenStorage.clearTempSignupToken();
      await app_router.reloadSkillPrefs(container);

      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go(app_router.postLoginLanding(
        app_router.currentSkillType(),
        app_router.currentLabourRole(),
      ));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackScope(
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            'Complete profile',
            style: AppTypography.headlineSmall.copyWith(color: Colors.white),
          ),
        ),
        body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Form(
                key: _formKey,
                child: SafeArea(
                  top: false,
                  child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _field(
                      controller: _fullNameController,
                      label: 'Full name *',
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Required' : null,
                    ),
                    _field(
                      controller: _emailDisplayController,
                      label: 'Email',
                      readOnly: true,
                    ),
                    _field(
                      controller: _passwordController,
                      label: 'Password *',
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    _field(
                      controller: _phoneNumberController,
                      label: 'Phone number *',
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Required' : null,
                    ),
                    _field(
                      controller: _ageController,
                      label: 'Age *',
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final n = int.tryParse(v?.trim() ?? '');
                        if (n == null || n < 1 || n > 150) {
                          return 'Enter 1–150';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _inputDecoration('Gender *'),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _gender = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      controller: _locationController,
                      label: 'Location *',
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Required' : null,
                    ),
                    if (_labour) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed:
                              _mapsLocationLoading ? null : _useGoogleMapsLocation,
                          icon: _mapsLocationLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(Icons.location_on_outlined,
                                  color: AppColors.primary),
                          label: Text(
                            _mapsLocationLoading
                                ? 'Getting address…'
                                : 'Use my current location (Google Maps)',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'CNIC (SkillLink) *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _fileTile('CNIC front', _cnicFront, _pickCnicFront),
                      _fileTile('CNIC back', _cnicBack, _pickCnicBack),
                      if (_labourWorker) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Services you offer *',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _labourServicesLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              )
                            : _labourServicesError != null
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber,
                                          size: 20,
                                          color: Colors.orange.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _labourServicesError!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.orange.shade800,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _loadLabourServices,
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  )
                                : DropdownSearch<SkillItem>.multiSelection(
                                    key: ValueKey(
                                      'labour_svc_${_labourServiceCatalog.length}',
                                    ),
                                    items: _labourServiceCatalog,
                                    selectedItems: _labourSelectedServices,
                                    onChanged: (v) => setState(
                                      () => _labourSelectedServices = v,
                                    ),
                                    itemAsString: (s) => s.name,
                                    compareFn: (a, b) => a.id == b.id,
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration:
                                          _inputDecoration(
                                        'Select one or more services',
                                      ),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? 'Select at least one'
                                        : null,
                                  ),
                      ],
                    ],
                    if (!_labour) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Offering skills *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _skillsLoading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : _skillsError != null
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber,
                                        size: 20,
                                        color: Colors.orange.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _skillsError!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.orange.shade800,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _loadSkills,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                )
                              : DropdownSearch<SkillItem>.multiSelection(
                                  key: ValueKey(
                                    'offering_${_skillsCache?.length ?? 0}',
                                  ),
                                  items: _skillsCache ?? [],
                                  selectedItems: _offeringSkills,
                                  onChanged: (v) =>
                                      setState(() => _offeringSkills = v),
                                  itemAsString: (s) => s.name,
                                  compareFn: (a, b) => a.id == b.id,
                                  dropdownDecoratorProps:
                                      DropDownDecoratorProps(
                                    dropdownSearchDecoration: _inputDecoration(
                                      'Select at least one',
                                    ),
                                  ),
                                  validator: (v) => (v == null || v.isEmpty)
                                      ? 'Select at least one'
                                      : null,
                                ),
                      if (!_skillsLoading && _skillsError == null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Learning skills *',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownSearch<SkillItem>.multiSelection(
                          key: ValueKey(
                            'learning_${_skillsCache?.length ?? 0}',
                          ),
                          items: _skillsCache ?? [],
                          selectedItems: _learningSkills,
                          onChanged: (v) =>
                              setState(() => _learningSkills = v),
                          itemAsString: (s) => s.name,
                          compareFn: (a, b) => a.id == b.id,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: _inputDecoration(
                              'Select at least one',
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Select at least one'
                              : null,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _field(
                        controller: _educationController,
                        label: 'Education',
                      ),
                    ],
                    if (!_labour || _labourWorker)
                      _field(
                        controller: _pastExperienceController,
                        label: 'Past experience',
                        maxLines: 2,
                      ),
                    const SizedBox(height: 12),
                    _fileTile('Profile photo', _profilePic, _pickProfileImage),
                    if (!_labour) ...[
                      _fileTile('Portfolio', _portfolio, _pickPortfolio),
                      _fileTile('Resume', _resume, _pickResume),
                      const SizedBox(height: 12),
                      const Text(
                        'Certificates',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _pickCertificates,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.workspace_premium_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _certificates.isEmpty
                                        ? 'Tap to add certificates'
                                        : '${_certificates.length} certificate(s) selected',
                                    style: TextStyle(
                                      color: _certificates.isEmpty
                                          ? Colors.grey.shade600
                                          : Colors.black87,
                                      fontWeight: _certificates.isEmpty
                                          ? FontWeight.normal
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_certificates.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _certificates.map((f) {
                            final name =
                                f.path.split(RegExp(r'[/\\]')).last;
                            return Chip(
                              label: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              onDeleted: () => _removeCertificate(f),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Create account',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
                ),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(label),
        validator: validator,
      ),
    );
  }

  Widget _fileTile(String label, File? file, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        subtitle: Text(
          file != null
              ? file.path.split(RegExp(r'[/\\]')).last
              : 'Not selected',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: TextButton(
          onPressed: onTap,
          child: Text(file == null ? 'Pick' : 'Change'),
        ),
      ),
    );
  }
}
