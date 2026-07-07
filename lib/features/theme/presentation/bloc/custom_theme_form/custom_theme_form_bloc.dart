// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/id_generator.dart';
import '../../../domain/entities/app_theme_data.dart';
import '../../../domain/entities/theme_type.dart';
import '../../../domain/usecases/save_custom_theme.dart';
import 'custom_theme_form_event.dart';
import 'custom_theme_form_state.dart';

/// Drives the Create/Edit Custom Theme screen.
///
/// Every field change (color, font, header image, name) updates state
/// synchronously so the live Home Screen preview re-renders immediately
/// — no debouncing, since these are simple in-memory field updates, not
/// network/database calls.
class CustomThemeFormBloc
    extends Bloc<CustomThemeFormEvent, CustomThemeFormState> {
  final SaveCustomTheme saveCustomTheme;

  CustomThemeFormBloc({required this.saveCustomTheme})
      : super(const CustomThemeFormState()) {
    on<CustomThemeFormInitialized>(_onInitialized);
    on<CustomThemeFormInitializedForEdit>(_onInitializedForEdit);
    on<CustomThemeNameChanged>(
      (e, emit) => emit(state.copyWith(name: e.name)),
    );
    on<CustomThemePrimaryColorChanged>(
      (e, emit) => emit(state.copyWith(primaryColor: e.color)),
    );
    on<CustomThemeBackgroundColorChanged>(
      (e, emit) => emit(state.copyWith(backgroundColor: e.color)),
    );
    on<CustomThemeAccentColorChanged>(
      (e, emit) => emit(state.copyWith(accentColor: e.color)),
    );
    on<CustomThemeFontChanged>(
      (e, emit) => emit(state.copyWith(fontFamily: e.fontFamily)),
    );
    on<CustomThemeHeaderImagePicked>(
      (e, emit) => emit(state.copyWith(headerImagePath: e.imagePath)),
    );
    on<CustomThemeHeaderImageCleared>(
      (e, emit) => emit(state.copyWith(clearHeaderImage: true)),
    );
    on<CustomThemeFormSubmitted>(_onSubmitted);
  }

  void _onInitialized(
    CustomThemeFormInitialized event,
    Emitter<CustomThemeFormState> emit,
  ) {
    final d = event.defaultTheme;
    emit(
      state.copyWith(
        status: CustomThemeFormStatus.ready,
        primaryColor: d.primaryColor,
        backgroundColor: d.backgroundColor,
        accentColor: d.accentColor,
        fontFamily: d.fontFamily,
      ),
    );
  }

  void _onInitializedForEdit(
    CustomThemeFormInitializedForEdit event,
    Emitter<CustomThemeFormState> emit,
  ) {
    final t = event.existingTheme;
    emit(
      state.copyWith(
        status: CustomThemeFormStatus.ready,
        editingThemeId: t.id,
        name: t.name,
        primaryColor: t.primaryColor,
        backgroundColor: t.backgroundColor,
        accentColor: t.accentColor,
        fontFamily: t.fontFamily,
        headerImagePath: t.headerImagePath,
      ),
    );
  }

  Future<void> _onSubmitted(
    CustomThemeFormSubmitted event,
    Emitter<CustomThemeFormState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: CustomThemeFormStatus.submitting, clearError: true));

    final theme = AppThemeData(
      id: state.editingThemeId ?? IdGenerator.generate(),
      name: state.name.trim(),
      type: state.headerImagePath != null
          ? ThemeType.colorsAndFontWithHeaderImage
          : ThemeType.colorsAndFont,
      primaryColor: state.primaryColor,
      backgroundColor: state.backgroundColor,
      accentColor: state.accentColor,
      fontFamily: state.fontFamily,
      headerImagePath: state.headerImagePath,
      isHeaderImageAsset: false,
      isBuiltIn: false,
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
