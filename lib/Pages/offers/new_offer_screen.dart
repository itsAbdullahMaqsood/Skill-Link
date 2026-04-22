import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/create_post_models.dart';
import 'package:skilllink/models/signup_models.dart';
import 'package:skilllink/services/signup_api_service.dart';
import 'package:skilllink/services/skill_post_service.dart';

class NewOfferScreen extends StatefulWidget {
  const NewOfferScreen({super.key});

  @override
  State<NewOfferScreen> createState() => _NewOfferScreenState();
}

class _NewOfferScreenState extends State<NewOfferScreen> {
  int _step = 1;
  CreatePostState _state = CreatePostState();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseOutlineController = TextEditingController();
  final _offerTimeCoinsController = TextEditingController();
  final _requestTimeCoinsController = TextEditingController();
  final _offerCourseMinutesController = TextEditingController();
  final _requestCourseMinutesController = TextEditingController();

  final _signupApi = SignupApiService();
  final _skillPostService = SkillPostService();

  List<SkillItem>? _skillsCache;
  bool _skillsLoading = true;
  String? _skillsError;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseOutlineController.dispose();
    _offerTimeCoinsController.dispose();
    _requestTimeCoinsController.dispose();
    _offerCourseMinutesController.dispose();
    _requestCourseMinutesController.dispose();
    super.dispose();
  }

  Future<void> _loadSkills() async {
    if (_skillsCache != null && !_skillsLoading) return;
    if (mounted) setState(() => _skillsLoading = true);
    try {
      final list = await _signupApi.getSkills();
      if (mounted) {
        setState(() {
          _skillsCache = list;
          _skillsLoading = false;
          _skillsError = list.isEmpty ? 'No skills available' : null;
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

  void _syncControllersFromState() {
    _titleController.text = _state.title;
    _descriptionController.text = _state.description;
    _courseOutlineController.text = _state.courseOutline;
    _offerTimeCoinsController.text = _state.offerTimeCoins?.toString() ?? '';
    _requestTimeCoinsController.text =
        _state.requestTimeCoins?.toString() ?? '';
    _offerCourseMinutesController.text =
        _state.offerCourseTotalMinutes?.toString() ?? '';
    _requestCourseMinutesController.text =
        _state.requestCourseTotalMinutes?.toString() ?? '';
  }

  void _syncStateFromControllers() {
    _state = _state.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      courseOutline: _courseOutlineController.text.trim(),
      offerTimeCoins: int.tryParse(_offerTimeCoinsController.text.trim()),
      requestTimeCoins: int.tryParse(_requestTimeCoinsController.text.trim()),
      offerCourseTotalMinutes: int.tryParse(
        _offerCourseMinutesController.text.trim(),
      ),
      requestCourseTotalMinutes: int.tryParse(
        _requestCourseMinutesController.text.trim(),
      ),
    );
  }

  void _onOfferAssetChanged(PostAssetType? value) {
    if (value == null) return;
    PostAssetType newRequest = _state.requestAsset;
    if (value == PostAssetType.timecoin) {
      newRequest = PostAssetType.skill;
    }
    setState(() {
      _state = _state.copyWith(offerAsset: value, requestAsset: newRequest);
    });
  }

  void _onRequestAssetChanged(PostAssetType? value) {
    if (value == null) return;
    PostAssetType newOffer = _state.offerAsset;
    if (value == PostAssetType.timecoin) {
      newOffer = PostAssetType.skill;
    }
    setState(() {
      _state = _state.copyWith(offerAsset: newOffer, requestAsset: value);
    });
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{
      'title': _state.title,
      'description': _state.description,
      'offer_type': _state.offerAsset.apiValue,
      'request_type': _state.requestAsset.apiValue,
    };
    if (_state.expiryDate != null) {
      payload['expiry_date'] = DateFormat(
        'yyyy-MM-dd',
      ).format(_state.expiryDate!);
    }

    final offer = <String, dynamic>{'asset_type': _state.offerAsset.apiValue};
    final request = <String, dynamic>{
      'asset_type': _state.requestAsset.apiValue,
    };

    switch (_state.offerAsset) {
      case PostAssetType.skill:
        offer['skill_ids'] = _state.offerSkillIds;
        offer['course_total_minutes'] = _state.offerCourseTotalMinutes!;
        offer['course_outline'] = _state.courseOutline;
        break;
      case PostAssetType.timecoin:
        offer['time_coins'] = _state.offerTimeCoins!;
        break;
    }

    switch (_state.requestAsset) {
      case PostAssetType.skill:
        request['skill_ids'] = _state.requestSkillIds;
        request['desired_duration_minutes'] = _state.requestCourseTotalMinutes!;
        break;
      case PostAssetType.timecoin:
        request['time_coins'] = _state.requestTimeCoins!;
        break;
    }

    payload['offer'] = offer;
    payload['request'] = request;
    return payload;
  }

  String? _validateStep2() {
    if (_state.title.isEmpty) return 'Title is required';
    if (_state.description.isEmpty) return 'Description is required';
    if (_state.offerAsset == PostAssetType.skill) {
      if (_state.offerSkillIds.isEmpty)
        return 'Select at least one skill you offer';
      if (_state.offerCourseTotalMinutes == null ||
          _state.offerCourseTotalMinutes! <= 0) {
        return 'Course duration (minutes) must be greater than 0';
      }
      if (_state.courseOutline.isEmpty) return 'Course outline is required';
    } else {
      if (_state.offerTimeCoins == null || _state.offerTimeCoins! <= 0) {
        return 'Timecoins offered must be greater than 0';
      }
    }
    if (_state.requestAsset == PostAssetType.skill) {
      if (_state.requestSkillIds.isEmpty)
        return 'Select at least one skill you need';
      if (_state.requestCourseTotalMinutes == null ||
          _state.requestCourseTotalMinutes! <= 0) {
        return 'Expected course duration (minutes) must be greater than 0';
      }
    } else {
      if (_state.requestTimeCoins == null || _state.requestTimeCoins! <= 0) {
        return 'Timecoins requested must be greater than 0';
      }
    }
    return null;
  }

  void _resetForm() {
    setState(() {
      _step = 1;
      _state = CreatePostState();
      _titleController.clear();
      _descriptionController.clear();
      _courseOutlineController.clear();
      _offerTimeCoinsController.clear();
      _requestTimeCoinsController.clear();
      _offerCourseMinutesController.clear();
      _requestCourseMinutesController.clear();
      _isSubmitting = false;
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    _syncStateFromControllers();
    if (_formKey.currentState?.validate() == false) {
      return;
    }
    final err = _validateStep2();
    if (err != null) {
      setState(() => _errorMessage = err);
      return;
    }
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final payload = _buildPayload();
      await _skillPostService.createPost(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _resetForm();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
          elevation: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  _step == 2
                      ? IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            _syncStateFromControllers();
                            setState(() => _step = 1);
                          },
                        )
                      : const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      _step == 1 ? 'Create Post' : 'Post Details',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: _step == 1 ? _buildStep1() : _buildStep2()),
      ],
    );
  }

  Widget _buildStep1() {
    final canNext = _state.canProceedToStep2;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'What are you offering?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _assetDropdown(
            value: _state.offerAsset,
            onChanged: _onOfferAssetChanged,
          ),
          const SizedBox(height: 24),
          Text(
            'What do you need?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _assetDropdown(
            value: _state.requestAsset,
            onChanged: _onRequestAssetChanged,
          ),
          const SizedBox(height: 16),
          if (_state.offerAsset == PostAssetType.timecoin &&
              _state.requestAsset == PostAssetType.timecoin)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'TIMECOIN → TIMECOIN is not allowed. The other field will be set to SKILL when you select TIMECOIN.',
                style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
              ),
            ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: canNext
                ? () {
                    setState(() => _step = 2);
                    _syncControllersFromState();
                  }
                : null,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _assetDropdown({
    required PostAssetType value,
    required void Function(PostAssetType?) onChanged,
  }) {
    return DropdownButtonFormField<PostAssetType>(
      value: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: PostAssetType.values
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e == PostAssetType.skill ? 'SKILL' : 'TIMECOIN'),
            ),
          )
          .toList(),
      onChanged: (v) => onChanged(v),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Looking for Python mentorship',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe what you offer or need...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Description is required'
                  : null,
            ),
            const SizedBox(height: 16),
            _buildExpiryField(),
            const SizedBox(height: 16),
            if (_state.offerAsset == PostAssetType.skill) ...[
              _buildOfferSkillsSection(),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: _offerCourseMinutesController,
                label: 'Course duration (minutes) *',
                hint: 'e.g., 60',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _buildCourseOutlineField(),
              const SizedBox(height: 16),
            ],
            if (_state.offerAsset == PostAssetType.timecoin) ...[
              _buildNumberField(
                controller: _offerTimeCoinsController,
                label: 'Timecoins offered *',
                hint: 'e.g., 10',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
            ],
            if (_state.requestAsset == PostAssetType.skill) ...[
              _buildRequestSkillsSection(),
              const SizedBox(height: 16),
              _buildNumberField(
                controller: _requestCourseMinutesController,
                label: 'Requested course duration (minutes) *',
                hint: 'e.g., 45',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
            ],
            if (_state.requestAsset == PostAssetType.timecoin) ...[
              _buildNumberField(
                controller: _requestTimeCoinsController,
                label: 'Timecoins requested *',
                hint: 'e.g., 8',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton(
                onPressed: _submit,
                child: const Text('Create Post'),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiryField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate:
              _state.expiryDate ?? DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null && mounted) {
          setState(() => _state = _state.copyWith(expiryDate: date));
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Expiry date (optional)',
          border: OutlineInputBorder(),
        ),
        child: Text(
          _state.expiryDate != null
              ? DateFormat('yyyy-MM-dd').format(_state.expiryDate!)
              : 'Select date',
          style: TextStyle(
            color: _state.expiryDate != null
                ? Colors.black87
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildOfferSkillsSection() {
    return _buildSkillMultiSelect(
      label: 'Skills you offer *',
      selectedIds: _state.offerSkillIds,
      onChanged: (ids) =>
          setState(() => _state = _state.copyWith(offerSkillIds: ids)),
    );
  }

  Widget _buildRequestSkillsSection() {
    return _buildSkillMultiSelect(
      label: 'Skills you need *',
      selectedIds: _state.requestSkillIds,
      onChanged: (ids) =>
          setState(() => _state = _state.copyWith(requestSkillIds: ids)),
    );
  }

  Widget _buildSkillMultiSelect({
    required String label,
    required List<String> selectedIds,
    required void Function(List<String>) onChanged,
  }) {
    if (_skillsLoading) {
      return const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_skillsError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                size: 20,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(_skillsError!)),
              TextButton(onPressed: _loadSkills, child: const Text('Retry')),
            ],
          ),
        ],
      );
    }
    final items = _skillsCache ?? [];
    final selected = items.where((s) => selectedIds.contains(s.id)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownSearch<SkillItem>.multiSelection(
          items: items,
          selectedItems: selected,
          onChanged: (v) => onChanged(v.map((e) => e.id).toList()),
          itemAsString: (s) => s.name,
          compareFn: (a, b) => a.id == b.id,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: 'Select skills',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseOutlineField() {
    return TextFormField(
      controller: _courseOutlineController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Course outline *',
        hintText: 'Outline the topics covered...',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      onChanged: (_) => setState(() {}),
      validator: (v) {
        if (_state.offerAsset != PostAssetType.skill) return null;
        return (v == null || v.trim().isEmpty)
            ? 'Course outline is required when offering a skill'
            : null;
      },
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
