// lib/features/theme/presentation/pages/theme_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/error_screen.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../domain/entities/app_theme_data.dart';
import '../bloc/theme_list/theme_list_bloc.dart';
import '../bloc/theme_list/theme_list_event.dart';
import '../bloc/theme_list/theme_list_state.dart';
import '../cubit/app_theme_cubit.dart';

/// Lists default and custom themes; tapping one applies it app-wide
/// immediately via [AppThemeCubit].
///
/// Its [ThemeListBloc] is provided by [MainShell] (created once, kept
/// alive across tab switches) — this widget only consumes it, it does
/// not create it. The "Custom Theme" action lives in the shell's shared
/// AppBar (previously this screen's own FAB), and calls back into
/// [ThemeListBloc] to refresh after a successful create.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ThemeScreenView();
  }
}

class _ThemeScreenView extends StatefulWidget {
  const _ThemeScreenView();

  @override
  State<_ThemeScreenView> createState() => _ThemeScreenViewState();
}

class _ThemeScreenViewState extends State<_ThemeScreenView> {
  // Guards against a rapid double-tap applying two theme changes at once.
  bool _isApplyingTheme = false;

  Future<void> _applyTheme(BuildContext context, String themeId) async {
    if (_isApplyingTheme) return;
    _isApplyingTheme = true;

    final result = await context.read<AppThemeCubit>().changeTheme(themeId);

    _isApplyingTheme = false;

    if (!context.mounted) return;

    result.match(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    // No Scaffold/AppBar/FAB here — MainShell provides the AppBar
    // (including the "Custom Theme" action, previously this screen's FAB).
    return BlocBuilder<ThemeListBloc, ThemeListState>(
      builder: (context, state) {
        switch (state.status) {
          case ThemeListStatus.initial:
          case ThemeListStatus.loading:
            return const LoadingScreen();

          case ThemeListStatus.failure:
            return ErrorScreen(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: () =>
                  context.read<ThemeListBloc>().add(const LoadThemes()),
            );

          case ThemeListStatus.loaded:
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: state.themes.length,
              itemBuilder: (context, index) {
                final theme = state.themes[index];
                final isSelected = theme.id == state.selectedThemeId;
                return _ThemeCard(
                  theme: theme,
                  isSelected: isSelected,
                  onTap: () => _applyTheme(context, theme.id),
                );
              },
            );
        }
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemeData theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  Color _colorFromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: _colorFromHex(theme.backgroundColor),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.black12,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _swatch(_colorFromHex(theme.primaryColor)),
                const SizedBox(width: 6),
                _swatch(_colorFromHex(theme.accentColor)),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, color: colorScheme.primary),
              ],
            ),
            const Spacer(),
            Text(
              theme.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (theme.isCustom)
              Text(
                'Custom',
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _swatch(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}