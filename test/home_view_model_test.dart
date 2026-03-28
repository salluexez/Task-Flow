import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/features/tasks/models/task_draft_model.dart';
import 'package:task_flow/features/tasks/models/task_model.dart';
import 'package:task_flow/features/tasks/models/task_status.dart';
import 'package:task_flow/features/tasks/repositories/task_repository.dart';
import 'package:task_flow/features/tasks/viewmodels/home_view_model.dart';

void main() {
  test('home view model filters tasks by search and status', () async {
    final repository = _MemoryRepository([
      _task(id: '1', title: 'Website Redesign', status: TaskStatus.inProgress),
      _task(id: '2', title: 'Backend Integration', status: TaskStatus.todo),
    ]);

    final viewModel = HomeViewModel(repository);
    await Future<void>.delayed(Duration.zero);
    await viewModel.loadTasks();

    viewModel.setSearchQuery('website');
    expect(viewModel.visibleTasks.map((task) => task.id), ['1']);

    viewModel.setSearchQuery('');
    viewModel.setStatusFilter(TaskStatus.todo);
    expect(viewModel.visibleTasks.map((task) => task.id), ['2']);
  });
}

class _MemoryRepository implements TaskRepository {
  _MemoryRepository(this._tasks);

  final List<TaskModel> _tasks;

  @override
  Future<void> clearDraft() async {}

  @override
  Future<TaskModel> createTask(TaskDraftModel draft) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<List<TaskModel>> fetchTasks() async => List.unmodifiable(_tasks);

  @override
  TaskDraftModel? loadDraft() => null;

  @override
  Future<void> saveDraft(TaskDraftModel draft) async {}

  @override
  Future<TaskModel> updateTask(String id, TaskDraftModel draft) async =>
      throw UnimplementedError();
}

TaskModel _task({
  required String id,
  required String title,
  TaskStatus status = TaskStatus.todo,
}) {
  final now = DateTime(2026, 10, 20);
  return TaskModel(
    id: id,
    title: title,
    description: '',
    dueDate: now,
    status: status,
    blockedByTaskId: null,
    createdAt: now,
    updatedAt: now,
  );
}
