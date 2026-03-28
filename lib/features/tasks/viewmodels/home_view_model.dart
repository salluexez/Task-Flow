import 'package:flutter/foundation.dart';

import '../models/task_draft_model.dart';
import '../models/task_model.dart';
import '../models/task_status.dart';
import '../repositories/task_repository.dart';
import '../utils/task_dependency_utils.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repository) {
    loadTasks();
  }

  final TaskRepository _repository;

  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  TaskStatus? _statusFilter;
  List<TaskModel> _tasks = const [];
  bool _isMutating = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
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
    _searchQuery = value;
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? value) {
    _statusFilter = value;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _isMutating = true;
    notifyListeners();
    await _repository.deleteTask(id);
    await loadTasks();
    _isMutating = false;
    notifyListeners();
  }

  Future<void> markTaskDone(TaskModel task) async {
    _isMutating = true;
    notifyListeners();
    await _repository.updateTask(
      task.id,
      TaskDraftModel.fromTask(task).copyWith(status: TaskStatus.done),
    );
    await loadTasks();
    _isMutating = false;
    notifyListeners();
  }

  Future<TaskSwipeOutcome> handleLeftSwipe(TaskModel task) async {
    if (isBlocked(task)) {
      return TaskSwipeOutcome.blocked;
    }

    _isMutating = true;
    notifyListeners();

    try {
      switch (task.status) {
        case TaskStatus.todo:
          await _repository.updateTask(
            task.id,
            TaskDraftModel.fromTask(
              task,
            ).copyWith(status: TaskStatus.inProgress),
          );
          await loadTasks();
          return TaskSwipeOutcome.movedToInProgress;
        case TaskStatus.inProgress:
          await _repository.updateTask(
            task.id,
            TaskDraftModel.fromTask(task).copyWith(status: TaskStatus.done),
          );
          await loadTasks();
          return TaskSwipeOutcome.movedToDone;
        case TaskStatus.done:
          await _repository.deleteTask(task.id);
          await loadTasks();
          return TaskSwipeOutcome.deleted;
      }
    } finally {
      _isMutating = false;
      notifyListeners();
    }
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
