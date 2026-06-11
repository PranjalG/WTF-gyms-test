import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../di/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/chat/conversation_screen.dart';
import '../../features/schedule/pending_requests_screen.dart';
import '../../features/schedule/scheduled_calls_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);

  return GoRouter(
    initialLocation: isLoggedIn ? '/home' : '/login',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/requests',
        builder: (context, state) => const PendingRequestsScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) => ConversationScreen(
          chatPartnerId: state.pathParameters['chatId'] ?? 'dk_001',
        ),
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const ScheduledCallsScreen(),
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

/// Placeholder screen — replace with real screens in Phase 3+
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
