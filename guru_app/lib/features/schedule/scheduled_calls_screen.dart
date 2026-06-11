import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/di/auth_provider.dart';
import '../../core/di/schedule_provider.dart';
import '../../core/theme/app_theme.dart';

class ScheduledCallsScreen extends ConsumerWidget {
  const ScheduledCallsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final scheduledCallsAsync = ref.watch(scheduledCallsProvider(currentUser.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Scheduled Calls'),
        elevation: 0,
      ),
      body: scheduledCallsAsync.when(
        data: (calls) {
          if (calls.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 64,
                    color: AppTheme.grey200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scheduled calls yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.grey600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Request a call or wait for your trainer to accept',
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
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final call = calls[index];
              final isApproved = call.status == 'approved';
              final isPending = call.status == 'pending';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM dd, yyyy').format(call.scheduledFor),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('hh:mm a').format(call.scheduledFor),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.grey600,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isApproved
                                  ? AppTheme.success.withValues( alpha: 0.2)
                                  : isPending
                                      ? AppTheme.primary.withValues( alpha: 0.2)
                                      : AppTheme.error.withValues( alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isApproved
                                  ? '✓ Approved'
                                  : isPending
                                      ? '⏳ Pending'
                                      : '✗ Declined',
                              style: TextStyle(
                                color: isApproved
                                    ? AppTheme.success
                                    : isPending
                                        ? AppTheme.primary
                                        : AppTheme.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Note
                      if (call.note.isNotEmpty) ...[
                        Text(
                          'Message:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.grey600,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          call.note,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Action button
                      if (isApproved)
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                            ),
                            onPressed: () {
                              context.push('/call/prejoin', extra: call);
                            },
                            child: const Text(
                              'Join Call',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      else if (isPending)
                        Text(
                          'Waiting for trainer approval...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.primary,
                                fontStyle: FontStyle.italic,
                              ),
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
}
