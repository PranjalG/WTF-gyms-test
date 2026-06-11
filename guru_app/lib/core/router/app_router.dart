import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../di/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/chat/conversation_screen.dart';
import '../../features/schedule/schedule_call_screen.dart';
import '../../features/schedule/scheduled_calls_screen.dart';
import '../../features/schedule/pending_requests_screen.dart';
import '../../features/calls/prejoin_screen.dart';
import '../../features/calls/in_call_screen.dart';
import '../../models/call_request_model.dart';

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
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:chatId',
        builder: (context, state) => ConversationScreen(
          chatPartnerId: state.pathParameters['chatId'] ?? 'aarav_001',
        ),
      ),
      GoRoute(
        path: '/schedule',
        builder: (context, state) => const ScheduleCallScreen(),
      ),
      GoRoute(
        path: '/schedule/history',
        builder: (context, state) => const ScheduledCallsScreen(),
      ),
      GoRoute(
        path: '/requests',
        builder: (context, state) => const PendingRequestsScreen(),
      ),
      GoRoute(
        path: '/sessions',
        builder: (context, state) => const _PlaceholderScreen(title: 'My Sessions'),
      ),
      GoRoute(
        path: '/call/prejoin',
        builder: (context, state) {
          final call = state.extra;
          if (call is! CallRequestModel) {
            return const _PlaceholderScreen(title: 'Missing call request');
          }
          return PreJoinScreen(call: call);
        },
      ),
      GoRoute(
        path: '/call/room',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! Map<String, dynamic> || extra['call'] is! CallRequestModel) {
            return const _PlaceholderScreen(title: 'Missing call session');
          }
          return InCallScreen(
            call: extra['call'] as CallRequestModel,
            token: extra['token'] as String,
            userName: extra['userName'] as String,
            micOn: extra['micOn'] as bool,
            cameraOn: extra['cameraOn'] as bool,
          );
        },
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
