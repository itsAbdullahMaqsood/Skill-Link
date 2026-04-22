import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skilllink/skillink/ui/completion_report/view_models/pending_completion_reports_view_model.dart';

final completionPromptBindingProvider = Provider<void>((ref) {
  ref.watch(pendingCompletionReportsProvider);
});
