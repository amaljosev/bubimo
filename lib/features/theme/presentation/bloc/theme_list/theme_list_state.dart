// lib/features/theme/presentation/bloc/theme_list/theme_list_state.dart

import 'package:equatable/equatable.dart';

import '../../../domain/entities/app_theme_data.dart';

enum ThemeListStatus { initial, loading, loaded, failure }

class ThemeListState extends Equatable {
  final ThemeListStatus status;
  final List<AppThemeData> builtInThemes;
  final List<AppThemeData> customThemes;
  final String? activeThemeId;
  final String? errorMessage;

  /// True while an apply/reset/delete action is in flight — used to
  /// disable taps on theme tiles so a second tap can't fire mid-action,
  /// without needing a full-screen loading state.
  final bool isActionInProgress;

  const ThemeListState({
    this.status = ThemeListStatus.initial,
    this.builtInThemes = const [],
    this.customThemes = const [],
    this.activeThemeId,
    this.errorMessage,
    this.isActionInProgress = false,
  });

  bool get canAddCustomTheme => customThemes.length < 3;

  ThemeListState copyWith({
    ThemeListStatus? status,
    List<AppThemeData>? builtInThemes,
    List<AppThemeData>? customThemes,
    String? activeThemeId,
    String? errorMessage,
    bool clearError = false,
    bool? isActionInProgress,
  }) {
    return ThemeListState(
      status: status ?? this.status,
      builtInThemes: builtInThemes ?? this.builtInThemes,
      customThemes: customThemes ?? this.customThemes,
      activeThemeId: activeThemeId ?? this.activeThemeId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }

  @override
  List<Object?> get props => [
        status,
        builtInThemes,
        customThemes,
        activeThemeId,
        errorMessage,
        isActionInProgress,
      ];
}
