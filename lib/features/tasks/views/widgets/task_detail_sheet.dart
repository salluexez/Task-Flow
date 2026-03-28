import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/task_status.dart';
import '../../utils/date_formatters.dart';

class TaskDetailSheet extends StatelessWidget {
  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.isBlocked,
    this.onMarkDone,
    this.blockedByTitle,
  });

  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMarkDone;
  final bool isBlocked;
  final String? blockedByTitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLowest.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.08),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 92,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.inProgress],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Row(
              children: [
                _HeaderBadge(label: task.status.label.toUpperCase()),
                const SizedBox(width: 10),
                if (isBlocked) const _HeaderBadge(label: 'BLOCKED', dark: true),
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(fontSize: 24, height: 1.1),
            ),
            const SizedBox(height: 18),
            Text('DESCRIPTION', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetaPanel(
                  icon: Icons.calendar_today_outlined,
                  label: 'DUE DATE',
                  value: DateFormatters.detail(task.dueDate),
                ),
                _MetaPanel(
                  icon: Icons.flag_outlined,
                  label: 'STATUS',
                  value: task.status.label,
                ),
                if (blockedByTitle != null)
                  _MetaPanel(
                    icon: Icons.link_rounded,
                    label: 'BLOCKED BY',
                    value: blockedByTitle!,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onMarkDone,
                    child: Text(
                      task.status == TaskStatus.done
                          ? 'Already Done'
                          : 'Mark as Done',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ElevatedButton(
                      onPressed: onEdit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Edit Task'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: dark ? AppTheme.surfaceLow : AppTheme.inProgress,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: dark ? AppTheme.textSecondary : AppTheme.primary,
        ),
      ),
    );
  }
}

class _MetaPanel extends StatelessWidget {
  const _MetaPanel({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 136),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
