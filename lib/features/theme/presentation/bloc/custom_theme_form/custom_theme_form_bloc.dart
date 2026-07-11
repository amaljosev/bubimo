// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/built_in_themes.dart';
import '../../../../../core/utils/id_generator.dart';
import '../../../domain/entities/app_theme_data.dart';
import '../../../domain/entities/rgba_color.dart';
import '../../../domain/entities/theme_palette.dart';
import '../../../domain/entities/theme_type.dart';
import '../../../domain/usecases/save_custom_theme.dart';
import '../../cubit/app_theme_cubit.dart';

part 'custom_theme_form_event.dart';
part 'custom_theme_form_state.dart';

/// Drives the Create/Edit Custom Theme screen.
///
/// Every field change (color, font, header image, name, dark mode)
/// updates state synchronously so the live Home Screen preview
/// re-renders immediately — no debouncing, since these are simple
/// in-memory field updates, not network/database calls.
///
/// Holds a full palette for EACH mode ([CustomThemeFormState.lightPalette]
/// / [CustomThemeFormState.darkPalette]) so toggling Dark Mode recalls
/// that mode's own colors instead of discarding whichever mode isn't
/// currently active.
///
/// [appThemeCubit] is used only when editing a theme that's currently
/// the app's active theme: on a successful save, the change is applied
/// live immediately, so the user doesn't need a separate "Apply Theme"
/// step after "Update Theme" (see [_onSubmitted]).
class CustomThemeFormBloc
    extends Bloc<CustomThemeFormEvent, CustomThemeFormState> {
  final SaveCustomTheme saveCustomTheme;
  final AppThemeCubit appThemeCubit;

  CustomThemeFormBloc({
    required this.saveCustomTheme,
    required this.appThemeCubit,
  }) : super(CustomThemeFormState()) {
    on<CustomThemeFormInitialized>(_onInitialized);
    on<CustomThemeFormInitializedForEdit>(_onInitializedForEdit);
    on<CustomThemeNameChanged>(
      (e, emit) => emit(state.copyWith(name: e.name)),
    );
    on<CustomThemePrimaryColorChanged>(
      (e, emit) => emit(
        state.copyWithActivePaletteColor(primaryColor: e.color),
      ),
    );
    on<CustomThemeSecondaryColorChanged>(
      (e, emit) => emit(
        state.copyWithActivePaletteColor(secondaryColor: e.color),
      ),
    );
    on<CustomThemeSurfaceColorChanged>(
      (e, emit) => emit(
        state.copyWithActivePaletteColor(surfaceColor: e.color),
      ),
    );
    on<CustomThemeBackgroundColorChanged>(
      (e, emit) => emit(
        state.copyWithActivePaletteColor(backgroundColor: e.color),
      ),
    );
    on<CustomThemeTextColorChanged>(
      (e, emit) => emit(
        state.copyWithActivePaletteColor(textColor: e.color),
      ),
    );
    on<CustomThemeDarkModeToggled>(_onDarkModeToggled);
    on<CustomThemeFontChanged>(
      (e, emit) => emit(state.copyWith(fontFamily: e.fontFamily)),
    );
    on<CustomThemeHeaderImagePicked>(
      (e, emit) => emit(state.copyWith(headerImagePath: e.imagePath)),
    );
    on<CustomThemeHeaderImageCleared>(
      (e, emit) => emit(state.copyWith(clearHeaderImage: true)),
    );
    on<CustomThemeColorsReset>(_onColorsReset);
    on<CustomThemeFormSubmitted>(_onSubmitted);
  }

  /// Toggling Light/Dark Mode switches which palette is active. If this
  /// theme already has its OWN saved colors for the newly-selected mode
  /// (i.e. it's being edited and [AppThemeData.lightPalette] /
  /// [AppThemeData.darkPalette] was populated at load time), those are
  /// shown — the user's own prior customization for that mode is never
  /// silently discarded. Only when the theme has never had a palette
  /// for that mode (a brand-new theme, or one only ever edited in the
  /// other mode) does it fall back to Dusk's/Nightfall's defaults,
  /// which is what [CustomThemeFormState]'s own built-in defaults
  /// already provide.
  void _onDarkModeToggled(
    CustomThemeDarkModeToggled event,
    Emitter<CustomThemeFormState> emit,
  ) {
    emit(state.copyWith(isDark: event.isDark));
  }

  /// Resets the CURRENT mode's palette back to that mode's default
  /// colors (Dusk's for Light Mode, Nightfall's for Dark Mode), without
  /// touching [CustomThemeFormState.isDark] or the OTHER mode's
  /// palette. This is the explicit "Reset Colors" action, always
  /// available on the form (not just when there's a contrast warning),
  /// distinct from switching modes, which never resets anything on its
  /// own (see [_onDarkModeToggled]).
  void _onColorsReset(
    CustomThemeColorsReset event,
    Emitter<CustomThemeFormState> emit,
  ) {
    final defaults = _defaultPaletteFor(state.isDark);
    emit(
      state.isDark
          ? state.copyWith(darkPalette: defaults)
          : state.copyWith(lightPalette: defaults),
    );
  }

  /// The default color palette for a given mode: [BuiltInThemes.dusk]
  /// for Light Mode, [BuiltInThemes.nightfall] for Dark Mode — the
  /// app's own default light/dark built-in themes, so this form's
  /// "reset" always lands on the same known-good, already
  /// contrast-validated colors used elsewhere in the app, rather than
  /// a separately hand-picked palette that could drift out of sync.
  ThemePalette _defaultPaletteFor(bool isDark) {
    final source = isDark ? BuiltInThemes.nightfall : BuiltInThemes.dusk;
    return source.activePalette;
  }

  void _onInitialized(
    CustomThemeFormInitialized event,
    Emitter<CustomThemeFormState> emit,
  ) {
    final d = event.defaultTheme;
    emit(
      state.copyWith(
        status: CustomThemeFormStatus.ready,
        isDark: d.isDark,
        lightPalette: d.isDark ? _defaultPaletteFor(false) : d.activePalette,
        darkPalette: d.isDark ? d.activePalette : _defaultPaletteFor(true),
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
        isDark: t.isDark,
        // Prefer the theme's OWN saved palette for each mode; fall
        // back to Dusk/Nightfall defaults for whichever mode it has
        // never been saved in yet.
        lightPalette: t.lightPalette ?? _defaultPaletteFor(false),
        darkPalette: t.darkPalette ?? _defaultPaletteFor(true),
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

    final themeId = state.editingThemeId ?? IdGenerator.generate();

    final theme = AppThemeData(
      id: themeId,
      name: state.name.trim(),
      type: state.headerImagePath != null
          ? ThemeType.colorsAndFontWithHeaderImage
          : ThemeType.colorsAndFont,
      primaryColor: state.primaryColor,
      secondaryColor: state.secondaryColor,
      surfaceColor: state.surfaceColor,
      backgroundColor: state.backgroundColor,
      textColor: state.textColor,
      isDark: state.isDark,
      fontFamily: state.fontFamily,
      headerImagePath: state.headerImagePath,
      isHeaderImageAsset: false,
      isBuiltIn: false,
      lightPalette: state.lightPalette,
      darkPalette: state.darkPalette,
    );

    final result = await saveCustomTheme(theme);

    final failure = result.match((f) => f, (_) => null);
    if (failure != null) {
      emit(
        state.copyWith(
          status: CustomThemeFormStatus.failure,
          errorMessage: failure.message,
        ),
      );
      return;
    }

    // If the theme being edited is the one currently applied app-wide,
    // re-apply it immediately so the change is reflected live — the
    // user shouldn't have to separately press "Apply Theme" after
    // "Update Theme" for a theme that's already active. Any failure
    // here is silent: the save itself already succeeded, and the next
    // app-wide theme load will pick up the new colors regardless.
    if (state.isEditing && appThemeCubit.currentTheme?.id == themeId) {
      await appThemeCubit.changeTheme(themeId);
    }

    emit(state.copyWith(status: CustomThemeFormStatus.success));
  }
}