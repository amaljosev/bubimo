// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_event.dart

import 'package:equatable/equatable.dart';

sealed class CustomThemeFormEvent extends Equatable {
  const CustomThemeFormEvent();

  @override
  List<Object?> get props => [];
}

final class CustomThemeNameChanged extends CustomThemeFormEvent {
  final String name;

  const CustomThemeNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

final class CustomThemePrimaryColorChanged extends CustomThemeFormEvent {
  final String hexColor;

  const CustomThemePrimaryColorChanged(this.hexColor);

  @override
  List<Object?> get props => [hexColor];
}

final class CustomThemeBackgroundColorChanged extends CustomThemeFormEvent {
  final String hexColor;

  const CustomThemeBackgroundColorChanged(this.hexColor);

  @override
  List<Object?> get props => [hexColor];
}

final class CustomThemeAccentColorChanged extends CustomThemeFormEvent {
  final String hexColor;

  const CustomThemeAccentColorChanged(this.hexColor);

  @override
  List<Object?> get props => [hexColor];
}

final class CustomThemeHeaderImagePicked extends CustomThemeFormEvent {
  final String? imagePath;

  const CustomThemeHeaderImagePicked(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// Fired when the user taps Save. The bloc validates (non-empty name)
/// and guards against duplicate submissions before calling
/// [SaveCustomTheme].
final class CustomThemeFormSubmitted extends CustomThemeFormEvent {
  const CustomThemeFormSubmitted();
}