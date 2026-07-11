// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_event.dart

part of 'custom_theme_form_bloc.dart';

sealed class CustomThemeFormEvent extends Equatable {
  const CustomThemeFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initializes the form for CREATE mode: the Light palette starts from
/// [defaultTheme]'s colors (or Dusk's defaults if [defaultTheme] is
/// itself a Dark Mode theme) and the Dark palette starts from
/// Nightfall's defaults (or [defaultTheme]'s colors if it's Dark Mode)
/// — see `CustomThemeFormBloc._onInitialized`.
final class CustomThemeFormInitialized extends CustomThemeFormEvent {
  final AppThemeData defaultTheme;

  const CustomThemeFormInitialized(this.defaultTheme);

  @override
  List<Object?> get props => [defaultTheme];
}

/// Initializes the form for EDIT mode, pre-filling every field from an
/// existing custom theme — including recalling that theme's OWN saved
/// Light and Dark palettes independently (falling back to Dusk's/
/// Nightfall's defaults for whichever mode it has no saved palette
/// for yet).
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

/// Updates the PRIMARY color of whichever palette (Light/Dark) is
/// currently active.
final class CustomThemePrimaryColorChanged extends CustomThemeFormEvent {
  final RgbaColor color;

  const CustomThemePrimaryColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

final class CustomThemeSecondaryColorChanged extends CustomThemeFormEvent {
  final RgbaColor color;

  const CustomThemeSecondaryColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

final class CustomThemeSurfaceColorChanged extends CustomThemeFormEvent {
  final RgbaColor color;

  const CustomThemeSurfaceColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

final class CustomThemeBackgroundColorChanged extends CustomThemeFormEvent {
  final RgbaColor color;

  const CustomThemeBackgroundColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

final class CustomThemeTextColorChanged extends CustomThemeFormEvent {
  final RgbaColor color;

  const CustomThemeTextColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

/// Toggles Light/Dark Mode. Switching modes now shows THIS THEME'S OWN
/// palette for the newly-selected mode — the user's prior
/// customization for that mode (if any) is preserved, not discarded
/// (see `CustomThemeFormBloc._onDarkModeToggled`). A mode that has
/// never been customized shows Dusk's/Nightfall's defaults instead.
/// See [CustomThemeColorsReset] for explicitly resetting the current
/// mode's colors back to those defaults.
final class CustomThemeDarkModeToggled extends CustomThemeFormEvent {
  final bool isDark;

  const CustomThemeDarkModeToggled(this.isDark);

  @override
  List<Object?> get props => [isDark];
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

/// Resets the CURRENT mode's 5 color fields back to that mode's default
/// palette (Dusk's colors in Light Mode, Nightfall's in Dark Mode),
/// without changing [CustomThemeFormState.isDark] and without touching
/// the OTHER mode's palette. Fired by the always-visible "Reset
/// Colors" button on the Create/Edit Custom Theme screen — a one-tap
/// way back to a known-good starting point, distinct from
/// [CustomThemeDarkModeToggled] which never resets colors on its own.
final class CustomThemeColorsReset extends CustomThemeFormEvent {
  const CustomThemeColorsReset();
}

final class CustomThemeFormSubmitted extends CustomThemeFormEvent {
  const CustomThemeFormSubmitted();
}