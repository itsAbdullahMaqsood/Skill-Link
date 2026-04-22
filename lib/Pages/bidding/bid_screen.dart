import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/skill_post.dart';
import 'package:skilllink/services/skill_post_service.dart';

class BidScreen extends StatefulWidget {
  final SkillPost post;

  const BidScreen({super.key, required this.post});

  @override
  State<BidScreen> createState() => _BidScreenState();
}

class _BidScreenState extends State<BidScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _offerDurationController;
  late final TextEditingController _requestDurationController;
  late final TextEditingController _timeCoinsController;
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

  bool get _isOfferSkill => widget.post.offerType.toUpperCase() == 'SKILL';
  bool get _isRequestSkill => widget.post.requestType.toUpperCase() == 'SKILL';
  bool get _isSkillExchange => _isOfferSkill && _isRequestSkill;

  @override
  void initState() {
    super.initState();
    _offerDurationController = TextEditingController(
      text: widget.post.courseTotalMinutes?.toString() ?? '',
    );
    _requestDurationController = TextEditingController(
      text: widget.post.desiredDurationMinutes?.toString() ?? '',
    );

    final tc = widget.post.offerTimeCoins ?? widget.post.requestTimeCoins;
    _timeCoinsController = TextEditingController(
      text: tc?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _offerDurationController.dispose();
    _requestDurationController.dispose();
    _timeCoinsController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Place a Bid'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostSummary(),
              const SizedBox(height: 24),
              _buildBidFormSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostSummary() {
    final post = widget.post;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article_outlined, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Post Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (post.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              post.description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'by ${post.name}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            label: 'OFFERS',
            color: Colors.green.shade700,
            bgColor: Colors.green.shade50,
            icon: Icons.arrow_upward,
            child: _isOfferSkill
                ? _summarySkillContent(
                    skills: post.offers,
                    duration: post.courseTotalMinutes,
                    color: Colors.green.shade700,
                  )
                : _summaryTimecoinContent(
                    timeCoins: post.offerTimeCoins,
                    color: Colors.green.shade700,
                  ),
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            label: 'NEEDS',
            color: Colors.purple.shade700,
            bgColor: Colors.purple.shade50,
            icon: Icons.check_circle,
            child: _isRequestSkill
                ? _summarySkillContent(
                    skills: post.needs,
                    duration: post.desiredDurationMinutes,
                    color: Colors.purple.shade700,
                  )
                : _summaryTimecoinContent(
                    timeCoins: post.requestTimeCoins,
                    color: Colors.purple.shade700,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required Color color,
    required Color bgColor,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _summarySkillContent({
    required List<String> skills,
    int? duration,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (skills.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: skills
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(s, style: TextStyle(fontSize: 11, color: color)),
                    ))
                .toList(),
          ),
        if (duration != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                _formatDuration(duration),
                style: TextStyle(fontSize: 11, color: color),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _summaryTimecoinContent({int? timeCoins, required Color color}) {
    return Row(
      children: [
        SvgPicture.asset('assets/images/timecoin.svg', width: 16, height: 16),
        const SizedBox(width: 6),
        Text(
          '${timeCoins ?? 0} TimeCoins',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  Widget _buildBidFormSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, size: 18, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Your Bid',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Propose different terms for this exchange.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          ..._buildConditionalFields(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Message (optional)',
              hintText: 'Explain your proposal...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConditionalFields() {
    if (_isSkillExchange) {
      return [
        _durationField(
          controller: _offerDurationController,
          label: 'Proposed Offer Duration (minutes)',
        ),
        const SizedBox(height: 14),
        _durationField(
          controller: _requestDurationController,
          label: 'Proposed Request Duration (minutes)',
        ),
      ];
    }

    if (_isOfferSkill) {
      return [
        _durationField(
          controller: _offerDurationController,
          label: 'Proposed Offer Duration (minutes)',
        ),
        const SizedBox(height: 14),
        _timeCoinsField(),
      ];
    }

    return [
      _timeCoinsField(),
      const SizedBox(height: 14),
      _durationField(
        controller: _requestDurationController,
        label: 'Proposed Request Duration (minutes)',
      ),
    ];
  }

  Widget _durationField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.timer_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Duration is required';
        final n = int.tryParse(v);
        if (n == null || n <= 0) return 'Must be greater than 0';
        return null;
      },
    );
  }

  Widget _timeCoinsField() {
    return TextFormField(
      controller: _timeCoinsController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Proposed TimeCoins',
        suffixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset('assets/images/timecoin.svg', width: 20, height: 20),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'TimeCoins amount is required';
        final n = int.tryParse(v);
        if (n == null || n <= 0) return 'Must be greater than 0';
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gavel, size: 18),
                  SizedBox(width: 8),
                  Text('Place Bid', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final payload = _buildPayload();

    try {
      final result = await SkillPostService().placeBid(
        postId: widget.post.id,
        payload: payload,
      );

      if (!mounted) return;

      final msg = (result['message'] as String?) ?? 'Bid placed successfully';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{};

    final msg = _messageController.text.trim();
    if (msg.isNotEmpty) payload['message'] = msg;

    if (_isSkillExchange) {
      payload['proposed_timeline'] =
          int.tryParse(_offerDurationController.text) ?? 0;
      payload['course_timeline'] =
          int.tryParse(_requestDurationController.text) ?? 0;
    } else if (_isOfferSkill) {
      payload['proposed_timeline'] =
          int.tryParse(_offerDurationController.text) ?? 0;
      payload['suggested_time_coins'] =
          int.tryParse(_timeCoinsController.text) ?? 0;
    } else {
      payload['suggested_time_coins'] =
          int.tryParse(_timeCoinsController.text) ?? 0;
      payload['course_timeline'] =
          int.tryParse(_requestDurationController.text) ?? 0;
    }

    return payload;
  }

  static String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }
}
