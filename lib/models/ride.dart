class Ride {
  final String id;
  final String name;
  final String inviteCode;
  final String leaderId;
  final String status;

  const Ride({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.leaderId,
    required this.status,
  });

  factory Ride.fromJson(Map<String, dynamic> json) => Ride(
        id: json['id'] as String,
        name: json['name'] as String,
        inviteCode: json['invite_code'] as String,
        leaderId: json['leader_id'] as String,
        status: json['status'] as String,
      );

  bool get isActive => status == 'active';
}
