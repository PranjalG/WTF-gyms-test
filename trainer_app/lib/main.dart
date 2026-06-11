import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trainer_app/services/seed_service.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/hive_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp();

  // Load env vars
  await dotenv.load(fileName: '.env');

  // Init Hive
  await HiveInit.init();
  SeedService.seedIfEmpty();

  runApp(
    const ProviderScope(
      child: TrainerApp(),
    ),
  );
}

class TrainerApp extends ConsumerWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'WTF Gyms — Trainer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
