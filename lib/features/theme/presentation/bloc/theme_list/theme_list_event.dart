// lib/features/theme/presentation/bloc/theme_list/theme_list_event.dart

part of 'theme_list_bloc.dart';

sealed class ThemeListEvent extends Equatable {
  const ThemeListEvent();

  @override
  List<Object?> get props => [];
}

/// Loads all themes (built-in + custom) and the currently active theme
/// id. Dispatched on Theme Switcher screen init, and re-dispatched after
/// returning from the Create/Edit Custom Theme screen or after a
/// delete.
final class ThemeListLoaded extends ThemeListEvent {
  const ThemeListLoaded();
}

/// Applies [themeId] immediately — used for built-in themes (instant
/// tap-to-apply) and as the handler behind the custom-theme "Apply
/// Theme" button.
final class ThemeListThemeApplied extends ThemeListEvent {
  final String themeId;

  const ThemeListThemeApplied(this.themeId);

  @override
  List<Object?> get props => [themeId];
}

/// Applies the default built-in theme — "Reset to Default" button.
final class ThemeListResetToDefaultRequested extends ThemeListEvent {
  const ThemeListResetToDefaultRequested();
}

/// Deletes a custom theme by id.
final class ThemeListCustomThemeDeleted extends ThemeListEvent {
  final String themeId;

  const ThemeListCustomThemeDeleted(this.themeId);

  @override
  List<Object?> get props => [themeId];
}
