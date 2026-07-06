// lib/core/navigation/main_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/bloc/analytics/analytics_bloc.dart';
import '../../features/analytics/presentation/bloc/analytics/analytics_event.dart';
import '../../features/analytics/presentation/pages/analytics_screen.dart';
import '../../features/home/presentation/bloc/diary_list/diary_list_bloc.dart';
import '../../features/home/presentation/bloc/diary_list/diary_list_event.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/reminders/presentation/bloc/reminder_settings/reminder_settings_bloc.dart';
import '../../features/reminders/presentation/bloc/reminder_settings/reminder_settings_event.dart';
import '../../features/reminders/presentation/pages/reminder_settings_page.dart';
import '../../features/theme/presentation/bloc/theme_list/theme_list_bloc.dart';
import '../../features/theme/presentation/bloc/theme_list/theme_list_event.dart';
import '../../features/theme/presentation/pages/theme_screen.dart';
import '../di/injection.dart';
import '../router/app_router.dart';

/// App-wide navigation shell. Owns the bottom navigation bar, the single
/// shared [AppBar], and an [IndexedStack] of the four top-level tabs.
///
/// Each tab's BLoC is created exactly once here (not inside its page),
/// so switching tabs preserves scroll position and data — no refetching,
/// no rebuild of offscreen tabs beyond the initial build.
///
/// Screens embedded here (HomePage, ThemeScreen, AnalyticsScreen,
/// ReminderSettingsPage) must not include their own Scaffold/AppBar —
/// the shell provides both. Their own BlocProviders have been removed
/// in favor of the ones created below.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Created once and kept alive for the lifetime of the shell.
  late final DiaryListBloc _diaryListBloc;
  late final ThemeListBloc _themeListBloc;
  late final AnalyticsBloc _analyticsBloc;
  late final ReminderSettingsBloc _reminderSettingsBloc;

  static const List<_TabConfig> _tabs = [
    _TabConfig(label: 'Diary', icon: Icons.book_outlined, activeIcon: Icons.book),
    _TabConfig(label: 'Themes', icon: Icons.palette_outlined, activeIcon: Icons.palette),
    _TabConfig(label: 'Analytics', icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart),
    _TabConfig(label: 'Reminders', icon: Icons.notifications_outlined, activeIcon: Icons.notifications),
  ];

  @override
  void initState() {
    super.initState();
    _diaryListBloc = getIt<DiaryListBloc>()..add(const LoadDiaryEntries());
    _themeListBloc = getIt<ThemeListBloc>()..add(const LoadThemes());
    _analyticsBloc = getIt<AnalyticsBloc>()..add(const LoadAnalytics());
    _reminderSettingsBloc = getIt<ReminderSettingsBloc>()
      ..add(const LoadReminderSettings());
  }

  @override
  void dispose() {
    _diaryListBloc.close();
    _themeListBloc.close();
    _analyticsBloc.close();
    _reminderSettingsBloc.close();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:_currentIndex==0?null: AppBar(
        title: Text(_tabs[_currentIndex].label),
        actions: _buildAppBarActions(context),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BlocProvider.value(
            value: _diaryListBloc,
            child: const HomePage(),
          ),
          BlocProvider.value(
            value: _themeListBloc,
            child: const ThemeScreen(),
          ),
          BlocProvider.value(
            value: _analyticsBloc,
            child: const AnalyticsScreen(),
          ),
          BlocProvider.value(
            value: _reminderSettingsBloc,
            child: const ReminderSettingsPage(),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.activeIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }

  /// Tab-specific AppBar actions. Only the Themes tab currently needs one
  /// (the "Custom Theme" action, moved here from its old FAB). Extend this
  /// switch as other tabs need their own actions.
  List<Widget>? _buildAppBarActions(BuildContext context) {
    switch (_currentIndex) {
      case 1: // Themes tab
        return [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Custom Theme',
            onPressed: () => _openCustomTheme(context),
          ),
        ];
      default:
        return null;
    }
  }

  Future<void> _openCustomTheme(BuildContext context) async {
    final result = await context.push<bool>(AppRoutes.customThemeScreen);
    if (result == true && mounted) {
      _themeListBloc.add(const LoadThemes());
    }
  }
}

class _TabConfig {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _TabConfig({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}