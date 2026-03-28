import '../models/task_draft_model.dart';
import '../models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> fetchTasks();
  Future<TaskModel> createTask(TaskDraftModel draft);
  Future<TaskModel> updateTask(String id, TaskDraftModel draft);
  Future<void> deleteTask(String id);
  Future<void> saveDraft(TaskDraftModel draft);
  TaskDraftModel? loadDraft();
  Future<void> clearDraft();
}
