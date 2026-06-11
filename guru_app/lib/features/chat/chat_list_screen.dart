import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/auth_provider.dart';
import '../../core/di/chat_provider.dart';
import '../../core/theme/app_theme.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final chatPartner = ref.watch(chatPartnerProvider(currentUser.id));
    final chatId = ref.watch(chatIdProvider(chatPartner));
    final lastMessage = ref.watch(lastMessageProvider(chatId));
    final unreadCount = ref.watch(unreadCountProvider(chatId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
      ),
      body: lastMessage == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: AppTheme.grey200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.grey600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Start a conversation with your trainer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.grey400,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: () => context.push('/chat/aarav_001'),
                      child: const Text('Start Chat'),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => context.push('/chat/aarav_001'),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.primaryDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'A',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Message preview
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aarav',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lastMessage.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.grey600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (unreadCount > 0)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppTheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.success,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          fixedColor: AppTheme.primary,
          unselectedItemColor: Colors.grey,
          currentIndex: 1,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Sessions'),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/chat');
                break;
              case 2:
                context.push('/schedule');
                break;
              case 3:
                context.push('/sessions');
                break;
            }
          },
        ),
      ),
    );
  }
}
