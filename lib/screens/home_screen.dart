import 'package:flutter/material.dart';
import '../models/ride_membership.dart';
import '../notifiers/auth_notifier.dart';
import '../notifiers/ride_notifier.dart';
import '../services/ride_service.dart';
import 'live_map_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AuthNotifier authNotifier;
  final RideNotifier rideNotifier;

  const HomeScreen({
    super.key,
    required this.authNotifier,
    required this.rideNotifier,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final userId = widget.authNotifier.currentUser?.id;
    if (userId != null) {
      widget.rideNotifier.loadMyRides(userId);
    }
  }

  String get _displayName =>
      widget.authNotifier.currentUser?.userMetadata?['display_name'] ?? 'Rider';

  String get _userId => widget.authNotifier.currentUser?.id ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RiderApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(authNotifier: widget.authNotifier),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.rideNotifier,
        builder: (context, _) {
          final rides = widget.rideNotifier.myRides;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Welcome, $_displayName!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create Ride'),
                        onPressed: () => _showCreateRideDialog(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.group),
                        label: const Text('Join Ride'),
                        onPressed: () => _showJoinRideDialog(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (rides.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'Your Active Rides',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: rides.length,
                    itemBuilder: (context, i) => _RideTile(
                      membership: rides[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveMapScreen(
                            membership: rides[i],
                            userId: _userId,
                            displayName: _displayName,
                            rideNotifier: widget.rideNotifier,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else
                const Expanded(
                  child: Center(child: Text('No active rides. Create or join one!')),
                ),
            ],
          );
        },
      ),
    );
  }

  String _defaultRideName() {
    final now = DateTime.now();
    final day = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][now.weekday - 1];
    final period = now.hour < 12 ? 'Morning' : now.hour < 17 ? 'Afternoon' : 'Evening';
    return '$day - $period';
  }

  Future<void> _showCreateRideDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _defaultRideName());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create a Ride'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Ride name',
              hintText: 'e.g. Sunday Morning Run',
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter a ride name';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final ride = await widget.rideNotifier.createRide(
        name: nameController.text.trim(),
        leaderId: _userId,
        displayName: _displayName,
      );
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => LiveMapScreen(
            membership: RideMembership(ride: ride, role: 'leader'),
            userId: _userId,
            displayName: _displayName,
            rideNotifier: widget.rideNotifier,
          )));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create ride. Please try again.')),
        );
      }
    }
  }

  Future<void> _showJoinRideDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join a Ride'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: 'Invite code',
              hintText: 'e.g. ABC123',
            ),
            autofocus: true,
            autocorrect: false,
            textCapitalization: TextCapitalization.characters,
            onChanged: (v) {
              final upper = v.toUpperCase();
              if (v != upper) {
                codeController.value = codeController.value.copyWith(text: upper);
              }
            },
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter an invite code';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, true);
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final ride = await widget.rideNotifier.joinRide(
        inviteCode: codeController.text.trim(),
        userId: _userId,
        displayName: _displayName,
      );
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => LiveMapScreen(
              membership: RideMembership(ride: ride, role: 'rider'),
              userId: _userId,
              displayName: _displayName,
              rideNotifier: widget.rideNotifier,
            )));
      }
    } on RideNotFoundException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid invite code. Please check and try again.')),
        );
      }
    } on RideEndedException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This ride has already ended.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to join ride. Please try again.')),
        );
      }
    }
  }
}

class _RideTile extends StatelessWidget {
  final RideMembership membership;
  final VoidCallback onTap;

  const _RideTile({required this.membership, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(membership.isLeader ? Icons.star : Icons.directions_bike),
      title: Text(membership.ride.name),
      subtitle: Text(membership.isLeader ? 'Leader · ${membership.ride.inviteCode}' : 'Rider · ${membership.ride.inviteCode}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
