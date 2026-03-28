import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    this.title = 'No tasks yet',
    this.message =
        'Start organizing your day by creating your first task. Your focused workspace is waiting for its first entry.',
    this.onCreatePressed,
  });

  final String title;
  final String message;
  final VoidCallback? onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.content_copy_rounded,
              size: 48,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 26),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.displayLarge?.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          if (onCreatePressed != null) ...[
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.16),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: onCreatePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create your first task'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
