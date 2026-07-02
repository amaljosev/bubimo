// lib/features/theme/presentation/pages/theme_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/entities/app_theme_data.dart';
import '../../domain/usecases/get_all_themes.dart';
import '../bloc/theme_list/theme_list_bloc.dart';

import '../cubit/app_theme_cubit.dart';

/// Lists all selectable themes (bundled defaults + user-created custom
/// ones). Tapping a theme calls `AppThemeCubit.changeTheme`, which
/// applies it app-wide immediately (see `AppThemeCubit` doc comment) —
/// this screen doesn't manage the active theme itself, only reads it
/// (via `context.watch<AppThemeCubit>().activeTheme`) to know which item
/// to highlight.
///
/// Navigating to the Custom Theme Screen (create or edit) reuses the
/// established awaited-Navigator.push-result + reload pattern: on
/// return, [ThemeListRequested] is re-dispatched so newly-created/edited/
/// deleted custom themes are reflected without a full screen rebuild.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeListBloc(
        getAllThemes: GetIt.instance<GetAllThemes>(),
      )..add(const ThemeListRequested()),
      child: const _ThemeScreenView(),
    );
  }
}

class _ThemeScreenView extends StatefulWidget {
  const _ThemeScreenView();

  @override
  State<_ThemeScreenView> createState() => _ThemeScreenViewState();
}

class _ThemeScreenViewState extends State<_ThemeScreenView> {
  // Guards against rapid/duplicate taps triggering multiple
  // navigations/selections at once — same pattern used elsewhere in the
  // app (single-navigation guard on buttons).
  bool _isNavigating = false;
  bool _isSelecting = false;

  Future<void> _selectTheme(AppThemeData theme) async {
    if (_isSelecting) return;
    setState(() => _isSelecting = true);

    final success = await context.read<AppThemeCubit>().changeTheme(theme);

    if (!mounted) return;
    setState(() => _isSelecting = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not apply theme. Please try again.')),
      );
    }
  }

  Future<void> _openCustomThemeScreen({AppThemeData? existingTheme}) async {
    if (_isNavigating) return;
    _isNavigating = true;

    await context.pushNamed<bool>(
      AppRoutes.customThemeForm,
      extra: existingTheme,
    );

    _isNavigating = false;
    if (!mounted) return;
    context.read<ThemeListBloc>().add(const ThemeListRequested());
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = context.watch<AppThemeCubit>().activeTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Themes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCustomThemeScreen(),
        tooltip: 'Create custom theme',
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ThemeListBloc, ThemeListState>(
        builder: (context, state) {
          switch (state.status) {
            case ThemeListStatus.initial:
            case ThemeListStatus.loading:
              return const LoadingScreen(message: 'Loading themes…');
            case ThemeListStatus.error:
              return ErrorScreen(
                message: state.errorMessage ?? 'Failed to load themes.',
                onRetry: () => context
                    .read<ThemeListBloc>()
                    .add(const ThemeListRequested()),
              );
            case ThemeListStatus.loaded:
              if (state.isEmpty) {
                return const Center(child: Text('No themes available.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.themes.length,
                itemBuilder: (context, index) {
                  final theme = state.themes[index];
                  final isSelected = theme.id == activeTheme?.id;
                  return _ThemeListTile(
                    theme: theme,
                    isSelected: isSelected,
                    onTap: () => _selectTheme(theme),
                    onEdit: theme.isCustom
                        ? () => _openCustomThemeScreen(existingTheme: theme)
                        : null,
                  );
                },
              );
          }
        },
      ),
    );
  }
}

class _ThemeListTile extends StatelessWidget {
  final AppThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _ThemeListTile({
    required this.theme,
    required this.isSelected,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _ThemeSwatch(theme: theme),
      title: Text(theme.name),
      subtitle: theme.isCustom ? const Text('Custom') : const Text('Default'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final AppThemeData theme;

  const _ThemeSwatch({required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 4,
            child: _dot(theme.primaryColor),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: _dot(theme.accentColor),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}