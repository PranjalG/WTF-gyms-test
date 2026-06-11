import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guru_app/services/seed_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/hive_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load env vars
  await dotenv.load(fileName: '.env');

  // Init Hive
  await HiveInit.init();
  SeedService.seedIfEmpty();

  runApp(
    const ProviderScope(
      child: GuruApp(),
    ),
  );
}

class GuruApp extends ConsumerWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'WTF Gyms — Guru',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
