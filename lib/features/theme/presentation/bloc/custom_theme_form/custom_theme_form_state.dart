// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_state.dart

import 'package:equatable/equatable.dart';

enum CustomThemeFormStatus { initial, submitting, success, failure }

class CustomThemeFormState extends Equatable {
  final CustomThemeFormStatus status;
  final String name;
  final String primaryColor;
  final String backgroundColor;
  final String accentColor;
  final String? headerImagePath;
  final String? errorMessage;

  const CustomThemeFormState({
    this.status = CustomThemeFormStatus.initial,
    this.name = '',
    this.primaryColor = '#6750A4',
    this.backgroundColor = '#FFFBFE',
    this.accentColor = '#7D5260',
    this.headerImagePath,
    this.errorMessage,
  });

  bool get isSubmitting => status == CustomThemeFormStatus.submitting;

  CustomThemeFormState copyWith({
    CustomThemeFormStatus? status,
    String? name,
    String? primaryColor,
    String? backgroundColor,
    String? accentColor,
    String? headerImagePath,
    String? errorMessage,
  }) {
    return CustomThemeFormState(
      status: status ?? this.status,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      headerImagePath: headerImagePath ?? this.headerImagePath,
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
        headerImagePath,
        errorMessage,
      ];
}