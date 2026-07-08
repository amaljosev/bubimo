// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_event.dart

part of 'custom_theme_form_bloc.dart';

sealed class CustomThemeFormEvent extends Equatable {
  const CustomThemeFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes the form for CREATE mode: every color field starts from
/// [defaultTheme]'s colors, per spec ("All color fields should be
/// initialized using the default theme's colors").
final class CustomThemeFormInitialized extends CustomThemeFormEvent {
  final AppThemeData defaultTheme;

  const CustomThemeFormInitialized(this.defaultTheme);

  @override
  List<Object?> get props => [defaultTheme];
}

/// Initializes the form for EDIT mode, pre-filling every field from an
/// existing custom theme.
final class CustomThemeFormInitializedForEdit extends CustomThemeFormEvent {
  final AppThemeData existingTheme;

  const CustomThemeFormInitializedForEdit(this.existingTheme);

  @override
  List<Object?> get props => [existingTheme];
}

final class CustomThemeNameChanged extends CustomThemeFormEvent {
  final String name;

  const CustomThemeNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

final class CustomThemePrimaryColorChanged extends CustomThemeFormEvent {
  final RgbaColor color;

  const CustomThemePrimaryColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

final class CustomThemeBackgroundColorChanged extends CustomThemeFormEvent {
  final RgbaColor color;

  const CustomThemeBackgroundColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

final class CustomThemeAccentColorChanged extends CustomThemeFormEvent {
  final RgbaColor color;

  const CustomThemeAccentColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

final class CustomThemeFontChanged extends CustomThemeFormEvent {
  final String fontFamily;

  const CustomThemeFontChanged(this.fontFamily);

  @override
  List<Object?> get props => [fontFamily];
}

/// [imagePath] is the final, already-cropped (3600x1200) image file
/// path — cropping happens in the UI layer (image_cropper) before this
/// event is dispatched.
final class CustomThemeHeaderImagePicked extends CustomThemeFormEvent {
  final String imagePath;

  const CustomThemeHeaderImagePicked(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

final class CustomThemeHeaderImageCleared extends CustomThemeFormEvent {
  const CustomThemeHeaderImageCleared();
}

final class CustomThemeFormSubmitted extends CustomThemeFormEvent {
  const CustomThemeFormSubmitted();
}
