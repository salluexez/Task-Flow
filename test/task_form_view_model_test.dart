import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/features/tasks/models/task_draft_model.dart';
import 'package:task_flow/features/tasks/models/task_model.dart';
import 'package:task_flow/features/tasks/models/task_status.dart';
import 'package:task_flow/features/tasks/repositories/task_repository.dart';
import 'package:task_flow/features/tasks/viewmodels/task_form_view_model.dart';

void main() {
  test('create mode restores saved draft', () async {
    final repository = _DraftRepository(
      draft: const TaskDraftModel(
        title: 'Draft title',
        description: 'Draft description',
        dueDate: null,
        status: TaskStatus.todo,
      ),
    );

    final viewModel = TaskFormViewModel(
      repository: repository,
      allTasks: const [],
    );
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.title, 'Draft title');
    expect(viewModel.description, 'Draft description');
  });

  test('edit mode does not restore create draft', () async {
    final repository = _DraftRepository(
      draft: const TaskDraftModel(
        title: 'Draft title',
        description: 'Draft description',
        dueDate: null,
        status: TaskStatus.todo,
      ),
    );
    final existingTask = _task(id: '1', title: 'Real task');

    final viewModel = TaskFormViewModel(
      repository: repository,
      allTasks: [existingTask],
      existingTask: existingTask,
    );

    expect(viewModel.title, 'Real task');
  });

  test('save prevents duplicate submit while request is running', () async {
    final repository = _SlowRepository();
    final viewModel = TaskFormViewModel(
      repository: repository,
      allTasks: const [],
    );

    await Future<void>.delayed(Duration.zero);
    viewModel.updateTitle('Task');
    viewModel.updateDescription('Description');
    viewModel.updateDueDate(DateTime(2026, 10, 21));

    final firstSave = viewModel.save();
    final secondSave = await viewModel.save();

    expect(secondSave, isNull);
    await firstSave;
    expect(repository.createCallCount, 1);
  });
}

class _DraftRepository implements TaskRepository {
  _DraftRepository({this.draft});

  final TaskDraftModel? draft;

  @override
  Future<void> clearDraft() async {}

  @override
  Future<TaskModel> createTask(TaskDraftModel draft) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<List<TaskModel>> fetchTasks() async => const [];

  @override
  TaskDraftModel? loadDraft() => draft;

  @override
  Future<void> saveDraft(TaskDraftModel draft) async {}

  @override
  Future<TaskModel> updateTask(String id, TaskDraftModel draft) async =>
      throw UnimplementedError();
}

class _SlowRepository implements TaskRepository {
  int createCallCount = 0;

  @override
  Future<void> clearDraft() async {}

  @override
  Future<TaskModel> createTask(TaskDraftModel draft) async {
    createCallCount++;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return _task(id: 'created', title: draft.title);
  }

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<List<TaskModel>> fetchTasks() async => const [];

  @override
  TaskDraftModel? loadDraft() => null;

  @override
  Future<void> saveDraft(TaskDraftModel draft) async {}

  @override
  Future<TaskModel> updateTask(String id, TaskDraftModel draft) async =>
      throw UnimplementedError();
}

TaskModel _task({required String id, required String title}) {
  final now = DateTime(2026, 10, 20);
  return TaskModel(
    id: id,
    title: title,
    description: '',
    dueDate: now,
    status: TaskStatus.todo,
    blockedByTaskId: null,
    createdAt: now,
    updatedAt: now,
  );
}
