import 'package:flutter/foundation.dart';
import '../models/ride.dart';
import '../services/ride_service.dart';

class RideNotifier extends ChangeNotifier {
  final _rideService = RideService();

  Ride? _activeRide;
  Ride? get activeRide => _activeRide;
  bool get hasActiveRide => _activeRide != null;

  Future<Ride> createRide({required String name, required String leaderId}) async {
    final ride = await _rideService.createRide(name: name, leaderId: leaderId);
    _activeRide = ride;
    notifyListeners();
    return ride;
  }

  Future<void> loadActiveRide(String userId) async {
    _activeRide = await _rideService.activeRideForUser(userId);
    notifyListeners();
  }

  void clearRide() {
    _activeRide = null;
    notifyListeners();
  }
}
