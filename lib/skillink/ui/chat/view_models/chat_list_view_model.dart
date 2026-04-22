import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/data/providers.dart';
import 'package:skilllink/skillink/domain/models/chat_summary.dart';
import 'package:skilllink/skillink/ui/auth/view_models/auth_view_model.dart';

final chatListViewModelProvider =
    StreamProvider.autoDispose<List<ChatSummary>>((ref) {
  final me = ref.watch(authViewModelProvider).user?.id;
  if (me == null || me.isEmpty) {
    return const Stream<List<ChatSummary>>.empty();
  }
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchUserChats(me);
});
