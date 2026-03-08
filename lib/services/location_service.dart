import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/rider_location.dart';

class LocationService {
  final _client = Supabase.instance.client;

  Future<LocationPermission> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  bool isGranted(LocationPermission permission) =>
      permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always;

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      return null;
    }
  }

  Stream<Position> positionStream() => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 3,
        ),
      );

  Future<void> upsertLocation({
    required String rideId,
    required String userId,
    required String displayName,
    required double latitude,
    required double longitude,
    double? heading,
  }) async {
    await _client.from('rider_locations').upsert({
      'ride_id': rideId,
      'user_id': userId,
      'display_name': displayName,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> removeLocation({
    required String rideId,
    required String userId,
  }) async {
    await _client
        .from('rider_locations')
        .delete()
        .eq('ride_id', rideId)
        .eq('user_id', userId);
  }

  Stream<List<RiderLocation>> riderLocationsStream(String rideId) {
    return _client
        .from('rider_locations')
        .stream(primaryKey: ['ride_id', 'user_id'])
        .eq('ride_id', rideId)
        .map((rows) => rows.map(RiderLocation.fromJson).toList());
  }
}
