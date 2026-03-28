import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/task_status.dart';
import '../../repositories/task_repository.dart';
import '../../viewmodels/task_form_view_model.dart';
import '../../utils/date_formatters.dart';

class TaskFormScreen extends StatelessWidget {
  const TaskFormScreen({super.key, required this.allTasks, this.existingTask});

  final List<TaskModel> allTasks;
  final TaskModel? existingTask;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskFormViewModel>(
      create: (_) => TaskFormViewModel(
        repository: context.read<TaskRepository>(),
        allTasks: allTasks,
        existingTask: existingTask,
      ),
      child: _TaskFormView(existingTask: existingTask),
    );
  }
}

class _TaskFormView extends StatefulWidget {
  const _TaskFormView({this.existingTask});

  final TaskModel? existingTask;

  @override
  State<_TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<_TaskFormView> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskFormViewModel>(
      builder: (context, viewModel, _) {
        _syncController(_titleController, viewModel.title);
        _syncController(_descriptionController, viewModel.description);

        return PopScope(
          onPopInvokedWithResult: (_, _) {},
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: Text(viewModel.isEditMode ? 'Edit Task' : 'Create Task'),
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 18),
                  child: CircleAvatar(
                    backgroundColor: AppTheme.inProgress,
                    child: Icon(
                      Icons.person_rounded,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel(label: 'TASK TITLE'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      enabled: !viewModel.isSaving,
                      onChanged: viewModel.updateTitle,
                      decoration: InputDecoration(
                        hintText: 'What needs to be done?',
                        errorText: viewModel.fieldErrors['title'],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'DESCRIPTION'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      enabled: !viewModel.isSaving,
                      onChanged: viewModel.updateDescription,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Add details about this task...',
                        errorText: viewModel.fieldErrors['description'],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'DUE DATE'),
                    const SizedBox(height: 8),
                    _SelectionField(
                      text: viewModel.dueDate == null
                          ? 'mm/dd/yyyy'
                          : DateFormatters.form(viewModel.dueDate!),
                      hasValue: viewModel.dueDate != null,
                      errorText: viewModel.fieldErrors['dueDate'],
                      icon: Icons.calendar_today_outlined,
                      enabled: !viewModel.isSaving,
                      onTap: () => _pickDate(context, viewModel),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'STATUS'),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonFormField<TaskStatus>(
                        initialValue: viewModel.status,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        items: TaskStatus.values
                            .map(
                              (status) => DropdownMenuItem<TaskStatus>(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(),
                        onChanged: viewModel.isSaving
                            ? null
                            : (value) {
                                if (value != null) {
                                  viewModel.updateStatus(value);
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'BLOCKED BY'),
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonFormField<String?>(
                        initialValue: viewModel.blockedByTaskId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          errorText: viewModel.fieldErrors['blockedBy'],
                        ),
                        hint: const Text('None (Optional)'),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('None (Optional)'),
                          ),
                          ...viewModel.availableBlockers.map(
                            (task) => DropdownMenuItem<String?>(
                              value: task.id,
                              child: Text(
                                task.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: viewModel.isSaving
                            ? null
                            : viewModel.updateBlockedByTask,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Link this task to another that must be finished first.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                    if (viewModel.errorMessage != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        viewModel.errorMessage!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.danger,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.primaryContainer,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.18),
                              blurRadius: 26,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: viewModel.isSaving
                              ? null
                              : () async {
                                  final saved = await viewModel.save();
                                  if (saved != null && context.mounted) {
                                    Navigator.of(context).pop(saved);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: viewModel.isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  viewModel.isEditMode
                                      ? 'Save Changes'
                                      : 'Save Task',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    TaskFormViewModel viewModel,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      viewModel.updateDueDate(picked);
    }
  }

  void _syncController(TextEditingController controller, String nextValue) {
    if (controller.text == nextValue) {
      return;
    }
    controller.value = controller.value.copyWith(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.labelSmall);
  }
}

class _SelectionField extends StatelessWidget {
  const _SelectionField({
    required this.text,
    required this.hasValue,
    required this.icon,
    required this.onTap,
    this.errorText,
    this.enabled = true,
  });

  final String text;
  final bool hasValue;
  final IconData icon;
  final VoidCallback onTap;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppTheme.surfaceLow,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hasValue
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  Icon(icon, color: AppTheme.textSecondary),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.danger,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
