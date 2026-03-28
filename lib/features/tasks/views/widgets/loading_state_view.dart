import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            height: 156,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLowest,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  height: 16,
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 220,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 12,
                  width: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
