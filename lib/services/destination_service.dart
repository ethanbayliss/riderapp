import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ride_destination.dart';

class DestinationService {
  final _client = Supabase.instance.client;

  static const _nominatimBase = 'https://nominatim.openstreetmap.org';
  // Nominatim policy requires a descriptive User-Agent with contact info:
  // https://operations.osmfoundation.org/policies/nominatim/
  static const _userAgent = 'RiderApp/1.0 (https://github.com/ethanbayliss/riderapp)';

  // ── Geocoding ──────────────────────────────────────────────────────────────

  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse('$_nominatimBase/reverse').replace(queryParameters: {
        'lat': '$lat',
        'lon': '$lng',
        'format': 'json',
        'zoom': '18',
      });
      final res = await http.get(uri, headers: {'User-Agent': _userAgent});
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return json['display_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<List<NominatimResult>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final uri = Uri.parse('$_nominatimBase/search').replace(queryParameters: {
        'q': query,
        'format': 'json',
        'limit': '5',
      });
      final res = await http.get(uri, headers: {'User-Agent': _userAgent});
      if (res.statusCode != 200) return [];
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.map((item) {
        final m = item as Map<String, dynamic>;
        return NominatimResult(
          latitude: double.parse(m['lat'] as String),
          longitude: double.parse(m['lon'] as String),
          displayName: m['display_name'] as String,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Database ───────────────────────────────────────────────────────────────

  Future<RideDestination> setDestination({
    required String rideId,
    required String setBy,
    required double latitude,
    required double longitude,
  }) async {
    final placeName = await reverseGeocode(latitude, longitude);

    // Deactivate any existing active destination for this ride
    await _client
        .from('ride_destinations')
        .update({'is_active': false})
        .eq('ride_id', rideId)
        .eq('is_active', true);

    final row = await _client
        .from('ride_destinations')
        .insert({
          'ride_id': rideId,
          'set_by': setBy,
          'latitude': latitude,
          'longitude': longitude,
          'place_name': placeName,
        })
        .select()
        .single();

    return RideDestination.fromJson(row);
  }

  Future<void> clearDestination(String rideId) async {
    await _client
        .from('ride_destinations')
        .update({'is_active': false})
        .eq('ride_id', rideId)
        .eq('is_active', true);
  }

  Stream<RideDestination?> currentDestinationStream(String rideId) {
    return _client
        .from('ride_destinations')
        .stream(primaryKey: ['id'])
        .eq('ride_id', rideId)
        .map((rows) {
          final active = rows.where((r) => r['is_active'] == true).toList()
            ..sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
          if (active.isEmpty) return null;
          return RideDestination.fromJson(active.first);
        });
  }

  Future<List<RideDestination>> getHistory(String rideId) async {
    final rows = await _client
        .from('ride_destinations')
        .select()
        .eq('ride_id', rideId)
        .order('created_at', ascending: false);
    return rows.map(RideDestination.fromJson).toList();
  }
}
