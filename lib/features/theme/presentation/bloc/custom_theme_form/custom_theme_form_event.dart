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

/// Fired when the user picks a font from the fixed font list on the
/// Custom Theme Screen.
final class CustomThemeFontChanged extends CustomThemeFormEvent {
  final String fontFamily;

  const CustomThemeFontChanged(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}

/// Fired when the user picks a header image from the gallery. [imagePath]
/// is always non-null when fired from the picker — image_picker returning
/// null (user cancelled) means the bloc simply doesn't dispatch this
/// event at all, so the existing selection is left untouched.
///
/// To explicitly REMOVE an already-picked image, use
/// [CustomThemeHeaderImageCleared] instead — a null [imagePath] here
/// would be indistinguishable from "no change" under the state's
/// `copyWith` semantics.
final class CustomThemeHeaderImagePicked extends CustomThemeFormEvent {
  final String imagePath;

  const CustomThemeHeaderImagePicked(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// Fired when the user taps "remove image" to go back to a no-header-
/// image theme.
final class CustomThemeHeaderImageCleared extends CustomThemeFormEvent {
  const CustomThemeHeaderImageCleared();
}

/// Fired when the user taps Save. The bloc validates (non-empty name)
/// and guards against duplicate submissions before calling
/// [SaveCustomTheme].
final class CustomThemeFormSubmitted extends CustomThemeFormEvent {
  const CustomThemeFormSubmitted();
}