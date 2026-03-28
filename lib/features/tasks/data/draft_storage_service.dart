import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_draft_model.dart';

class DraftStorageService {
  DraftStorageService(this._preferences);

  static const String _draftKey = 'task_flow_create_draft';

  final SharedPreferences _preferences;

  static Future<DraftStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return DraftStorageService(preferences);
  }

  Future<void> save(TaskDraftModel draft) async {
    await _preferences.setString(_draftKey, jsonEncode(draft.toJson()));
  }

  TaskDraftModel? load() {
    final raw = _preferences.getString(_draftKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return TaskDraftModel.fromJson(decoded);
  }

  Future<void> clear() async {
    await _preferences.remove(_draftKey);
  }
}
