// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_state.dart

import 'package:equatable/equatable.dart';

enum CustomThemeFormStatus { initial, submitting, success, failure }

class CustomThemeFormState extends Equatable {
  final CustomThemeFormStatus status;
  final String name;
  final String primaryColor;
  final String backgroundColor;
  final String accentColor;
  final String fontFamily;
  final String? headerImagePath;
  final String? errorMessage;

  const CustomThemeFormState({
    this.status = CustomThemeFormStatus.initial,
    this.name = '',
    this.primaryColor = '#6750A4',
    this.backgroundColor = '#FFFBFE',
    this.accentColor = '#7D5260',
    this.fontFamily = 'Poppins',
    this.headerImagePath,
    this.errorMessage,
  });

  bool get isSubmitting => status == CustomThemeFormStatus.submitting;

  /// [clearHeaderImage] exists because the ordinary
  /// `headerImagePath ?? this.headerImagePath` pattern below can never
  /// express "set it back to null" — passing `null` for `headerImagePath`
  /// just falls through to the existing value. Set `clearHeaderImage:
  /// true` (and leave `headerImagePath` unset) to explicitly remove the
  /// picked image, e.g. from the form's "remove image" action.
  CustomThemeFormState copyWith({
    CustomThemeFormStatus? status,
    String? name,
    String? primaryColor,
    String? backgroundColor,
    String? accentColor,
    String? fontFamily,
    String? headerImagePath,
    bool clearHeaderImage = false,
    String? errorMessage,
  }) {
    return CustomThemeFormState(
      status: status ?? this.status,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      fontFamily: fontFamily ?? this.fontFamily,
      headerImagePath:
          clearHeaderImage ? null : (headerImagePath ?? this.headerImagePath),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        name,
        primaryColor,
        backgroundColor,
        accentColor,
        fontFamily,
        headerImagePath,
        errorMessage,
      ];
}