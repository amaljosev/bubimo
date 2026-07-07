// lib/features/theme/presentation/pages/custom_theme_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/built_in_themes.dart';
import '../../domain/entities/app_theme_data.dart';
import '../bloc/custom_theme_form/custom_theme_form_bloc.dart';
import '../bloc/custom_theme_form/custom_theme_form_event.dart';
import '../bloc/custom_theme_form/custom_theme_form_state.dart';
import '../widgets/custom_theme_form/color_field_tile.dart';
import '../widgets/custom_theme_form/font_picker_sheet.dart';
import '../widgets/custom_theme_form/header_image_picker_field.dart';
import '../widgets/custom_theme_form/home_preview_card.dart';
import '../widgets/custom_theme_form/theme_name_field.dart';

/// Create/Edit Custom Theme screen.
///
/// Pass [existingTheme] to open in EDIT mode (pre-fills every field and
/// upserts the same theme id on save); omit it for CREATE mode, where
/// every color field is initialized from
/// [BuiltInThemes.defaultTheme]'s colors per spec.
///
/// The live Home Screen preview at the top is a pure function of the
/// bloc's current [CustomThemeFormState] — it re-renders on every field
/// change, and intentionally never touches [AppThemeCubit]/the app's
/// real theme (see `HomePreviewCard`'s doc comment): saving here never
/// auto-applies the theme.
class CustomThemeScreen extends StatelessWidget {
  final AppThemeData? existingTheme;

  const CustomThemeScreen({super.key, this.existingTheme});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<CustomThemeFormBloc>();
        final theme = existingTheme;
        if (theme != null) {
          bloc.add(CustomThemeFormInitializedForEdit(theme));
        } else {
          bloc.add(CustomThemeFormInitialized(BuiltInThemes.defaultTheme));
        }
        return bloc;
      },
      child: _CustomThemeScreenView(isEditing: existingTheme != null),
    );
  }
}

class _CustomThemeScreenView extends StatefulWidget {
  final bool isEditing;

  const _CustomThemeScreenView({required this.isEditing});

  @override
  State<_CustomThemeScreenView> createState() =>
      _CustomThemeScreenViewState();
}

class _CustomThemeScreenViewState extends State<_CustomThemeScreenView> {
  late final TextEditingController _nameController;
  final ScrollController _scrollController = ScrollController();
  bool _initializedController = false;

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPreview() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openFontPicker(BuildContext context, String current) async {
    final picked = await FontPickerSheet.show(context, selectedFont: current);
    if (picked != null && context.mounted) {
      context.read<CustomThemeFormBloc>().add(CustomThemeFontChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomThemeFormBloc, CustomThemeFormState>(
      listener: (context, state) {
        if (!_initializedController &&
            state.status != CustomThemeFormStatus.initial) {
          _nameController = TextEditingController(text: state.name);
          _initializedController = true;
        }

        if (state.status == CustomThemeFormStatus.success) {
          context.pop(true);
        }
        if (state.status == CustomThemeFormStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        if (!_initializedController) {
          // First build before the initializing event has been
          // processed — render a lightweight loading state rather than
          // constructing the controller with stale/default text.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.isEditing ? 'Edit Theme' : 'Create Custom Theme'),
            actions: [
              IconButton(
                tooltip: 'Scroll to preview',
                icon: const Icon(Icons.arrow_upward),
                onPressed: _scrollToPreview,
              ),
            ],
          ),
          body: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              HomePreviewCard(
                primaryColor: state.primaryColor,
                backgroundColor: state.backgroundColor,
                accentColor: state.accentColor,
                fontFamily: state.fontFamily,
                headerImagePath: state.headerImagePath,
                themeName: state.name,
              ),
              const SizedBox(height: 24),
              ThemeNameField(
                controller: _nameController,
                onChanged: (value) => context
                    .read<CustomThemeFormBloc>()
                    .add(CustomThemeNameChanged(value)),
              ),
              const SizedBox(height: 20),
              HeaderImagePickerField(
                imagePath: state.headerImagePath,
                onImagePicked: (path) => context
                    .read<CustomThemeFormBloc>()
                    .add(CustomThemeHeaderImagePicked(path)),
                onImageRemoved: () => context
                    .read<CustomThemeFormBloc>()
                    .add(const CustomThemeHeaderImageCleared()),
              ),
              const SizedBox(height: 20),
              ColorFieldTile(
                label: 'Primary color',
                color: state.primaryColor,
                onChanged: (color) => context
                    .read<CustomThemeFormBloc>()
                    .add(CustomThemePrimaryColorChanged(color)),
              ),
              const Divider(height: 1),
              ColorFieldTile(
                label: 'Background color',
                color: state.backgroundColor,
                onChanged: (color) => context
                    .read<CustomThemeFormBloc>()
                    .add(CustomThemeBackgroundColorChanged(color)),
              ),
              const Divider(height: 1),
              ColorFieldTile(
                label: 'Accent color',
                color: state.accentColor,
                onChanged: (color) => context
                    .read<CustomThemeFormBloc>()
                    .add(CustomThemeAccentColorChanged(color)),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Font'),
                subtitle: Text(state.fontFamily),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openFontPicker(context, state.fontFamily),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: state.canSubmit
                    ? () => context
                        .read<CustomThemeFormBloc>()
                        .add(const CustomThemeFormSubmitted())
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEditing ? 'Update Theme' : 'Save Theme'),
              ),
            ],
          ),
        );
      },
    );
  }
}
