import 'ride.dart';

class RideMembership {
  final Ride ride;
  final String role;

  const RideMembership({required this.ride, required this.role});

  bool get isLeader => role == 'leader';

  factory RideMembership.fromJson(Map<String, dynamic> json) => RideMembership(
        ride: Ride.fromJson(json['rides'] as Map<String, dynamic>),
        role: json['role'] as String,
      );
}
