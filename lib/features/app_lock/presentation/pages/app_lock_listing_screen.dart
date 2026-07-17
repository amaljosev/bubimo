// lib/features/app_lock/presentation/pages/app_lock_listing_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../domain/entities/lock_method.dart';
import '../bloc/settings_bloc/app_lock_settings_bloc.dart';
import '../widgets/lock_method_tile.dart';

/// The app lock settings/listing page. Shows every available lock
/// method, highlights whichever is currently active, and lets the
/// user turn the lock off entirely.
///
/// Tapping a method that's already configured activates it directly.
/// Tapping one that isn't configured yet navigates to its setup route
/// via GoRouter (context.push) — NOT Navigator.pushNamed, since this
/// app has no onGenerateRoute / named-route table registered.
///
/// Expects an [AppLockSettingsBloc] to already be provided above it in
/// the tree — the GoRoute in app_router.dart provides one (see
/// AppRoutes.lockListing), so this widget does NOT wrap itself in its
/// own BlocProvider.
class AppLockListingScreen extends StatelessWidget {
  const AppLockListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppLockListingView();
  }
}

class _AppLockListingView extends StatelessWidget {
  const _AppLockListingView();

  static const _methods = [
    LockMethod.biometric,
    LockMethod.pin,
    LockMethod.pattern,
    LockMethod.deviceCredential,
  ];

  void _onMethodTapped(
    BuildContext context,
    AppLockSettingsLoaded state,
    LockMethod method,
  ) {
    if (state.activeMethod == method) return;

    if (state.isConfigured(method) &&
        (method == LockMethod.pin || method == LockMethod.pattern)) {
      // Already has a stored PIN/pattern — activate directly.
      context.read<AppLockSettingsBloc>().add(ActivateConfiguredMethod(method));
      return;
    }

    switch (method) {
      case LockMethod.pin:
        context.push(AppRoutes.setupPin);
        break;
      case LockMethod.pattern:
        context.push(AppRoutes.setupPattern);
        break;
      case LockMethod.biometric:
        context.push(AppRoutes.setupBiometric);
        break;
      case LockMethod.deviceCredential:
        context.push(AppRoutes.setupDeviceCredential);
        break;
      case LockMethod.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Lock')),
      body: BlocConsumer<AppLockSettingsBloc, AppLockSettingsState>(
        listener: (context, state) {
          if (state is AppLockSettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AppLockSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! AppLockSettingsLoaded) {
            return const SizedBox.shrink();
          }

          final isLockOn = state.activeMethod != LockMethod.none;
          final visibleMethods =
              _methods.where((method) => state.isVisible(method)).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              SwitchListTile(
                title: const Text('App Lock'),
                subtitle: Text(
                  isLockOn
                      ? 'Locked with ${state.activeMethod.label}'
                      : 'Off',
                ),
                value: isLockOn,
                onChanged: (value) {
                  if (!value) {
                    context.read<AppLockSettingsBloc>().add(
                          const TurnOffAppLock(),
                        );
                  } else {
                    context.push(AppRoutes.setupPin);
                  }
                },
              ),
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'LOCK METHOD',
                  style: TextStyle(fontSize: 12, letterSpacing: 0.5),
                ),
              ),
              for (final method in visibleMethods)
                LockMethodTile(
                  method: method,
                  isSelected: state.activeMethod == method,
                  isConfigured: state.isConfigured(method),
                  onTap: () => _onMethodTapped(context, state, method),
                ),
            ],
          );
        },
      ),
    );
  }
}