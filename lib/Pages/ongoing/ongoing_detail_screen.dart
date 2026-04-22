import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skilllink/Pages/chat/chat_page.dart';
import 'package:skilllink/Pages/profile/user_profile_detail_screen.dart';
import 'package:skilllink/Widgets/user_avatar.dart';
import 'package:skilllink/models/ongoing_post.dart';

class OngoingDetailScreen extends StatefulWidget {
  final OngoingPost post;

  const OngoingDetailScreen({super.key, required this.post});

  @override
  State<OngoingDetailScreen> createState() => _OngoingDetailScreenState();
}

class _OngoingDetailScreenState extends State<OngoingDetailScreen> {
  late OngoingPost _post = widget.post;

  bool get _isOwner => _post.isOwner;

  Future<void> _markCompleted() async {
    final confirmed = await _confirmDialog(
      title: 'Mark as completed?',
      body:
          'Use this when the skill exchange or service is fulfilled.\n\n'
          'Note: this updates the screen only — backend sync is not yet wired up.',
      confirmText: 'Mark completed',
      confirmColor: Colors.blue.shade600,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _post = _post.copyWith(status: 'completed'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marked as completed (local only)')),
    );
  }

  Future<void> _remove() async {
    final confirmed = await _confirmDialog(
      title: 'Remove from this list?',
      body:
          'This only hides the engagement on this device for now — '
          'it will reappear when the screen reloads from the server.',
      confirmText: 'Remove',
      confirmColor: Colors.red.shade600,
    );
    if (confirmed != true || !mounted) return;
    Navigator.pop(context);
  }

  Future<bool?> _confirmDialog({
    required String title,
    required String body,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Dismiss'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _post;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('Engagement details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _statusBadge(p.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isOwner
                        ? 'You accepted this bid'
                        : 'Your bid was accepted',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (p.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      p.description,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        height: 1.5,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _card(child: _counterpartyRow(p)),
            const SizedBox(height: 12),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Terms'),
                  const SizedBox(height: 8),
                  if (p.acceptedTimeCoins != null)
                    _kv('Timecoins', '${p.acceptedTimeCoins}'),
                  _kv('Offer type', p.offerType),
                  _kv('Request type', p.requestType),
                  if (p.expiryDate != null)
                    _kv('Expires',
                        DateFormat.yMMMd().format(p.expiryDate!)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _card(
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    p.bidAcceptedAt != null
                        ? 'Accepted ${DateFormat.yMMMd().add_jm().format(p.bidAcceptedAt!)}'
                        : 'Accepted recently',
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (p.otherUser?.id ?? '').trim().isEmpty
                      ? null
                      : () {
                          final other = p.otherUser!;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatUserId: other.id,
                                chatUserName: other.fullName,
                                chatUserAvatar: other.profilePicUrl ?? '',
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'complete') _markCompleted();
                  if (v == 'cancel') _remove();
                },
                itemBuilder: (_) => [
                  if (p.status.toLowerCase() != 'completed')
                    const PopupMenuItem(
                      value: 'complete',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Mark completed'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(Icons.more_horiz, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _counterpartyRow(OngoingPost p) {
    final other = p.otherUser;
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: other == null
              ? null
              : () => openUserProfileDetail(context, other.id),
          child: UserAvatar(
            imageRef: other?.profilePicUrl,
            radius: 26,
            backgroundColor: Colors.blue.shade50,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isOwner ? 'Bidder' : 'Poster',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                other?.fullName ?? '—',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (other != null)
          TextButton.icon(
            onPressed: () => openUserProfileDetail(context, other.id),
            icon: const Icon(Icons.person_outline, size: 16),
            label: const Text('Profile'),
          ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade700,
          letterSpacing: 0.5,
        ),
      );

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              k,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'completed':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        break;
      case 'cancelled':
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
        break;
      default:
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.isEmpty
            ? 'Active'
            : status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
