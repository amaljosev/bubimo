// lib/features/theme/presentation/bloc/theme_list/theme_list_event.dart

import 'package:equatable/equatable.dart';

sealed class ThemeListEvent extends Equatable {
  const ThemeListEvent();

  @override
  List<Object?> get props => [];
}

/// Loads all themes (defaults + custom) plus the current selection, for
/// the Theme Screen. Fired on init, and again after returning from the
/// Custom Theme Screen with a new theme saved.
final class LoadThemes extends ThemeListEvent {
  const LoadThemes();
}