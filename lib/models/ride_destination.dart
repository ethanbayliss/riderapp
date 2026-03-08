class RideDestination {
  final String id;
  final String rideId;
  final String setBy;
  final double latitude;
  final double longitude;
  final String? placeName;
  final bool isActive;
  final DateTime createdAt;

  const RideDestination({
    required this.id,
    required this.rideId,
    required this.setBy,
    required this.latitude,
    required this.longitude,
    this.placeName,
    required this.isActive,
    required this.createdAt,
  });

  factory RideDestination.fromJson(Map<String, dynamic> json) => RideDestination(
        id: json['id'] as String,
        rideId: json['ride_id'] as String,
        setBy: json['set_by'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        placeName: json['place_name'] as String?,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      );
}

class NominatimResult {
  final double latitude;
  final double longitude;
  final String displayName;

  const NominatimResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });
}
