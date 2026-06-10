import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _isLoggedIn = false;

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: _isLoggedIn ? '/home' : '/login',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const _PlaceholderScreen(title: 'Login — Aarav'),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const _PlaceholderScreen(title: 'Home — Aarav'),
      ),
      GoRoute(
        path: '/members',
        builder: (context, state) => const _PlaceholderScreen(title: 'Members (CRM)'),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const _PlaceholderScreen(title: 'Chats'),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) => _PlaceholderScreen(
          title: 'Chat: ${state.pathParameters['chatId']}',
        ),
      ),
      GoRoute(
        path: '/requests',
        builder: (context, state) => const _PlaceholderScreen(title: 'Call Requests'),
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const _PlaceholderScreen(title: 'Sessions'),
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
