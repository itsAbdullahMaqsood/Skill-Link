import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/data/repositories/chat_repository.dart';
import 'package:skilllink/skillink/domain/models/app_user.dart';
import 'package:skilllink/skillink/domain/models/user_role.dart';
import 'package:skilllink/skillink/domain/models/worker.dart';
import 'package:skilllink/skillink/routing/routes.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

class ChatEntry {
  const ChatEntry._();

  static Future<bool> openWithWorker(
    BuildContext context,
    WidgetRef ref, {
    required Worker worker,
  }) async {
    final me = ref.read(authViewModelProvider).user;
    if (me == null) {
      _toast(context, 'Sign in to message workers.');
      return false;
    }
    if (me.id == worker.id) {
      _toast(context, 'You cannot message yourself.');
      return false;
    }
    return _openAndPush(
      context,
      ref,
      OpenChatInput(
        viewerId: me.id,
        viewerName: me.name,
        viewerAvatar: me.avatarUrl,
        viewerRole: me.role,
        peerId: worker.id,
        peerName: worker.name,
        peerAvatar: worker.avatarUrl,
        peerRole: UserRole.worker,
      ),
    );
  }

  static Future<bool> openWithUser(
    BuildContext context,
    WidgetRef ref, {
    required AppUser peer,
  }) async {
    final me = ref.read(authViewModelProvider).user;
    if (me == null) {
      _toast(context, 'Sign in to send messages.');
      return false;
    }
    if (me.id == peer.id) {
      _toast(context, 'You cannot message yourself.');
      return false;
    }
    return _openAndPush(
      context,
      ref,
      OpenChatInput(
        viewerId: me.id,
        viewerName: me.name,
        viewerAvatar: me.avatarUrl,
        viewerRole: me.role,
        peerId: peer.id,
        peerName: peer.name,
        peerAvatar: peer.avatarUrl,
        peerRole: peer.role,
      ),
    );
  }

  static Future<bool> openWithPeer(
    BuildContext context,
    WidgetRef ref, {
    required String peerId,
    required String peerName,
    String? peerAvatar,
    required UserRole peerRole,
  }) async {
    final me = ref.read(authViewModelProvider).user;
    if (me == null) {
      _toast(context, 'Sign in to send messages.');
      return false;
    }
    if (me.id == peerId) {
      _toast(context, 'You cannot message yourself.');
      return false;
    }
    return _openAndPush(
      context,
      ref,
      OpenChatInput(
        viewerId: me.id,
        viewerName: me.name,
        viewerAvatar: me.avatarUrl,
        viewerRole: me.role,
        peerId: peerId,
        peerName: peerName,
        peerAvatar: peerAvatar,
        peerRole: peerRole,
      ),
    );
  }

  static Future<bool> _openAndPush(
    BuildContext context,
    WidgetRef ref,
    OpenChatInput input,
  ) async {
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.openChat(input);
    if (!context.mounted) return false;
    return res.when(
      success: (opened) {
        context.push(Routes.chatThread(opened.chatId));
        return true;
      },
      failure: (msg, _) {
        _toast(context, msg);
        return false;
      },
    );
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
