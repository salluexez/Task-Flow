import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/task_status.dart';
import '../../repositories/task_repository.dart';
import '../../viewmodels/home_view_model.dart';
import '../widgets/error_state_view.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/loading_state_view.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/status_filter_chip.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_sheet.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeViewModel>(
      create: (_) => HomeViewModel(context.read<TaskRepository>()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, _) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppTheme.surface,
              floatingActionButton: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryContainer],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: viewModel.isMutating
                      ? null
                      : () => _openForm(context, viewModel),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add_rounded),
                ),
              ),
              body: SafeArea(
                child: RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: viewModel.isMutating
                      ? () async {}
                      : viewModel.loadTasks,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                    children: [
                      _Header(date: DateTime.now()),
                      const SizedBox(height: 24),
                      SearchBarField(
                        initialValue: viewModel.searchQuery,
                        onChanged: viewModel.setSearchQuery,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 42,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            StatusFilterChip(
                              label: 'All',
                              selected: viewModel.statusFilter == null,
                              onTap: () => viewModel.setStatusFilter(null),
                            ),
                            const SizedBox(width: 10),
                            for (final status in TaskStatus.values) ...[
                              StatusFilterChip(
                                label: status.label,
                                selected: viewModel.statusFilter == status,
                                onTap: () => viewModel.setStatusFilter(status),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'UPCOMING TASKS',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 16),
                      _buildContent(context, viewModel),
                    ],
                  ),
                ),
              ),
            ),
            if (viewModel.isMutating)
              const Positioned.fill(child: _MutationOverlay()),
          ],
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.isLoading) {
      return const LoadingStateView();
    }

    if (viewModel.errorMessage != null) {
      return ErrorStateView(
        message: viewModel.errorMessage!,
        onRetry: viewModel.loadTasks,
      );
    }

    if (viewModel.allTasks.isEmpty) {
      return EmptyStateView(
        onCreatePressed: () => _openForm(context, viewModel),
      );
    }

    if (viewModel.visibleTasks.isEmpty) {
      return const EmptyStateView(
        title: 'No matching tasks',
        message:
            'Try a different search term or status filter to surface the right task.',
      );
    }

    return Column(
      children: [
        for (final task in viewModel.visibleTasks) ...[
          _SwipeableTaskCard(
            task: task,
            viewModel: viewModel,
            onTap: () => _openDetails(context, viewModel, task),
          ),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 28),
        Text(
          viewModel.visibleTasks.length > 1
              ? 'Your afternoon is looking clear.'
              : 'One focused task beats ten noisy ones.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Future<void> _openForm(
    BuildContext context,
    HomeViewModel homeViewModel, [
    TaskModel? task,
  ]) async {
    final result = await Navigator.of(context).push<TaskModel>(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          allTasks: homeViewModel.allTasks,
          existingTask: task,
        ),
      ),
    );

    if (result != null && context.mounted) {
      await homeViewModel.loadTasks();
    }
  }

  Future<void> _openDetails(
    BuildContext context,
    HomeViewModel homeViewModel,
    TaskModel task,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return TaskDetailSheet(
          task: task,
          blockedByTitle: task.blockedByTaskId == null
              ? null
              : homeViewModel.tasksById[task.blockedByTaskId!]?.title,
          isBlocked: homeViewModel.isBlocked(task),
          onEdit: () async {
            Navigator.of(sheetContext).pop();
            await _openForm(context, homeViewModel, task);
          },
          onDelete: () async {
            Navigator.of(sheetContext).pop();
            await homeViewModel.deleteTask(task.id);
          },
          onMarkDone:
              task.status == TaskStatus.done || homeViewModel.isBlocked(task)
              ? null
              : () async {
                  Navigator.of(sheetContext).pop();
                  await homeViewModel.markTaskDone(task);
                },
        );
      },
    );
  }
}

class _MutationOverlay extends StatelessWidget {
  const _MutationOverlay();

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.08),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLowest,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              SizedBox(width: 12),
              Text('Updating tasks...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeableTaskCard extends StatelessWidget {
  const _SwipeableTaskCard({
    required this.task,
    required this.viewModel,
    required this.onTap,
  });

  final TaskModel task;
  final HomeViewModel viewModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBlocked = viewModel.isBlocked(task);
    return Dismissible(
      key: ValueKey('${task.id}-${task.status.name}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final outcome = await viewModel.handleLeftSwipe(task);
        if (!context.mounted) {
          return false;
        }

        final messenger = ScaffoldMessenger.of(context);
        switch (outcome) {
          case TaskSwipeOutcome.blocked:
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Finish the blocking task first before moving this one.',
                ),
              ),
            );
            return false;
          case TaskSwipeOutcome.movedToInProgress:
            messenger.showSnackBar(
              SnackBar(content: Text('"${task.title}" moved to In Progress.')),
            );
            return false;
          case TaskSwipeOutcome.movedToDone:
            messenger.showSnackBar(
              SnackBar(content: Text('"${task.title}" moved to Done.')),
            );
            return false;
          case TaskSwipeOutcome.deleted:
            messenger.showSnackBar(
              SnackBar(content: Text('"${task.title}" was deleted.')),
            );
            return true;
        }
      },
      background: _SwipeActionBackground(
        label: _swipeLabel(task.status, isBlocked),
        icon: _swipeIcon(task.status, isBlocked),
        color: _swipeColor(task.status, isBlocked),
      ),
      child: TaskCard(
        task: task,
        isBlocked: isBlocked,
        blockedByTitle: task.blockedByTaskId == null
            ? null
            : viewModel.tasksById[task.blockedByTaskId!]?.title,
        onTap: onTap,
      ),
    );
  }

  String _swipeLabel(TaskStatus status, bool isBlocked) {
    if (isBlocked) {
      return 'BLOCKED';
    }
    switch (status) {
      case TaskStatus.todo:
        return 'MOVE TO IN PROGRESS';
      case TaskStatus.inProgress:
        return 'MOVE TO DONE';
      case TaskStatus.done:
        return 'DELETE TASK';
    }
  }

  IconData _swipeIcon(TaskStatus status, bool isBlocked) {
    if (isBlocked) {
      return Icons.lock_outline_rounded;
    }
    switch (status) {
      case TaskStatus.todo:
        return Icons.play_arrow_rounded;
      case TaskStatus.inProgress:
        return Icons.check_rounded;
      case TaskStatus.done:
        return Icons.delete_outline_rounded;
    }
  }

  Color _swipeColor(TaskStatus status, bool isBlocked) {
    if (isBlocked) {
      return AppTheme.surfaceHigh;
    }
    switch (status) {
      case TaskStatus.todo:
        return AppTheme.primary;
      case TaskStatus.inProgress:
        return const Color(0xFF1E8E66);
      case TaskStatus.done:
        return AppTheme.danger;
    }
  }
}

class _SwipeActionBackground extends StatelessWidget {
  const _SwipeActionBackground({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = color == AppTheme.surfaceHigh
        ? AppTheme.textSecondary
        : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: foregroundColor),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: foregroundColor),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceLow),
          icon: const Icon(Icons.menu_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Curator',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppTheme.primary),
              ),
              const SizedBox(height: 18),
              Text(
                '${date.weekday == DateTime.monday ? 'MONDAY' : 'TODAY'}, ${_monthDay(date)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Good Morning.',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 34),
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.inProgress,
          child: Icon(Icons.person_rounded, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  String _monthDay(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
