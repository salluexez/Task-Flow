import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_draft_model.dart';

class DraftStorageService {
  DraftStorageService(this._preferences);

  static const String _createDraftKey = 'task_flow_create_draft';

  final SharedPreferences _preferences;

  static Future<DraftStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return DraftStorageService(preferences);
  }

  Future<void> save(TaskDraftModel draft, {String? draftId}) async {
    await _preferences.setString(_draftKey(draftId), jsonEncode(draft.toJson()));
  }

  TaskDraftModel? load({String? draftId}) {
    final raw = _preferences.getString(_draftKey(draftId));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return TaskDraftModel.fromJson(decoded);
  }

  Future<void> clear({String? draftId}) async {
    await _preferences.remove(_draftKey(draftId));
  }

  String _draftKey(String? draftId) =>
      draftId == null ? _createDraftKey : 'task_flow_edit_draft_$draftId';
}
