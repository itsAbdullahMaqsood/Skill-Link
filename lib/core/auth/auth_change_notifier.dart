import 'package:flutter/foundation.dart';

final ValueNotifier<int> authChangeNotifier = ValueNotifier<int>(0);

void bumpAuthChange() {
  authChangeNotifier.value = authChangeNotifier.value + 1;
}
