// lib/features/theme/presentation/bloc/custom_theme_form/custom_theme_form_state.dart

import 'package:equatable/equatable.dart';

import '../../../domain/entities/rgba_color.dart';

enum CustomThemeFormStatus { initial, ready, submitting, success, failure }

class CustomThemeFormState extends Equatable {
  final CustomThemeFormStatus status;

  /// Non-null once editing an existing custom theme — `null` in create
  /// mode. Kept as the id string (not a bool flag) so the bloc's submit
  /// handler can build the correct [AppThemeData.id] for the upsert.
  final String? editingThemeId;

  final String name;
  final RgbaColor primaryColor;
  final RgbaColor backgroundColor;
  final RgbaColor accentColor;
  final String fontFamily;
  final String? headerImagePath;

  final String? errorMessage;

  const CustomThemeFormState({
    this.status = CustomThemeFormStatus.initial,
    this.editingThemeId,
    this.name = '',
    this.primaryColor = const RgbaColor(red: 103, green: 80, blue: 164),
    this.backgroundColor = const RgbaColor(red: 255, green: 251, blue: 254),
    this.accentColor = const RgbaColor(red: 125, green: 82, blue: 96),
    this.fontFamily = 'Poppins',
    this.headerImagePath,
    this.errorMessage,
  });

  bool get isEditing => editingThemeId != null;
  bool get isSubmitting => status == CustomThemeFormStatus.submitting;
  bool get canSubmit => name.trim().isNotEmpty && !isSubmitting;

  CustomThemeFormState copyWith({
    CustomThemeFormStatus? status,
    String? editingThemeId,
    String? name,
    RgbaColor? primaryColor,
    RgbaColor? backgroundColor,
    RgbaColor? accentColor,
    String? fontFamily,
    String? headerImagePath,
    bool clearHeaderImage = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomThemeFormState(
      status: status ?? this.status,
      editingThemeId: editingThemeId ?? this.editingThemeId,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      fontFamily: fontFamily ?? this.fontFamily,
      headerImagePath: clearHeaderImage
          ? null
          : (headerImagePath ?? this.headerImagePath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        editingThemeId,
        name,
        primaryColor,
        backgroundColor,
        accentColor,
        fontFamily,
        headerImagePath,
        errorMessage,
      ];
}
