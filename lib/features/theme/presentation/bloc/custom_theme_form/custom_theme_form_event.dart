// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_event.dart

part of 'custom_theme_form_bloc.dart';

abstract class CustomThemeFormEvent extends Equatable {
  const CustomThemeFormEvent();

  @override
  List<Object?> get props => [];
}

class CustomThemeFormNameChanged extends CustomThemeFormEvent {
  final String name;

  const CustomThemeFormNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class CustomThemeFormPrimaryColorChanged extends CustomThemeFormEvent {
  final Color color;

  const CustomThemeFormPrimaryColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

class CustomThemeFormBackgroundColorChanged extends CustomThemeFormEvent {
  final Color color;

  const CustomThemeFormBackgroundColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

class CustomThemeFormAccentColorChanged extends CustomThemeFormEvent {
  final Color color;

  const CustomThemeFormAccentColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

/// [imagePath] is nullable so the picker flow can also be used to CLEAR a
/// previously-picked header image (pass `null`) — distinct from the user
/// simply never having picked one yet (form's initial `headerImagePath`
/// state, also `null`). Both cases behave identically since there's
/// nothing to distinguish from the form's point of view.
class CustomThemeFormHeaderImageChanged extends CustomThemeFormEvent {
  final String? imagePath;

  const CustomThemeFormHeaderImageChanged(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class CustomThemeFormSubmitted extends CustomThemeFormEvent {
  const CustomThemeFormSubmitted();
}
