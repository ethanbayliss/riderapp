import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../models/ride_membership.dart';
import '../services/ride_service.dart';

class RideNotifier extends ChangeNotifier {
  final _rideService = RideService();

  List<RideMembership> _myRides = [];
  List<RideMembership> get myRides => _myRides;

  Future<void> loadMyRides(String userId) async {
    _myRides = await _rideService.getMyRides(userId);
    notifyListeners();
  }

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
    await loadMyRides(leaderId);
    return ride;
  }

  Future<void> leaveRide({
    required String rideId,
    required String userId,
    required String displayName,
  }) async {
    await _rideService.leaveRide(
      rideId: rideId,
      userId: userId,
      displayName: displayName,
    );
    await loadMyRides(userId);
  }

  Future<void> endRide({
    required String rideId,
    required String userId,
  }) async {
    await _rideService.endRide(rideId: rideId, userId: userId);
    await loadMyRides(userId);
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
    await loadMyRides(userId);
    return ride;
  }
}
