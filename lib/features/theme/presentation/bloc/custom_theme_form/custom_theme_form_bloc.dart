// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/id_generator.dart';
import '../../../domain/entities/app_theme_data.dart';
import '../../../domain/usecases/save_custom_theme.dart';
import 'custom_theme_form_event.dart';
import 'custom_theme_form_state.dart';

/// Handles the Custom Theme Screen's form. Validates that a name was
/// entered before allowing save, and guards against duplicate
/// submissions from rapid repeated taps.
class CustomThemeFormBloc
    extends Bloc<CustomThemeFormEvent, CustomThemeFormState> {
  final SaveCustomTheme saveCustomTheme;

  CustomThemeFormBloc({required this.saveCustomTheme})
      : super(const CustomThemeFormState()) {
    on<CustomThemeNameChanged>(
      (event, emit) => emit(state.copyWith(name: event.name)),
    );
    on<CustomThemePrimaryColorChanged>(
      (event, emit) =>
          emit(state.copyWith(primaryColor: event.hexColor)),
    );
    on<CustomThemeBackgroundColorChanged>(
      (event, emit) =>
          emit(state.copyWith(backgroundColor: event.hexColor)),
    );
    on<CustomThemeAccentColorChanged>(
      (event, emit) =>
          emit(state.copyWith(accentColor: event.hexColor)),
    );
    on<CustomThemeFontChanged>(
      (event, emit) => emit(state.copyWith(fontFamily: event.fontFamily)),
    );
    on<CustomThemeHeaderImagePicked>(
      (event, emit) =>
          emit(state.copyWith(headerImagePath: event.imagePath)),
    );
    on<CustomThemeHeaderImageCleared>(
      (event, emit) => emit(state.copyWith(clearHeaderImage: true)),
    );
    on<CustomThemeFormSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CustomThemeFormSubmitted event,
    Emitter<CustomThemeFormState> emit,
  ) async {
    // Guard against duplicate submissions from rapid repeated taps.
    if (state.isSubmitting) return;

    if (state.name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: CustomThemeFormStatus.failure,
          errorMessage: 'Please give your theme a name.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: CustomThemeFormStatus.submitting));

    final theme = AppThemeData(
      id: IdGenerator.generate(),
      name: state.name.trim(),
      isCustom: true,
      primaryColor: state.primaryColor,
      backgroundColor: state.backgroundColor,
      accentColor: state.accentColor,
      fontFamily: state.fontFamily,
      headerImagePath: state.headerImagePath,
    );

    final result = await saveCustomTheme(theme);

    result.match(
      (failure) => emit(
        state.copyWith(
          status: CustomThemeFormStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: CustomThemeFormStatus.success)),
    );
  }
}