import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ride.dart';
import '../models/ride_membership.dart';
import 'audio_callout_service.dart';

class RideService {
  final _client = Supabase.instance.client;
  final _audioCallouts = AudioCalloutService();

  // Unambiguous characters: no 0/O, 1/I
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _generateCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => _codeChars[rng.nextInt(_codeChars.length)]).join();
  }

  Future<Ride> createRide({
    required String name,
    required String leaderId,
    required String displayName,
  }) async {
    // Retry on the rare chance of an invite code collision
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generateCode();
      try {
        final row = await _client
            .from('rides')
            .insert({'name': name, 'invite_code': code, 'leader_id': leaderId})
            .select()
            .single();
        final ride = Ride.fromJson(row);
        // Add leader to ride_members
        await _client.from('ride_members').insert({
          'ride_id': ride.id,
          'user_id': leaderId,
          'display_name': displayName,
          'role': 'leader',
        });
        return ride;
      } on PostgrestException catch (e) {
        // 23505 = unique_violation; retry for invite_code collision only
        if (e.code == '23505' && e.message.contains('invite_code')) continue;
        rethrow;
      }
    }
    throw Exception('Failed to generate a unique invite code. Please try again.');
  }

  Future<Ride> joinRide({
    required String inviteCode,
    required String userId,
    required String displayName,
  }) async {
    // Look up the ride — case-insensitive by uppercasing the input
    final rows = await _client
        .from('rides')
        .select()
        .eq('invite_code', inviteCode.toUpperCase())
        .limit(1);

    if (rows.isEmpty) throw const RideNotFoundException();

    final ride = Ride.fromJson(rows.first);
    if (!ride.isActive) throw const RideEndedException();

    await _client.from('ride_members').insert({
      'ride_id': ride.id,
      'user_id': userId,
      'display_name': displayName,
      'role': 'rider',
    });

    await _audioCallouts.announceJoin(displayName);
    return ride;
  }

  Future<void> leaveRide({
    required String rideId,
    required String userId,
    required String displayName,
    required bool isLeader,
  }) async {
    await _client
        .from('ride_members')
        .delete()
        .eq('ride_id', rideId)
        .eq('user_id', userId);

    if (isLeader) {
      await _client
          .from('rides')
          .update({'status': 'ended'})
          .eq('id', rideId);
      // TODO(RIDER-6): push realtime event so remaining members are notified
    }

    await _audioCallouts.announceLeave(displayName);
  }

  Future<List<RideMembership>> getMyRides(String userId) async {
    final rows = await _client
        .from('ride_members')
        .select('role, rides(id, name, invite_code, leader_id, status)')
        .eq('user_id', userId);
    return rows
        .where((r) => r['rides'] != null && r['rides']['status'] == 'active')
        .map((r) => RideMembership.fromJson(r))
        .toList();
  }
}

class RideNotFoundException implements Exception {
  const RideNotFoundException();
}

class RideEndedException implements Exception {
  const RideEndedException();
}
