// lib/core/navigation/main_shell.dart

import 'package:bubimo/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/analytics/presentation/bloc/analytics/analytics_bloc.dart';
import '../../features/analytics/presentation/bloc/analytics/analytics_event.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/bloc/diary_list/diary_list_bloc.dart';
import '../../features/home/presentation/bloc/diary_list/diary_list_event.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/theme/presentation/bloc/theme_list/theme_list_bloc.dart';
import '../../features/theme/presentation/bloc/theme_list/theme_list_event.dart';
import '../../features/theme/presentation/pages/theme_screen.dart';
import '../../features/timeline/presentation/pages/timeline_page.dart';
import '../di/injection.dart';

/// App-wide navigation shell. Owns the bottom navigation bar and an
/// [IndexedStack] of the five top-level tabs: Timeline, Favorites,
/// Diary, Themes, Profile.
///
/// Each tab's BLoC is created exactly once here (not inside its page),
/// so switching tabs preserves scroll position and data — no refetching,
/// no rebuild of offscreen tabs beyond the initial build. Timeline and
/// Favorites don't get their own bloc: both read the same shared
/// [DiaryListBloc] the Diary tab uses, since all three are just
/// different views over the same entry list.
///
/// Every tab provides its own Scaffold/AppBar (Diary and Timeline use a
/// collapsing SliverAppBar with the theme's header image; Favorites and
/// Profile use a plain AppBar; Themes uses a Scaffold with a built-in
/// TabBar for App Themes / Custom Themes).
///
/// The Profile tab renders [ProfileAnalyticsScreen] — the combined
/// Profile & Analytics screen — so it needs both a [ProfileCubit] and
/// an [AnalyticsBloc] in scope. Both are created once here (alongside
/// [_diaryListBloc]/[_themeListBloc]) rather than per-build, for the
/// same reason: switching away and back to the Profile tab shouldn't
/// re-trigger a full reload. The same screen is ALSO reached by pushing
/// AppRoutes.profile (e.g. not currently used, but kept available) —
/// that pushed route provides its own fresh instances since it sits
/// outside this shell's widget tree.
///
/// Settings is NOT a tab — it's reached by pushing from Profile (gear
/// icon). See AppRoutes.settings.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 2; // Diary is the default landing tab.

  // Created once and kept alive for the lifetime of the shell.
  late final DiaryListBloc _diaryListBloc;
  late final ThemeListBloc _themeListBloc;
  late final ProfileCubit _profileCubit;
  late final AnalyticsBloc _analyticsBloc;

  static const List<_TabConfig> _tabs = [
    _TabConfig(label: 'Timeline', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month),
    _TabConfig(label: 'Favorites', icon: Icons.favorite_outline, activeIcon: Icons.favorite),
    _TabConfig(label: 'Diary', icon: Icons.book_outlined, activeIcon: Icons.book),
    _TabConfig(label: 'Themes', icon: Icons.palette_outlined, activeIcon: Icons.palette),
    _TabConfig(label: 'Profile', icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  @override
  void initState() {
    super.initState();
    _diaryListBloc = getIt<DiaryListBloc>()..add(const LoadDiaryEntries());
    _themeListBloc = getIt<ThemeListBloc>()..add(const ThemeListLoaded());
    _profileCubit = getIt<ProfileCubit>()..loadProfile();
    _analyticsBloc = getIt<AnalyticsBloc>()..add(const LoadAnalytics());
  }

  @override
  void dispose() {
    _diaryListBloc.close();
    _themeListBloc.close();
    _profileCubit.close();
    _analyticsBloc.close();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  // Every tab now renders its own Scaffold/AppBar — including Themes
  // (index 3), which owns a full Scaffold with its TabBar (App Themes /
  // Custom Themes) built directly into `ThemeScreen`. There is no
  // shell-level shared AppBar anymore.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BlocProvider.value(
            value: _diaryListBloc,
            child: const TimelinePage(),
          ),
          BlocProvider.value(
            value: _diaryListBloc,
            child: const FavoritesPage(),
          ),
          BlocProvider.value(
            value: _diaryListBloc,
            child: const HomePage(),
          ),
          BlocProvider.value(
            value: _themeListBloc,
            child: const ThemeScreen(),
          ),
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _profileCubit),
              BlocProvider.value(value: _analyticsBloc),
            ],
            child: const ProfileAnalyticsScreen(),
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