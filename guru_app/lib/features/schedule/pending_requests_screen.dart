import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/di/auth_provider.dart';
import '../../core/di/schedule_provider.dart';
import '../../core/theme/app_theme.dart';

class PendingRequestsScreen extends ConsumerWidget {
  const PendingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pendingRequestsAsync = ref.watch(pendingCallRequestsProvider(currentUser.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Call Requests'),
        elevation: 0,
      ),
      body: pendingRequestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inbox,
                    size: 64,
                    color: AppTheme.grey200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.grey600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new call requests',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.grey400,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with member avatar
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary,
                                  AppTheme.primaryDark,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'D',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DK',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Requested ${DateFormat('MMM dd').format(request.requestedAt)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.grey600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Requested time
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues( alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, size: 20),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('MMM dd, yyyy').format(request.scheduledFor),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  DateFormat('hh:mm a').format(request.scheduledFor),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Note
                      if (request.note.isNotEmpty) ...[
                        Text(
                          'Member\'s message:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.grey600,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.note,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _respondToRequest(
                                context,
                                ref,
                                request.id,
                                'declined',
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.error),
                              ),
                              child: const Text(
                                'Decline',
                                style: TextStyle(color: AppTheme.error),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.success,
                              ),
                              onPressed: () => _respondToRequest(
                                context,
                                ref,
                                request.id,
                                'approved',
                              ),
                              child: const Text(
                                'Approve',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('Error: $e'),
        ),
      ),
    );
  }

  void _respondToRequest(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    String status,
  ) async {
    await ref.read(respondToCallRequestProvider((requestId, status)).future);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${status}d')),
      );
    }
  }
}
