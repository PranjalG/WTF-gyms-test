import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/di/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/call_request_model.dart';

class PreJoinScreen extends ConsumerStatefulWidget {
  final CallRequestModel call;

  const PreJoinScreen({super.key, required this.call});

  @override
  ConsumerState<PreJoinScreen> createState() => _PreJoinScreenState();
}

class _PreJoinScreenState extends ConsumerState<PreJoinScreen> {
  bool _micOn = true;
  bool _cameraOn = true;
  bool _isJoining = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final formatted = DateFormat('MMM dd, hh:mm a').format(widget.call.scheduledFor);

    return Scaffold(
      appBar: AppBar(title: const Text('Ready to join?')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Check mic and camera.', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Session with DK at $formatted', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.grey900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppTheme.primary,
                        child: Text(
                          currentUser?.name.substring(0, 1) ?? 'A',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _cameraOn ? 'Camera will start after joining' : 'Camera off',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ToggleButton(
                      icon: _micOn ? Icons.mic : Icons.mic_off,
                      label: _micOn ? 'Mic on' : 'Mic off',
                      isActive: _micOn,
                      onPressed: () => setState(() => _micOn = !_micOn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToggleButton(
                      icon: _cameraOn ? Icons.videocam : Icons.videocam_off,
                      label: _cameraOn ? 'Camera on' : 'Camera off',
                      isActive: _cameraOn,
                      onPressed: () => setState(() => _cameraOn = !_cameraOn),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppTheme.error)),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isJoining || currentUser == null ? null : _join,
                icon: _isJoining
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.video_call),
                label: Text(_isJoining ? 'Joining...' : 'Join Call'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _join() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      final tokenServerUrl = dotenv.env['TOKEN_SERVER_URL'] ?? 'http://localhost:3000';
      final role = currentUser.role == 'trainer' ? 'host' : 'guest';
      final response = await Dio().get(
        '$tokenServerUrl/token',
        queryParameters: {
          'userId': currentUser.id,
          'role': role,
          if (widget.call.roomCode != null && widget.call.roomCode!.isNotEmpty) 'roomId': widget.call.roomCode,
        },
      );
      print('ROOM ID = ${widget.call.roomCode}');
      print('ROLE = $role');
      print('USER = ${currentUser.id}');
      final token = response.data['token'] as String;

      if (!mounted) return;
      context.go('/call/room', extra: {
        'call': widget.call,
        'token': token,
        'userName': currentUser.name,
        'micOn': _micOn,
        'cameraOn': _cameraOn,
      });
    } catch (error) {
      setState(() => _error = 'Could not join call: $error');
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isActive ? AppTheme.primary : AppTheme.grey600,
        side: BorderSide(color: isActive ? AppTheme.primary : AppTheme.grey200),
      ),
    );
  }
}
