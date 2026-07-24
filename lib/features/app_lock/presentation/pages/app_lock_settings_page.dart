// lib/features/app_lock/presentation/pages/app_lock_settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/navigation/debounced_tap.dart';
import '../../domain/entities/lock_type.dart';
import '../bloc/lock_bloc.dart';
import '../routing/app_lock_route_paths.dart';
import '../widgets/lock_palette.dart';
import 'pin_lock_screen.dart';
import 'security_question_page.dart';

class _LockOptionData {
  const _LockOptionData({
    required this.type,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.accentSoft,
  });

  final LockType type;
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accent;
  final Color accentSoft;
}

const _options = <_LockOptionData>[
  _LockOptionData(
    type: LockType.none,
    icon: Icons.lock_open_rounded,
    label: 'No Lock',
    subtitle: 'Your diary opens right away',
    accent: Color(0xFF9AA0A8),
    accentSoft: Color(0xFFEDEDF2),
  ),
  _LockOptionData(
    type: LockType.biometric,
    icon: Icons.fingerprint_rounded,
    label: 'Mobile Lock',
    subtitle: 'Use your device face or fingerprint',
    accent: Color(0xFF7C8CFF),
    accentSoft: Color(0xFFE2E6FF),
  ),
  _LockOptionData(
    type: LockType.pin,
    icon: Icons.password_rounded,
    label: 'PIN Lock',
    subtitle: 'Unlock with a 4-digit code',
    accent: Color(0xFFFF6F91),
    accentSoft: Color(0xFFFFDCE5),
  ),
  _LockOptionData(
    type: LockType.securityQuestion,
    icon: Icons.question_answer_rounded,
    label: 'Security Question',
    subtitle: 'Unlock by answering your question',
    accent: Color(0xFFB68CFF),
    accentSoft: Color(0xFFEDE3FF),
  ),
];

class AppLockSettingsPage extends StatefulWidget {
  const AppLockSettingsPage({super.key});

  @override
  State<AppLockSettingsPage> createState() => _AppLockSettingsPageState();
}

class _AppLockSettingsPageState extends State<AppLockSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<LockBloc>().add(const LoadLockConfig());
  }

  Future<void> _onSelectLockType(LockType type) async {
    final bloc = context.read<LockBloc>();
    final currentType = bloc.state.lockType;

    if (type == currentType) return;

    switch (type) {
      case LockType.biometric:
        final succeeded = await _promptBiometric(bloc);
        if (!succeeded) return;
        bloc.add(const SetLockType(type: LockType.biometric));
      case LockType.pin:
        final pin = await context.push<String>(AppLockRoutePaths.pinCreate);
        if (pin == null || !mounted) return;
        bloc.add(SetLockType(type: type, pin: pin));
      case LockType.securityQuestion:
        final result = await context.push<Map<String, String>>(
          AppLockRoutePaths.securityQuestionSetup,
        );
        if (result == null || !mounted) return;
        bloc.add(
          SetLockType(
            type: type,
            question: result['question'],
            answer: result['answer'],
          ),
        );
      case LockType.none:
        bloc.add(const SetLockType(type: LockType.none));
    }
  }

  Future<void> _onToggleBiometricShortcut(bool enabled) async {
    final bloc = context.read<LockBloc>();

    if (enabled) {
      // Confirm biometrics actually work on this device before turning
      // the shortcut on — same reasoning as the primary Mobile Lock
      // option: don't persist a setting that would leave the user
      // unable to unlock via a broken/unavailable prompt. Unlike the
      // primary option, failing here just means the toggle stays off;
      // it doesn't touch lockType at all.
      final succeeded = await _promptBiometric(
        bloc,
        reason: 'Authenticate to enable the biometric shortcut',
      );
      if (!succeeded) return;
    }

    bloc.add(ToggleBiometric(enabled));
  }

  /// Runs the biometric prompt via the bloc's existing verify flow, then
  /// waits for it to settle and reports whether it succeeded. Reuses
  /// VerifyBiometricAttempt instead of adding a separate "checking
  /// biometrics" concept to AppLockState. Shared by both the primary
  /// Mobile Lock option and the secondary biometric-shortcut toggle.
  Future<bool> _promptBiometric(
    LockBloc bloc, {
    String reason = 'Authenticate to enable biometric lock',
  }) async {
    bloc.add(VerifyBiometricAttempt(reason: reason));

    await bloc.stream.firstWhere(
      (state) => state.verificationStatus != VerificationStatus.inProgress,
    );

    final succeeded = bloc.state.verificationStatus == VerificationStatus.success;
    bloc.add(const ResetVerification());

    if (!succeeded && mounted) {
      _showSnackBar('Biometric not supported on this device or authentication failed.');
    }
    return succeeded;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text('Secure your thoughts'),
        leading: context.canPop() == true
            ? BackButton(onPressed: () => context.pop())
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerHighest,
              colorScheme.surface,
            ],
          ),
        ),
        child: BlocConsumer<LockBloc, AppLockState>(
          listener: (context, state) {
            if (state.loadError != null) {
              _showSnackBar('Error: ${state.loadError}');
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: colorScheme.onSurface),
              );
            }

            // The "also allow biometric" shortcut only makes sense once
            // a PIN or Security Question is the primary method —
            // LockType.biometric is already biometric-only, and
            // LockType.none has nothing to shortcut into.
            final showsBiometricToggle =
                state.lockType == LockType.pin || state.lockType == LockType.securityQuestion;

            return SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  Expanded(
                    child: ClipPath(
                      clipper: const CloudTopClipper(),
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(20, 42, 20, 20),
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            for (final option in _options) ...[
                              _LockOptionTile(
                                data: option,
                                selected: state.lockType == option.type,
                                onTap: () => _onSelectLockType(option.type),
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (showsBiometricToggle) ...[
                              const SizedBox(height: 6),
                              _BiometricShortcutToggle(
                                enabled: state.biometricEnabled,
                                onChanged: _onToggleBiometricShortcut,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LockOptionTile extends StatelessWidget {
  const _LockOptionTile({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _LockOptionData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // DebouncedTap instead of a raw InkWell/Material — same rationale
    // as every other tappable list item in the app (see
    // core/navigation/debounced_tap.dart): a fast double-tap here would
    // otherwise be able to push the PIN-create / security-question-setup
    // route twice before the first transition finishes.
    return DebouncedTap(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? data.accentSoft : const Color(0xFFFAFAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? data.accent.withValues(alpha: 0.5) : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: Icon(data.icon, color: data.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: LockPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: const TextStyle(fontSize: 12.5, color: LockPalette.inkSoft),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(shape: BoxShape.circle, color: data.accent),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              )
            else
              Icon(Icons.chevron_right_rounded, color: LockPalette.inkSoft.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

/// The "also allow biometric" row — shown only when the primary lock
/// type is PIN or Security Question (see showsBiometricToggle above).
/// A switch, not a pushable tile: there's nothing to navigate to, it's
/// a direct on/off setting.
class _BiometricShortcutToggle extends StatelessWidget {
  const _BiometricShortcutToggle({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  static const _accent = Color(0xFF7C8CFF); // matches Mobile Lock's accent

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: const Icon(Icons.fingerprint_rounded, color: _accent, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric Shortcut',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LockPalette.ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Also allow face or fingerprint to unlock',
                  style: TextStyle(fontSize: 12.5, color: LockPalette.inkSoft),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeColor: _accent,
          ),
        ],
      ),
    );
  }
}