import 'package:hive_flutter/hive_flutter.dart';

class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();

    // TODO Phase 2: Register type adapters
    // Hive.registerAdapter(UserAdapter());
    // Hive.registerAdapter(MessageAdapter());
    // Hive.registerAdapter(CallRequestAdapter());
    // Hive.registerAdapter(SessionLogAdapter());
    // Hive.registerAdapter(RoomMetaAdapter());

    // Open boxes
    await Hive.openBox('users');
    await Hive.openBox('messages');
    await Hive.openBox('callRequests');
    await Hive.openBox('sessionLogs');
    await Hive.openBox('roomMeta');
    await Hive.openBox('appState');   // onboarding flag, current user, etc.
  }
}
