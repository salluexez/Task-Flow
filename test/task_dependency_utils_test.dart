import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/features/tasks/models/task_model.dart';
import 'package:task_flow/features/tasks/models/task_status.dart';
import 'package:task_flow/features/tasks/utils/task_dependency_utils.dart';

void main() {
  test('task is blocked when prerequisite is not done', () {
    final blocker = _task(
      id: 'a',
      title: 'Design',
      status: TaskStatus.inProgress,
    );
    final dependent = _task(id: 'b', title: 'Build', blockedByTaskId: 'a');

    expect(
      TaskDependencyUtils.isTaskBlocked(dependent, {
        'a': blocker,
        'b': dependent,
      }),
      isTrue,
    );
  });

  test('task unblocks when prerequisite is done', () {
    final blocker = _task(id: 'a', title: 'Design', status: TaskStatus.done);
    final dependent = _task(id: 'b', title: 'Build', blockedByTaskId: 'a');

    expect(
      TaskDependencyUtils.isTaskBlocked(dependent, {
        'a': blocker,
        'b': dependent,
      }),
      isFalse,
    );
  });

  test('cycle detection catches nested dependency loop', () {
    final source = _task(id: 'a', title: 'A', blockedByTaskId: 'c');
    final middle = _task(id: 'b', title: 'B', blockedByTaskId: 'a');
    final tail = _task(id: 'c', title: 'C', blockedByTaskId: 'b');

    expect(
      TaskDependencyUtils.wouldCreateCycle(
        sourceTaskId: 'a',
        proposedBlockedByTaskId: 'c',
        tasksById: {'a': source, 'b': middle, 'c': tail},
      ),
      isTrue,
    );
  });
}

TaskModel _task({
  required String id,
  required String title,
  TaskStatus status = TaskStatus.todo,
  String? blockedByTaskId,
}) {
  final now = DateTime(2026, 10, 20);
  return TaskModel(
    id: id,
    title: title,
    description: '',
    dueDate: now,
    status: status,
    blockedByTaskId: blockedByTaskId,
    createdAt: now,
    updatedAt: now,
  );
}
