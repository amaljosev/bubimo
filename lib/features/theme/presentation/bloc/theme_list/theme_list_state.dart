// lib/features/theme/presentation/bloc/theme_list/theme_list_state.dart

import 'package:equatable/equatable.dart';

import '../../../domain/entities/app_theme_data.dart';

enum ThemeListStatus { initial, loading, loaded, failure }

class ThemeListState extends Equatable {
  final ThemeListStatus status;
  final List<AppThemeData> themes;
  final String? selectedThemeId;
  final String? errorMessage;

  const ThemeListState({
    this.status = ThemeListStatus.initial,
    this.themes = const [],
    this.selectedThemeId,
    this.errorMessage,
  });

  ThemeListState copyWith({
    ThemeListStatus? status,
    List<AppThemeData>? themes,
    String? selectedThemeId,
    String? errorMessage,
  }) {
    return ThemeListState(
      status: status ?? this.status,
      themes: themes ?? this.themes,
      selectedThemeId: selectedThemeId ?? this.selectedThemeId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, themes, selectedThemeId, errorMessage];
}