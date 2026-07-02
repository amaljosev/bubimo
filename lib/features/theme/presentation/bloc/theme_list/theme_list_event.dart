// lib/features/theme/presentation/bloc/theme_list/theme_list_event.dart
part of 'theme_list_bloc.dart';

abstract class ThemeListEvent extends Equatable {
  const ThemeListEvent();

  @override
  List<Object?> get props => [];
}

/// Loads all themes (defaults + custom) for display on the Theme Screen.
/// Dispatched on screen init, and again after returning from the Custom
/// Theme Screen (create/edit/delete) so the list reflects the latest data.
class ThemeListRequested extends ThemeListEvent {
  const ThemeListRequested();
}
