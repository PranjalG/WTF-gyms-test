import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class SeedService {
  static void seedIfEmpty() {
    final box = Hive.box('users');
    if (box.isEmpty) {
      // Seed DK (member)
      final dk = UserModel(
        id: 'dk_001',
        name: 'DK',
        role: 'member',
        assignedTrainerId: 'aarav_001',
      );
      // Seed Aarav (trainer)
      final aarav = UserModel(
        id: 'aarav_001',
        name: 'Aarav',
        role: 'trainer',
      );
      box.put(dk.id, dk.toMap());
      box.put(aarav.id, aarav.toMap());
    }
  }
}