import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task_draft_model.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';
import '../repositories/task_repository.dart';
import '../utils/task_dependency_utils.dart';

class TaskFormViewModel extends ChangeNotifier {
  TaskFormViewModel({
    required TaskRepository repository,
    required List<TaskModel> allTasks,
    this.existingTask,
  }) : _repository = repository,
       _allTasks = allTasks {
    if (existingTask != null) {
      _applyDraft(TaskDraftModel.fromTask(existingTask!));
      _isInitializing = false;
    } else {
      unawaited(initialize());
    }
  }

  final TaskRepository _repository;
  final TaskModel? existingTask;
  List<TaskModel> _allTasks;

  String _title = '';
  String _description = '';
  DateTime? _dueDate;
  TaskStatus _status = TaskStatus.todo;
  String? _blockedByTaskId;
  bool _isSaving = false;
  bool _isInitializing = true;
  String? _errorMessage;
  Map<String, String> _fieldErrors = const {};

  bool get isEditMode => existingTask != null;
  bool get isSaving => _isSaving;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  String get title => _title;
  String get description => _description;
  DateTime? get dueDate => _dueDate;
  TaskStatus get status => _status;
  String? get blockedByTaskId => _blockedByTaskId;
  Map<String, String> get fieldErrors => _fieldErrors;

  Future<void> initialize() async {
    if (isEditMode) {
      return;
    }

    final draft = _repository.loadDraft();
    if (draft != null) {
      _applyDraft(draft);
    }
    _isInitializing = false;
    notifyListeners();
  }

  void updateAvailableTasks(List<TaskModel> tasks) {
    _allTasks = tasks;
    notifyListeners();
  }

  List<TaskModel> get availableBlockers {
    final tasksById = {for (final task in _allTasks) task.id: task};

    return _allTasks.where((task) {
      if (task.id == existingTask?.id) {
        return false;
      }
      if (existingTask == null) {
        return true;
      }
      return !TaskDependencyUtils.wouldCreateCycle(
        sourceTaskId: existingTask!.id,
        proposedBlockedByTaskId: task.id,
        tasksById: tasksById,
      );
    }).toList()..sort((left, right) => left.title.compareTo(right.title));
  }

  void updateTitle(String value) {
    _title = value;
    _clearFieldError('title');
    _persistDraft();
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    _clearFieldError('description');
    _persistDraft();
    notifyListeners();
  }

  void updateDueDate(DateTime value) {
    _dueDate = DateTime(value.year, value.month, value.day);
    _clearFieldError('dueDate');
    _persistDraft();
    notifyListeners();
  }

  void updateStatus(TaskStatus value) {
    _status = value;
    _clearFieldError('status');
    notifyListeners();
  }

  void updateBlockedByTask(String? value) {
    _blockedByTaskId = value;
    notifyListeners();
  }

  Future<TaskModel?> save() async {
    if (_isSaving) {
      return null;
    }
    if (!_validate()) {
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final draft = TaskDraftModel(
      title: _title.trim(),
      description: _description.trim(),
      dueDate: _dueDate,
      status: _status,
      blockedByTaskId: _blockedByTaskId,
    );

    try {
      final task = isEditMode
          ? await _repository.updateTask(existingTask!.id, draft)
          : await _repository.createTask(draft);
      if (!isEditMode) {
        await _repository.clearDraft();
      }
      return task;
    } catch (_) {
      _errorMessage = 'We could not save your task. Please try again.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> discardDraft() async {
    if (isEditMode) {
      return;
    }
    await _repository.clearDraft();
  }

  void _applyDraft(TaskDraftModel draft) {
    _title = draft.title;
    _description = draft.description;
    _dueDate = draft.dueDate;
    _status = draft.status;
    _blockedByTaskId = draft.blockedByTaskId;
  }

  void _persistDraft() {
    if (isEditMode || _isInitializing) {
      return;
    }

    unawaited(
      _repository.saveDraft(
        TaskDraftModel(
          title: _title,
          description: _description,
          dueDate: _dueDate,
          status: _status,
          blockedByTaskId: _blockedByTaskId,
        ),
      ),
    );
  }

  bool _validate() {
    final errors = <String, String>{};

    if (_title.trim().isEmpty) {
      errors['title'] = 'Task title is required.';
    }
    if (_description.trim().isEmpty) {
      errors['description'] = 'Task description is required.';
    }
    if (_dueDate == null) {
      errors['dueDate'] = 'Due date is required.';
    }
    if (_blockedByTaskId != null && existingTask != null) {
      final tasksById = {for (final task in _allTasks) task.id: task};
      if (TaskDependencyUtils.wouldCreateCycle(
        sourceTaskId: existingTask!.id,
        proposedBlockedByTaskId: _blockedByTaskId,
        tasksById: tasksById,
      )) {
        errors['blockedBy'] = 'This dependency would create a cycle.';
      }
    }

    _fieldErrors = errors;
    return errors.isEmpty;
  }

  void _clearFieldError(String key) {
    if (!_fieldErrors.containsKey(key)) {
      return;
    }
    final next = Map<String, String>.from(_fieldErrors);
    next.remove(key);
    _fieldErrors = next;
  }
}
