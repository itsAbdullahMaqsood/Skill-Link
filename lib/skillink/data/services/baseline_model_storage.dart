import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:skilllink/skillink/data/services/baseline_anomaly_detector.dart';

class BaselineModelStorage {
  static const _key = 'iot.baseline_model.v1';

  Future<BaselineModel?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return BaselineModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(BaselineModel m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(m.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
