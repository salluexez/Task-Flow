import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class SearchBarField extends StatelessWidget {
  const SearchBarField({
    super.key,
    required this.onChanged,
    this.initialValue = '',
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
        hintText: 'Search tasks...',
      ),
    );
  }
}
