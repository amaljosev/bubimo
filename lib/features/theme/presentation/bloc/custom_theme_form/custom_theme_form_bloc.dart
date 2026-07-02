import 'package:bubimo/features/theme/domain/entities/app_theme_data.dart';
import 'package:bubimo/features/theme/domain/usecases/save_custom_theme.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'custom_theme_form_event.dart';
part 'custom_theme_form_state.dart';


/// Drives the Custom Theme Screen's create/edit form.
///
/// Pass [existingTheme] to edit an existing custom theme; omit it to
/// create a new one — same create-vs-edit pattern as `DiaryFormBloc`.
///
/// Owns name validation: [SaveCustomTheme] (domain) deliberately does NOT
/// validate, per that use case's doc comment, so a blank/whitespace-only
/// name is rejected here, before the use case is ever called, and surfaced
/// via `CustomThemeFormState.nameError` for the screen to show inline.
class CustomThemeFormBloc
    extends Bloc<CustomThemeFormEvent, CustomThemeFormState> {
  final SaveCustomTheme saveCustomTheme;
 
  CustomThemeFormBloc({
    required this.saveCustomTheme,
    AppThemeData? existingTheme,
  }) : super(
          CustomThemeFormState(
            id: existingTheme?.id ?? '',
            name: existingTheme?.name ?? '',
            primaryColor:
                existingTheme?.primaryColor ?? const Color(0xFF3F51B5),
            backgroundColor:
                existingTheme?.backgroundColor ?? const Color(0xFFFAFAFC),
            accentColor: existingTheme?.accentColor ?? const Color(0xFFFF7043),
            headerImagePath: existingTheme?.headerImagePath,
          ),
        ) {
    on<CustomThemeFormNameChanged>(_onNameChanged);
    on<CustomThemeFormPrimaryColorChanged>(_onPrimaryColorChanged);
    on<CustomThemeFormBackgroundColorChanged>(_onBackgroundColorChanged);
    on<CustomThemeFormAccentColorChanged>(_onAccentColorChanged);
    on<CustomThemeFormHeaderImageChanged>(_onHeaderImageChanged);
    on<CustomThemeFormSubmitted>(_onSubmitted);
  }
 
  void _onNameChanged(
    CustomThemeFormNameChanged event,
    Emitter<CustomThemeFormState> emit,
  ) {
    // Clear a previously-shown name error as soon as the user edits the
    // field again, rather than leaving a stale error visible while they
    // type a correction.
    emit(state.copyWith(name: event.name, clearNameError: true));
  }
 
  void _onPrimaryColorChanged(
    CustomThemeFormPrimaryColorChanged event,
    Emitter<CustomThemeFormState> emit,
  ) {
    emit(state.copyWith(primaryColor: event.color));
  }
 
  void _onBackgroundColorChanged(
    CustomThemeFormBackgroundColorChanged event,
    Emitter<CustomThemeFormState> emit,
  ) {
    emit(state.copyWith(backgroundColor: event.color));
  }
 
  void _onAccentColorChanged(
    CustomThemeFormAccentColorChanged event,
    Emitter<CustomThemeFormState> emit,
  ) {
    emit(state.copyWith(accentColor: event.color));
  }
 
  void _onHeaderImageChanged(
    CustomThemeFormHeaderImageChanged event,
    Emitter<CustomThemeFormState> emit,
  ) {
    emit(state.copyWith(
      headerImagePath: event.imagePath,
      clearHeaderImagePath: event.imagePath == null,
    ));
  }
 
  Future<void> _onSubmitted(
    CustomThemeFormSubmitted event,
    Emitter<CustomThemeFormState> emit,
  ) async {
    final trimmedName = state.name.trim();
    if (trimmedName.isEmpty) {
      emit(state.copyWith(nameError: 'Please enter a theme name'));
      return;
    }
 
    emit(state.copyWith(status: CustomThemeFormStatus.submitting));
 
    final theme = AppThemeData(
      id: state.id,
      name: trimmedName,
      isCustom: true,
      primaryColor: state.primaryColor,
      backgroundColor: state.backgroundColor,
      accentColor: state.accentColor,
      headerImagePath: state.headerImagePath,
    );
 
    final result = await saveCustomTheme(theme);
    result.fold(
      (failure) => emit(state.copyWith(
        status: CustomThemeFormStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: CustomThemeFormStatus.success)),
    );
  }
}
