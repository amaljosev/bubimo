// lib/main.dart

import 'package:bubimo/core/config/secrets.dart';
import 'package:bubimo/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection.dart';
import 'features/app_lock/presentation/bloc/lock_bloc.dart';
import 'features/theme/presentation/cubit/app_theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Secrets.supabaseUrl,
    publishableKey: Secrets.supabaseAnonKey,
  );

  await configureDependencies();

  // Load the user's previously selected theme before the first frame,
  // so the app doesn't flash the fallback default theme on launch.
  await getIt<AppThemeCubit>().loadInitialTheme();

  // Load the persisted app-lock config before the first frame too, and
  // AWAIT it — appRouter's `redirect` (see lockRedirect in
  // app_router.dart) reads LockBloc.state synchronously on every
  // navigation, so it must already reflect the real lock type instead
  // of LockState.initial()'s `isLoading: false, lockType: none` before
  // GoRouter's very first redirect evaluation runs. Awaiting the
  // stream here (rather than firing LoadLockConfig and moving on, the
  // way AppThemeCubit's loadInitialTheme is itself awaited above) means
  // by the time runApp() executes, LockBloc.state.isLoading is already
  // back to false and lockType/isLocked are correct.
  // isColdStart: true is essential here — it's what tells LockBloc
  // this load should derive `isLocked` from whether a lock type is
  // configured. Any OTHER place that dispatches LoadLockConfig (e.g.
  // AppLockSettingsPage refreshing on mount) must NOT pass true, or it
  // would re-lock an already-unlocked session. See LoadLockConfig's
  // doc comment in lock_event.dart.
  getIt<LockBloc>().add(const LoadLockConfig(isColdStart: true));
  await getIt<LockBloc>().stream.firstWhere((state) => !state.isLoading);

  // Initialize local notifications (channel setup, timezone data,
  // permission request) before any reminder can be scheduled.
  //await getIt<LocalNotificationService>().initialize();

  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppThemeCubit>.value(value: getIt<AppThemeCubit>()),
        // Provided at the app root (not just inside individual
        // app_lock routes) because LockGate, the settings page, and
        // appRouter's `redirect` callback (which reads
        // getIt<LockBloc>() directly, not via context) all need the
        // one shared LockBloc instance loaded above.
        BlocProvider<LockBloc>.value(value: getIt<LockBloc>()),
      ],
      child: BlocBuilder<AppThemeCubit, ThemeData>(
        builder: (context, themeData) {
          return MaterialApp.router(
            title: 'Diary',
            debugShowCheckedModeBanner: false,
            theme: themeData,
            routerConfig: appRouter,
            localizationsDelegates: const [
              FlutterQuillLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}