// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/theme/presentation/cubit/app_theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  // Loaded once, here, before the first frame — so the app never
  // flashes AppThemeCubit's ThemeData.light() fallback before the
  // user's actual selected theme (default or custom) is available.
  // AppThemeCubit is a GetIt lazy singleton (see injection.dart), so
  // this is the same instance BlocProvider.value below hands to the
  // widget tree — loading it here, not in a widget's initState, keeps
  // "load on startup" a main()-level concern rather than tying it to
  // any particular widget's lifecycle.
  await getIt<AppThemeCubit>().loadInitialTheme();

  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider.value (not BlocProvider(create: ...)) since
    // AppThemeCubit is already constructed and loaded above — this
    // widget just hands the existing GetIt singleton to the tree, it
    // doesn't own the Cubit's lifecycle (GetIt does, for the app's
    // full lifetime).
    return BlocProvider<AppThemeCubit>.value(
      value: getIt<AppThemeCubit>(),
      child: BlocBuilder<AppThemeCubit, ThemeData>(
        builder: (context, themeData) {
          return MaterialApp.router(
            title: 'Diary',
            debugShowCheckedModeBanner: false,
            theme: themeData,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}