import 'package:flutter/material.dart';
import '../notifiers/auth_notifier.dart';
import '../notifiers/ride_notifier.dart';
import '../services/ride_service.dart';
import 'live_map_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  final AuthNotifier authNotifier;
  final RideNotifier rideNotifier;

  const HomeScreen({
    super.key,
    required this.authNotifier,
    required this.rideNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = authNotifier.currentUser?.userMetadata?['display_name'] ?? 'Rider';

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
                builder: (_) => SettingsScreen(authNotifier: authNotifier),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $displayName!'),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Create Ride'),
              onPressed: () => _showCreateRideDialog(context, displayName),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.group),
              label: const Text('Join Ride'),
              onPressed: () => _showJoinRideDialog(context, displayName),
            ),
          ],
        ),
      ),
    );
  }

  String _defaultRideName() {
    final now = DateTime.now();
    final day = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][now.weekday - 1];
    final period = now.hour < 12 ? 'Morning' : now.hour < 17 ? 'Afternoon' : 'Evening';
    return '$day - $period';
  }

  Future<void> _showCreateRideDialog(BuildContext context, String displayName) async {
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

    final userId = authNotifier.currentUser?.id;
    if (userId == null) return;

    try {
      final ride = await rideNotifier.createRide(
        name: nameController.text.trim(),
        leaderId: userId,
        displayName: displayName,
      );
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => LiveMapScreen(ride: ride)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create ride. Please try again.')),
        );
      }
    }
  }

  Future<void> _showJoinRideDialog(BuildContext context, String displayName) async {
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

    final userId = authNotifier.currentUser?.id;
    if (userId == null) return;

    try {
      final ride = await rideNotifier.joinRide(
        inviteCode: codeController.text.trim(),
        userId: userId,
        displayName: displayName,
      );
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => LiveMapScreen(ride: ride)));
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
