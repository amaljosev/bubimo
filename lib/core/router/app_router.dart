// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/diary_entry/domain/entities/diary_entry.dart';
import '../../features/diary_entry/presentation/pages/diary_entry_view_page.dart';
import '../../features/diary_entry/presentation/pages/diary_form_page.dart';
import '../../features/diary_entry/presentation/pages/home_page.dart';

/// Route name constants, used both for `GoRoute.name` and for
/// `context.goNamed(...)` calls elsewhere in the app.
abstract final class AppRoutes {
  static const onboarding = 'onboarding';
  static const home = 'home';
  static const diaryForm = 'diaryForm';
  static const diaryEntryView = 'diaryEntryView';
}

/// App-wide router configuration.
///
/// `diaryForm` accepts an optional [DiaryEntry] via `extra` (to seed the
/// form when editing). `diaryEntryView` takes an `id` path parameter — it
/// fetches its own data via `DiaryViewBloc` (see
/// `diary_entry_view_page.dart`), so no `extra` object is passed.
///
/// `onEdit` here is intentionally just raw navigation (push the form,
/// return the result) — `DiaryEntryViewPage` itself decides whether to
/// refresh its own bloc based on that result, since it's the one that
/// owns the `DiaryViewBloc` instance needing refreshing. Keeping that
/// decision in the page (not here) avoids reading a bloc from a
/// `BuildContext` that sits above where the bloc is actually provided.
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/',
      name: AppRoutes.onboarding,
      builder: (context, state) => const _PlaceholderScreen(
        screenName: 'Onboarding',
      ),
    ),
    GoRoute(
      path: '/home',
      name: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/diary-form',
      name: AppRoutes.diaryForm,
      builder: (context, state) {
        final existingEntry = state.extra as DiaryEntry?;
        return DiaryFormPage(
          existingEntry: existingEntry,
          onSaved: () => context.pop(true),
        );
      },
    ),
    GoRoute(
      path: '/diary-entry/:id',
      name: AppRoutes.diaryEntryView,
      builder: (context, state) {
        final entryId = state.pathParameters['id']!;
        return DiaryEntryViewPage(
          entryId: entryId,
          onEdit: (entry) => context.pushNamed<bool>(
            AppRoutes.diaryForm,
            extra: entry,
          ),
          onDeleted: () => context.pop(true),
        );
      },
    ),
  ],
);

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.screenName});

  final String screenName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(screenName)),
    );
  }
}