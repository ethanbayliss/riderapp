class RiderLocation {
  final String rideId;
  final String userId;
  final String displayName;
  final double latitude;
  final double longitude;
  final double? heading;
  final DateTime updatedAt;

  const RiderLocation({
    required this.rideId,
    required this.userId,
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.heading,
    required this.updatedAt,
  });

  bool get isStale =>
      DateTime.now().toUtc().difference(updatedAt).inSeconds > 60;

  factory RiderLocation.fromJson(Map<String, dynamic> json) => RiderLocation(
        rideId: json['ride_id'] as String,
        userId: json['user_id'] as String,
        displayName: json['display_name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        heading: (json['heading'] as num?)?.toDouble(),
        updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      );
}
