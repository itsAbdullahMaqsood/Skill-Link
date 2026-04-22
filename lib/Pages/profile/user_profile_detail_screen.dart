import 'package:flutter/material.dart';
import 'package:skilllink/Pages/chat/chat_page.dart';
import 'package:skilllink/Pages/profile/skillchain_user_profile_screen.dart';
import 'package:skilllink/core/network/api_exception.dart';
import 'package:skilllink/models/user.dart';
import 'package:skilllink/services/auth_service.dart';
import 'package:skilllink/services/user_profile_service.dart';

void openUserProfileDetail(BuildContext context, String userId) {
  if (userId.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile unavailable')),
    );
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => UserProfileDetailScreen(userId: userId.trim()),
    ),
  );
}

class UserProfileDetailScreen extends StatefulWidget {
  final String userId;

  const UserProfileDetailScreen({super.key, required this.userId});

  @override
  State<UserProfileDetailScreen> createState() => _UserProfileDetailScreenState();
}

class _UserProfileDetailScreenState extends State<UserProfileDetailScreen> {
  final UserProfileService _service = UserProfileService();
  final Future<bool> _labourSessionFuture = AuthService().isLabourBackend();

  UserModel? _user;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId.trim().isEmpty) {
      _loading = false;
      _error = ApiException(message: 'Missing user id');
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _user = null;
    });
    try {
      final user = await _service.fetchPublicProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _user?.fullName.isNotEmpty == true ? _user!.fullName : 'Profile';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      final message = _error is ApiException
          ? (_error as ApiException).message
          : 'Something went wrong';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 48, color: Colors.grey.shade500),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: widget.userId.trim().isEmpty ? null : _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final user = _user!;
    return FutureBuilder<bool>(
      future: _labourSessionFuture,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final labour = snap.data!;
        return RefreshIndicator(
          onRefresh: _load,
          child: SkillchainUserProfileLayout(
            user: user,
            isLabourSession: labour,
            isOwnProfile: false,
            showLabourCnicSection: false,
            belowStatsActions: _PublicProfileActions(user: user),
          ),
        );
      },
    );
  }
}

class _PublicProfileActions extends StatelessWidget {
  final UserModel user;

  const _PublicProfileActions({required this.user});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _toast(context, 'Skill exchange request — coming soon'),
          icon: const Icon(Icons.swap_horiz_rounded, size: 20),
          label: const Text('Request exchange'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            if (user.id.trim().isEmpty) {
              _toast(context, 'Messaging unavailable for this profile');
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ChatScreen(
                  chatUserId: user.id,
                  chatUserName: user.fullName,
                  chatUserAvatar: user.profilePic ?? '',
                ),
              ),
            );
          },
          icon: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey.shade800),
          label: Text(
            'Message',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.grey.shade900,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _toast(context, 'Saved to your list — coming soon'),
                icon: Icon(Icons.bookmark_add_outlined, size: 18, color: Colors.grey.shade800),
                label: Text(
                  'Save',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey.shade900,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton.icon(
                onPressed: () => _toast(context, 'Share — coming soon'),
                icon: Icon(Icons.share_outlined, size: 18, color: Colors.blue.shade700),
                label: Text(
                  'Share',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
