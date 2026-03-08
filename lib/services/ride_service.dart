import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride.dart';

class RideService {
  final _client = Supabase.instance.client;

  // Unambiguous characters: no 0/O, 1/I
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _generateCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => _codeChars[rng.nextInt(_codeChars.length)]).join();
  }

  Future<Ride> createRide({required String name, required String leaderId}) async {
    // Retry on the rare chance of an invite code collision
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generateCode();
      try {
        final row = await _client
            .from('rides')
            .insert({
              'name': name,
              'invite_code': code,
              'leader_id': leaderId,
            })
            .select()
            .single();
        return Ride.fromJson(row);
      } on PostgrestException catch (e) {
        // 23505 = unique_violation; retry for invite_code collision only
        if (e.code == '23505' && (e.message.contains('invite_code'))) continue;
        rethrow;
      }
    }
    throw Exception('Failed to generate a unique invite code. Please try again.');
  }

  Future<Ride?> activeRideForUser(String userId) async {
    final rows = await _client
        .from('rides')
        .select()
        .eq('leader_id', userId)
        .eq('status', 'active')
        .limit(1);
    if (rows.isEmpty) return null;
    return Ride.fromJson(rows.first);
  }
}
