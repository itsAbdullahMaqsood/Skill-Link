import 'package:flutter/material.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/services/skill_post_service.dart';

Future<bool?> showAcceptOfferDialog(
  BuildContext context, {
  required String postId,
  required String posterName,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _AcceptOfferDialog(
      postId: postId,
      posterName: posterName,
    ),
  );
}

class _AcceptOfferDialog extends StatefulWidget {
  final String postId;
  final String posterName;

  const _AcceptOfferDialog({
    required this.postId,
    required this.posterName,
  });

  @override
  State<_AcceptOfferDialog> createState() => _AcceptOfferDialogState();
}

class _AcceptOfferDialogState extends State<_AcceptOfferDialog> {
  final TextEditingController _comment = TextEditingController();
  final SkillPostService _service = SkillPostService();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _service.acceptOffer(
        postId: widget.postId,
        comment: _comment.text,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not accept the post. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Accept this post?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You\'re agreeing to all the offerings and needs of '
            '${widget.posterName}\'s post.',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13.5),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _comment,
            enabled: !_busy,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Optional note for the poster…',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline,
                      size: 16, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.green.shade600),
          onPressed: _busy ? null : _confirm,
          child: _busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text('Confirm'),
        ),
      ],
    );
  }
}
