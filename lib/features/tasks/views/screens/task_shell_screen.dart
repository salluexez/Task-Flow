import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../widgets/placeholder_tab_view.dart';
import 'home_screen.dart';

class TaskShellScreen extends StatefulWidget {
  const TaskShellScreen({super.key});

  @override
  State<TaskShellScreen> createState() => _TaskShellScreenState();
}

class _TaskShellScreenState extends State<TaskShellScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    PlaceholderTabView(
      title: 'Calendar',
      message:
          'A light placeholder keeps the Stitch navigation intact without adding extra scope.',
    ),
    PlaceholderTabView(
      title: 'Profile',
      message:
          'This tab stays decorative for the assignment while Home delivers the full feature set.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            height: 76,
            selectedIndex: _selectedIndex,
            backgroundColor: AppTheme.surfaceLowest,
            indicatorColor: AppTheme.inProgress,
            surfaceTintColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'HOME',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'CALENDAR',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'PROFILE',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
