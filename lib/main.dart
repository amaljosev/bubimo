// lib/main.dart

import 'package:bubimo/core/config/secrets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/reminders/data/datasources/local_notification_service.dart';
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

  // Initialize local notifications (channel setup, timezone data,
  // permission request) before any reminder can be scheduled.
  await getIt<LocalNotificationService>().initialize();

  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppThemeCubit>.value(
      value: getIt<AppThemeCubit>(),
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