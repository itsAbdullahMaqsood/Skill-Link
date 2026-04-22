import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilllink/Widgets/user_avatar.dart';
import 'package:image_picker/image_picker.dart';

import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/signup_models.dart';
import 'package:skilllink/models/user.dart';
import 'package:skilllink/router/app_router.dart' show skillTypePrefKey;
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/signup_api_service.dart';
import 'package:skilllink/services/user_profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onProfileUpdated;

  const EditProfilePage({
    super.key,
    required this.user,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _profileService = UserProfileService();
  final _authService = AuthService();
  final _signupApi = SignupApiService();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late TextEditingController _educationController;
  late TextEditingController _pastExperienceController;
  late TextEditingController _ageController;

  String? _selectedGender;
  File? _profilePic;
  File? _portfolio;
  File? _resume;
  List<File> _certificates = [];

  List<SkillItem> _offeringSkills = [];
  List<SkillItem> _learningSkills = [];
  List<SkillItem>? _skillsCache;
  bool _skillsLoading = true;
  String? _skillsError;

  bool _isSubmitting = false;
  bool _labour = false;

  String? get _profileDisplayUrl {
    if (_profilePic != null) return null;
    return widget.user.profileImageUrl.isNotEmpty
        ? widget.user.profileImageUrl
        : null;
  }

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneNumberController = TextEditingController(text: widget.user.phoneNumber);
    _locationController = TextEditingController(text: widget.user.location);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _educationController = TextEditingController(text: widget.user.education ?? '');
    _pastExperienceController =
        TextEditingController(text: widget.user.pastExperience ?? '');
    _ageController = TextEditingController(text: widget.user.age.toString());
    _selectedGender = widget.user.gender.isNotEmpty
        ? widget.user.gender
        : null;

    _initMode();
  }

  Future<void> _initMode() async {
    final p = await SharedPreferences.getInstance();
    final labour = p.getString(skillTypePrefKey) == 'labour';
    if (!mounted) return;
    setState(() {
      _labour = labour;
      if (labour) _skillsLoading = false;
    });
    if (!labour) _loadSkills();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _pastExperienceController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadSkills() async {
    if (_skillsCache != null && !_skillsLoading) return;
    setState(() {
      _skillsLoading = true;
      _skillsError = null;
    });
    try {
      final list = await _signupApi.getSkills();
      final idToSkill = <String, SkillItem>{};
      final nameToSkill = <String, SkillItem>{};
      for (final s in list) {
        idToSkill[s.id] = s;
        nameToSkill[s.name] = s;
      }
      final offering = widget.user.offeringSkills
          .map((val) => idToSkill[val] ?? nameToSkill[val])
          .whereType<SkillItem>()
          .toList();
      final learning = widget.user.learningSkills
          .map((val) => idToSkill[val] ?? nameToSkill[val])
          .whereType<SkillItem>()
          .toList();
      if (mounted) {
        setState(() {
          _skillsCache = list;
          _skillsLoading = false;
          _skillsError = list.isEmpty ? 'No skills available' : null;
          _offeringSkills = offering;
          _learningSkills = learning;
        });
      }
    } catch (_) {
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

  Future<void> _pickPortfolio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null &&
        result.files.single.path != null &&
        mounted) {
      setState(() => _portfolio = File(result.files.single.path!));
    }
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null &&
        result.files.single.path != null &&
        mounted) {
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

  Future<void> _saveProfile() async {
    final fullName = _fullNameController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final location = _locationController.text.trim();
    final ageVal = int.tryParse(_ageController.text.trim());

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (ageVal == null || ageVal < 1 || ageVal > 150) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid age (1–150)'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gender is required'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userMap = await _profileService.updateProfile(
        fullName: fullName,
        bio: _bioController.text.trim(),
        age: ageVal,
        gender: _selectedGender!,
        location: location,
        phoneNumber: phoneNumber,
        education: _educationController.text.trim(),
        offeringSkills: _offeringSkills.map((e) => e.id).toList(),
        learningSkills: _learningSkills.map((e) => e.id).toList(),
        pastExperience: _pastExperienceController.text.trim(),
        profilePic: _profilePic,
        resume: _resume,
        portfolio: _portfolio,
        certificates: _certificates,
        cnicFrontPath: widget.user.cnicFront,
        cnicBackPath: widget.user.cnicBack,
      );

      await _authService.saveUserData(userMap);
      final updatedUser = UserModel.fromJson(userMap);

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      widget.onProfileUpdated(updatedUser);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSubmitting ? null : _saveProfile,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    _profilePic != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: FileImage(_profilePic!),
                          )
                        : UserAvatar(
                            imageRef: _profileDisplayUrl,
                            radius: 60,
                            backgroundColor: Colors.grey.shade300,
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _pickProfileImage,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Change Photo'),
              ),
            ),
            const SizedBox(height: 24),

            _buildTextField(controller: _fullNameController, label: 'Full Name *', icon: Icons.person),
            const SizedBox(height: 16),
            _buildReadOnlyField(label: 'Email', value: widget.user.email, icon: Icons.email),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneNumberController,
              label: 'Phone Number *',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(controller: _locationController, label: 'Location *', icon: Icons.location_on),
            const SizedBox(height: 16),
            _buildTextField(controller: _bioController, label: 'Bio', icon: Icons.description, maxLines: 3),
            const SizedBox(height: 16),
            if (!_labour) ...[
              _buildTextField(
                  controller: _educationController,
                  label: 'Education',
                  icon: Icons.school),
              const SizedBox(height: 16),
            ],
            _buildTextField(
              controller: _pastExperienceController,
              label: 'Past Experience',
              icon: Icons.work,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _ageController,
                    label: 'Age *',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender *',
                      prefixIcon: Icon(Icons.people, color: Colors.blue.shade600),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (!_labour) ...[
              const Text(
                'Offering Skills',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _skillsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _skillsError != null
                      ? Row(
                          children: [
                            Icon(Icons.warning_amber,
                                color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_skillsError!)),
                            TextButton(
                              onPressed: _loadSkills,
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      : DropdownSearch<SkillItem>.multiSelection(
                          items: _skillsCache ?? [],
                          selectedItems: _offeringSkills,
                          onChanged: (v) => setState(() => _offeringSkills = v),
                          itemAsString: (s) => s.name,
                          compareFn: (a, b) => a.id == b.id,
                          dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: 'Select skills you offer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
              const SizedBox(height: 16),
              const Text(
                'Learning Skills',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              _skillsLoading
                  ? const SizedBox.shrink()
                  : DropdownSearch<SkillItem>.multiSelection(
                      items: _skillsCache ?? [],
                      selectedItems: _learningSkills,
                      onChanged: (v) => setState(() => _learningSkills = v),
                      itemAsString: (s) => s.name,
                      compareFn: (a, b) => a.id == b.id,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'Select skills you want to learn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              _fileTile('Portfolio', _portfolio, _pickPortfolio),
              const SizedBox(height: 12),
              _fileTile('Resume', _resume, _pickResume),
              const SizedBox(height: 16),
              const Text(
                'Certificates',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
                        Icon(Icons.workspace_premium_outlined,
                            color: Colors.grey.shade600),
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
                        Icon(Icons.add_circle_outline,
                            color: Colors.blue.shade600),
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
                    final name = f.path.split(RegExp(r'[/\\]')).last;
                    return Chip(
                      label: Text(name,
                          overflow: TextOverflow.ellipsis, maxLines: 1),
                      onDeleted: () => _removeCertificate(f),
                    );
                  }).toList(),
                ),
              ],
            ],
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      child: Text(value, style: TextStyle(color: Colors.grey.shade700)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _fileTile(String label, File? file, VoidCallback onPick) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.attach_file, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  file != null ? file.path.split(RegExp(r'[/\\]')).last : 'Tap to select $label',
                  style: TextStyle(
                    color: file != null ? Colors.black87 : Colors.grey.shade600,
                    fontWeight: file != null ? FontWeight.w500 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}
