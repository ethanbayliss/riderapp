import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../services/ride_service.dart';

class RideNotifier extends ChangeNotifier {
  final _rideService = RideService();

  Future<Ride> createRide({
    required String name,
    required String leaderId,
    required String displayName,
  }) async {
    final ride = await _rideService.createRide(
      name: name,
      leaderId: leaderId,
      displayName: displayName,
    );
    notifyListeners();
    return ride;
  }

  Future<Ride> joinRide({
    required String inviteCode,
    required String userId,
    required String displayName,
  }) async {
    final ride = await _rideService.joinRide(
      inviteCode: inviteCode,
      userId: userId,
      displayName: displayName,
    );
    notifyListeners();
    return ride;
  }
}
