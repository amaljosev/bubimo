
// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_state.dart

part of 'custom_theme_form_bloc.dart';


enum CustomThemeFormStatus { initial, submitting, success, failure }

/// State for the Custom Theme Screen's form.
///
/// Same Bloc/state handles both create and edit — pass an existing
/// [AppThemeData] in on construction (see `CustomThemeFormBloc`'s
/// constructor) to seed `id`/`name`/colors/`headerImagePath`; omit it to
/// create a new one, mirroring `DiaryFormBloc`'s create-vs-edit pattern.
///
/// `id` is empty string for a brand-new (not-yet-saved) custom theme —
/// `ThemeLocalDataSourceImpl.saveCustomTheme` already generates an id in
/// that case, so the form doesn't need to invent one itself.
class CustomThemeFormState extends Equatable {
  final CustomThemeFormStatus status;
  final String id;
  final String name;
  final Color primaryColor;
  final Color backgroundColor;
  final Color accentColor;
  final String? headerImagePath;

  /// Non-null once a submit has been attempted with an invalid name —
  /// shown as the `TextField`'s `errorText`. Stays `null` while the user
  /// is still typing, so the error doesn't appear before they've had a
  /// chance to enter anything (only surfaces on a failed Save attempt).
  final String? nameError;

  final String? errorMessage;

  const CustomThemeFormState({
    this.status = CustomThemeFormStatus.initial,
    this.id = '',
    this.name = '',
    this.primaryColor = const Color(0xFF3F51B5),
    this.backgroundColor = const Color(0xFFFAFAFC),
    this.accentColor = const Color(0xFFFF7043),
    this.headerImagePath,
    this.nameError,
    this.errorMessage,
  });

  bool get isEditing => id.isNotEmpty;

  CustomThemeFormState copyWith({
    CustomThemeFormStatus? status,
    String? id,
    String? name,
    Color? primaryColor,
    Color? backgroundColor,
    Color? accentColor,
    String? headerImagePath,
    bool clearHeaderImagePath = false,
    String? nameError,
    bool clearNameError = false,
    String? errorMessage,
  }) {
    return CustomThemeFormState(
      status: status ?? this.status,
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      headerImagePath: clearHeaderImagePath
          ? headerImagePath
          : (headerImagePath ?? this.headerImagePath),
      nameError: clearNameError ? null : (nameError ?? this.nameError),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        id,
        name,
        primaryColor,
        backgroundColor,
        accentColor,
        headerImagePath,
        nameError,
        errorMessage,
      ];
}