import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_flow/app/task_flow_app.dart';
import 'package:task_flow/features/tasks/models/task_draft_model.dart';
import 'package:task_flow/features/tasks/models/task_model.dart';
import 'package:task_flow/features/tasks/models/task_status.dart';
import 'package:task_flow/features/tasks/repositories/task_repository.dart';

void main() {
  testWidgets('home screen switches from loading into empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      TaskFlowApp(repository: _FakeTaskRepository(tasks: const [])),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('UPCOMING TASKS'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('Create your first task'), findsOneWidget);
  });

  testWidgets('search narrows task cards by title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      TaskFlowApp(
        repository: _FakeTaskRepository(
          tasks: [
            _task(id: '1', title: 'Website Redesign'),
            _task(id: '2', title: 'Backend Integration'),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Website');
    await tester.pump();

    expect(find.text('Website Redesign'), findsOneWidget);
    expect(find.text('Backend Integration'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Website Redesign'), findsOneWidget);
    expect(find.text('Backend Integration'), findsNothing);
  });

  testWidgets('blocked detail sheet disables mark done action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      TaskFlowApp(
        repository: _FakeTaskRepository(
          tasks: [
            _task(id: '1', title: 'Blocked task', blockedByTaskId: '2'),
            _task(
              id: '2',
              title: 'Blocker',
              status: TaskStatus.inProgress,
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Blocked task'));
    await tester.pumpAndSettle();

    final button = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Blocked'),
    );
    expect(button.onPressed, isNull);
  });
}

class _FakeTaskRepository implements TaskRepository {
  _FakeTaskRepository({required List<TaskModel> tasks})
    : _tasks = List.of(tasks);

  final List<TaskModel> _tasks;
  TaskDraftModel? _draft;

  @override
  Future<void> clearDraft({String? draftId}) async {
    _draft = null;
  }

  @override
  Future<TaskModel> createTask(TaskDraftModel draft) async {
    final task = _task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: draft.title,
      description: draft.description,
      dueDate: draft.dueDate ?? DateTime(2026, 10, 21),
      status: draft.status,
      blockedByTaskId: draft.blockedByTaskId,
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
  }

  @override
  Future<List<TaskModel>> fetchTasks() async => List.unmodifiable(_tasks);

  @override
  TaskDraftModel? loadDraft({String? draftId}) => _draft;

  @override
  Future<void> saveDraft(TaskDraftModel draft, {String? draftId}) async {
    _draft = draft;
  }

  @override
  Future<TaskModel> updateTask(String id, TaskDraftModel draft) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    final updated = _tasks[index].copyWith(
      title: draft.title,
      description: draft.description,
      dueDate: draft.dueDate,
      status: draft.status,
      blockedByTaskId: draft.blockedByTaskId,
    );
    _tasks[index] = updated;
    return updated;
  }
}

TaskModel _task({
  required String id,
  required String title,
  String description = 'Sample description',
  DateTime? dueDate,
  TaskStatus status = TaskStatus.todo,
  String? blockedByTaskId,
}) {
  final now = DateTime(2026, 10, 20);
  return TaskModel(
    id: id,
    title: title,
    description: description,
    dueDate: dueDate ?? DateTime(2026, 10, 21),
    status: status,
    blockedByTaskId: blockedByTaskId,
    createdAt: now,
    updatedAt: now,
  );
}
