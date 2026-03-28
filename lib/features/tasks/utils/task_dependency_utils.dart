import '../models/task_model.dart';
import '../models/task_status.dart';

class TaskDependencyUtils {
  static bool isTaskBlocked(TaskModel task, Map<String, TaskModel> tasksById) {
    final blockerId = task.blockedByTaskId;
    if (blockerId == null) {
      return false;
    }

    final blocker = tasksById[blockerId];
    if (blocker == null) {
      return false;
    }

    return blocker.status != TaskStatus.done;
  }

  static bool wouldCreateCycle({
    required String sourceTaskId,
    required String? proposedBlockedByTaskId,
    required Map<String, TaskModel> tasksById,
  }) {
    if (proposedBlockedByTaskId == null) {
      return false;
    }

    String? currentId = proposedBlockedByTaskId;
    while (currentId != null) {
      if (currentId == sourceTaskId) {
        return true;
      }
      currentId = tasksById[currentId]?.blockedByTaskId;
    }

    return false;
  }
}
