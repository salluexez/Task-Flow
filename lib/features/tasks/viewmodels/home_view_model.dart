import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task_draft_model.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';
import '../repositories/task_repository.dart';
import '../utils/task_dependency_utils.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(
    this._repository, {
    Duration searchDebounceDuration = const Duration(milliseconds: 300),
  }) : _searchDebounceDuration = searchDebounceDuration {
    loadTasks();
  }

  final TaskRepository _repository;
  final Duration _searchDebounceDuration;

  bool _isLoading = true;
  String? _errorMessage;
  String _searchInput = '';
  String _searchQuery = '';
  TaskStatus? _statusFilter;
  List<TaskModel> _tasks = const [];
  bool _isMutating = false;
  Timer? _searchDebounceTimer;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchInput => _searchInput;
  String get searchQuery => _searchQuery;
  TaskStatus? get statusFilter => _statusFilter;
  bool get isMutating => _isMutating;
  List<TaskModel> get allTasks => List.unmodifiable(_tasks);

  Map<String, TaskModel> get tasksById => {
    for (final task in _tasks) task.id: task,
  };

  List<TaskModel> get visibleTasks {
    final query = _searchQuery.trim().toLowerCase();
    return _tasks.where((task) {
      final matchesQuery =
          query.isEmpty || task.title.toLowerCase().contains(query);
      final matchesStatus =
          _statusFilter == null || task.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
  }

  bool isBlocked(TaskModel task) =>
      TaskDependencyUtils.isTaskBlocked(task, tasksById);

  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _repository.fetchTasks();
    } catch (_) {
      _errorMessage = 'Something went wrong while loading your tasks.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchInput = value;
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounceDuration, () {
      _searchQuery = value;
      notifyListeners();
    });
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _runMutation(() async {
      await _repository.deleteTask(id);
      await _refreshTasksAfterMutation();
    });
  }

  Future<bool> markTaskDone(TaskModel task) async {
    if (isBlocked(task)) {
      return false;
    }

    await _runMutation(() async {
      await _repository.updateTask(
        task.id,
        TaskDraftModel.fromTask(task).copyWith(status: TaskStatus.done),
      );
      await _refreshTasksAfterMutation();
    });
    return true;
  }

  Future<TaskSwipeOutcome> handleLeftSwipe(TaskModel task) async {
    if (isBlocked(task)) {
      return TaskSwipeOutcome.blocked;
    }

    switch (task.status) {
      case TaskStatus.todo:
        await _runMutation(() async {
          await _repository.updateTask(
            task.id,
            TaskDraftModel.fromTask(
              task,
            ).copyWith(status: TaskStatus.inProgress),
          );
          await _refreshTasksAfterMutation();
        });
        return TaskSwipeOutcome.movedToInProgress;
      case TaskStatus.inProgress:
        await _runMutation(() async {
          await _repository.updateTask(
            task.id,
            TaskDraftModel.fromTask(task).copyWith(status: TaskStatus.done),
          );
          await _refreshTasksAfterMutation();
        });
        return TaskSwipeOutcome.movedToDone;
      case TaskStatus.done:
        await _runMutation(() async {
          await _repository.deleteTask(task.id);
          await _refreshTasksAfterMutation();
        });
        return TaskSwipeOutcome.deleted;
    }
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    _isMutating = true;
    notifyListeners();
    try {
      await action();
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<void> _refreshTasksAfterMutation() async {
    try {
      _tasks = await _repository.fetchTasks();
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading your tasks.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}

enum TaskSwipeOutcome { blocked, movedToInProgress, movedToDone, deleted }

extension on TaskDraftModel {
  TaskDraftModel copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    Object? blockedByTaskId = _draftSentinel,
  }) {
    return TaskDraftModel(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedByTaskId: blockedByTaskId == _draftSentinel
          ? this.blockedByTaskId
          : blockedByTaskId as String?,
    );
  }
}

const Object _draftSentinel = Object();
