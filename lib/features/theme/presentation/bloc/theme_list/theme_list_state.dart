// lib/features/theme/presentation/bloc/theme_list/theme_list_state.dart

part of 'theme_list_bloc.dart';

enum ThemeListStatus { initial, loading, loaded, error }

/// State for the Theme Screen's list of selectable themes.
///
/// Deliberately does NOT track "which theme is selected" itself — that's
/// read live from `AppThemeCubit.activeTheme` at build time (see
/// `ThemeScreen`), so the highlighted item always matches the actual
/// active theme without this Bloc needing to duplicate or resync that
/// state.
class ThemeListState extends Equatable {
  final ThemeListStatus status;
  final List<AppThemeData> themes;
  final String? errorMessage;

  const ThemeListState({
    this.status = ThemeListStatus.initial,
    this.themes = const [],
    this.errorMessage,
  });

  bool get isEmpty => status == ThemeListStatus.loaded && themes.isEmpty;

  ThemeListState copyWith({
    ThemeListStatus? status,
    List<AppThemeData>? themes,
    String? errorMessage,
  }) {
    return ThemeListState(
      status: status ?? this.status,
      themes: themes ?? this.themes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, themes, errorMessage];
}
