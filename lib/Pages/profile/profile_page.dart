import 'package:flutter/material.dart';
import 'package:skilllink/models/user.dart';
import 'package:skilllink/Pages/profile/skillchain_user_profile_screen.dart';
import 'package:skilllink/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final bool isCurrentUser;
  final ValueChanged<UserModel>? onProfileUpdated;

  final Future<void> Function()? onRefresh;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.isCurrentUser,
    this.onProfileUpdated,
    this.onRefresh,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserModel _currentUser;
  final Future<bool> _labourSessionFuture = AuthService().isLabourBackend();

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _currentUser = widget.user;
    }
  }

  void _updateProfile(UserModel updatedUser) {
    setState(() {
      _currentUser = updatedUser;
    });
    widget.onProfileUpdated?.call(updatedUser);
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: FutureBuilder<bool>(
        future: _labourSessionFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final labour = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SkillchainUserProfileLayout(
              user: _currentUser,
              isLabourSession: labour,
              isOwnProfile: widget.isCurrentUser,
              onProfileUpdated: widget.isCurrentUser ? _updateProfile : null,
            ),
          );
        },
      ),
    );
  }
}
