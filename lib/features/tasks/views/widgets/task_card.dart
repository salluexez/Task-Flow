import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/task_status.dart';
import '../../utils/date_formatters.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.isBlocked,
    this.blockedByTitle,
  });

  final TaskModel task;
  final VoidCallback onTap;
  final bool isBlocked;
  final String? blockedByTitle;

  @override
  Widget build(BuildContext context) {
    final statusColors = _statusColors(task.status);
    return Material(
      color: isBlocked ? AppTheme.blocked : AppTheme.surfaceLowest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: statusColors),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(999),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.textPrimary.withValues(
                                  alpha: isBlocked ? 0.6 : 1,
                                ),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.textSecondary.withValues(
                                  alpha: isBlocked ? 0.7 : 1,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusPill(status: task.status, isBlocked: isBlocked),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppTheme.textSecondary.withValues(
                      alpha: isBlocked ? 0.7 : 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormatters.card(task.dueDate),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary.withValues(
                        alpha: isBlocked ? 0.7 : 1,
                      ),
                    ),
                  ),
                  if (blockedByTitle != null) ...[
                    const Spacer(),
                    const Icon(
                      Icons.link_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Blocked by $blockedByTitle',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _statusColors(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return const [AppTheme.todo, Color(0xFFEDEEF2)];
      case TaskStatus.inProgress:
        return const [AppTheme.inProgress, Color(0xFFD1CBFF)];
      case TaskStatus.done:
        return const [AppTheme.done, Color(0xFFFFD0BA)];
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.isBlocked});

  final TaskStatus status;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    switch (status) {
      case TaskStatus.todo:
        background = AppTheme.todo;
        foreground = AppTheme.textSecondary;
      case TaskStatus.inProgress:
        background = AppTheme.inProgress;
        foreground = AppTheme.primary;
      case TaskStatus.done:
        background = AppTheme.done;
        foreground = const Color(0xFF9D5738);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isBlocked ? AppTheme.surfaceHigh : background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isBlocked ? 'BLOCKED' : status.label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isBlocked ? AppTheme.textSecondary : foreground,
        ),
      ),
    );
  }
}
