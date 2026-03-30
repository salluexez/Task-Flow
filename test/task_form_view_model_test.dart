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

  test('edit mode restores its own saved draft', () async {
    final repository = _DraftRepository(
      drafts: {
        'task-1': const TaskDraftModel(
          title: 'Edited draft title',
          description: 'Edited draft description',
          dueDate: null,
          status: TaskStatus.inProgress,
        ),
      },
    );
    final existingTask = _task(id: 'task-1', title: 'Real task');

    final viewModel = TaskFormViewModel(
      repository: repository,
      allTasks: [existingTask],
      existingTask: existingTask,
    );
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.title, 'Edited draft title');
    expect(viewModel.description, 'Edited draft description');
    expect(viewModel.status, TaskStatus.inProgress);
  });

  test('all form field changes persist draft for edit mode', () async {
    final blocker = _task(id: 'blocker', title: 'Blocker');
    final existingTask = _task(id: 'task-1', title: 'Real task');
    final repository = _DraftRepository();

    final viewModel = TaskFormViewModel(
      repository: repository,
      allTasks: [existingTask, blocker],
      existingTask: existingTask,
    );

    viewModel.updateTitle('Updated title');
    viewModel.updateDescription('Updated description');
    viewModel.updateDueDate(DateTime(2026, 10, 21));
    viewModel.updateStatus(TaskStatus.todo);
    viewModel.updateBlockedByTask('blocker');
    await Future<void>.delayed(Duration.zero);

    final savedDraft = repository.loadDraft(draftId: 'task-1');
    expect(savedDraft?.title, 'Updated title');
    expect(savedDraft?.description, 'Updated description');
    expect(savedDraft?.dueDate, DateTime(2026, 10, 21));
    expect(savedDraft?.status, TaskStatus.todo);
    expect(savedDraft?.blockedByTaskId, 'blocker');
  });

  test('blocked tasks cannot be saved with progressed status', () async {
    final blocker = _task(
      id: 'blocker',
      title: 'Blocker',
      status: TaskStatus.inProgress,
    );
    final repository = _DraftRepository();
    final viewModel = TaskFormViewModel(
      repository: repository,
      allTasks: [blocker],
    );

    await Future<void>.delayed(Duration.zero);
    viewModel.updateTitle('Task');
    viewModel.updateDescription('Description');
    viewModel.updateDueDate(DateTime(2026, 10, 21));
    viewModel.updateBlockedByTask('blocker');
    viewModel.updateStatus(TaskStatus.done);

    final result = await viewModel.save();

    expect(result, isNull);
    expect(
      viewModel.fieldErrors['blockedState'],
      'Blocked tasks must stay To-Do until the prerequisite is done.',
    );
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
  _DraftRepository({TaskDraftModel? draft, Map<String, TaskDraftModel>? drafts})
    : _drafts = {...?drafts} {
    if (draft != null) {
      _drafts['create'] = draft;
    }
  }

  final Map<String, TaskDraftModel> _drafts;

  @override
  Future<void> clearDraft({String? draftId}) async {
    _drafts.remove(_draftKey(draftId));
  }

  @override
  Future<TaskModel> createTask(TaskDraftModel draft) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteTask(String id) async {}

  @override
  Future<List<TaskModel>> fetchTasks() async => const [];

  @override
  TaskDraftModel? loadDraft({String? draftId}) => _drafts[_draftKey(draftId)];

  @override
  Future<void> saveDraft(TaskDraftModel draft, {String? draftId}) async {
    _drafts[_draftKey(draftId)] = draft;
  }

  @override
  Future<TaskModel> updateTask(String id, TaskDraftModel draft) async =>
      throw UnimplementedError();

  String _draftKey(String? draftId) => draftId ?? 'create';
}

class _SlowRepository implements TaskRepository {
  int createCallCount = 0;

  @override
  Future<void> clearDraft({String? draftId}) async {}

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
  TaskDraftModel? loadDraft({String? draftId}) => null;

  @override
  Future<void> saveDraft(TaskDraftModel draft, {String? draftId}) async {}

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
