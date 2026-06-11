import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';

/// Provides the currently logged-in user
final currentUserProvider = Provider<UserModel?>((ref) {
  try {
    final box = Hive.box('users');
    final userMap = box.get('currentUser');
    if (userMap != null) {
      return UserModel.fromMap(userMap);
    }
    return null;
  } catch (e) {
    return null;
  }
});

/// Provides auth state (whether user is logged in)
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

/// Notifier for login/logout
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.data(null)) {
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    try {
      final box = Hive.box('users');
      final userMap = box.get('currentUser');
      if (userMap != null) {
        state = AsyncValue.data(UserModel.fromMap(userMap));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Login with user ID
  Future<void> login(String userId) async {
    state = const AsyncValue.loading();
    try {
      final usersBox = Hive.box('users');
      final userMap = usersBox.get(userId);
      
      if (userMap == null) {
        state = AsyncValue.error('User not found', StackTrace.current);
        return;
      }
      
      final user = UserModel.fromMap(userMap);
      
      // Save current user to Hive
      final appStateBox = Hive.box('appState');
      await appStateBox.put('currentUser', user.toMap());
      
      // Also update the users box for clarity
      await usersBox.put('currentUser', user.toMap());
      
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Logout
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final appStateBox = Hive.box('appState');
      await appStateBox.delete('currentUser');
      
      final usersBox = Hive.box('users');
      await usersBox.delete('currentUser');
      
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
