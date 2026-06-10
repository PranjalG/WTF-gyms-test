import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// TODO Phase 2: replace with real auth check
final _isLoggedIn = false;
final _hasCompletedOnboarding = false;

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: _isLoggedIn ? '/home' : '/onboarding',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const _PlaceholderScreen(title: 'Onboarding — DK'),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const _PlaceholderScreen(title: 'Home — DK'),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const _PlaceholderScreen(title: 'Chat List'),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Chat: ${state.pathParameters['chatId']}',
        ),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const _PlaceholderScreen(title: 'Schedule a Call'),
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const _PlaceholderScreen(title: 'My Sessions'),
      ),
      GoRoute(
        path: '/call/prejoin',
        builder: (context, state) => const _PlaceholderScreen(title: 'Pre-Join Check'),
      ),
      GoRoute(
        path: '/call/room',
        builder: (context, state) => const _PlaceholderScreen(title: 'In Call'),
      ),
    ],
  );
});

/// Placeholder screen — replace with real screens in Phase 2+
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\n[Coming soon]',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
