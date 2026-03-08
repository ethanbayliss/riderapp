import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ride_membership.dart';
import '../notifiers/ride_notifier.dart';

class LiveMapScreen extends StatelessWidget {
  final RideMembership membership;
  final String userId;
  final String displayName;
  final RideNotifier rideNotifier;

  const LiveMapScreen({
    super.key,
    required this.membership,
    required this.userId,
    required this.displayName,
    required this.rideNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(membership.ride.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Leave ride',
            onPressed: () => _confirmLeave(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _InviteCodeButton(code: membership.ride.inviteCode),
          const Expanded(
            child: Center(child: Text('Map coming soon')),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final isLeader = membership.isLeader;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Ride?'),
        content: Text(
          isLeader
              ? 'You are the ride leader. Leaving will end the ride for all members.'
              : 'Are you sure you want to leave this ride?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(isLeader ? 'End Ride' : 'Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await rideNotifier.leaveRide(
        rideId: membership.ride.id,
        userId: userId,
        displayName: displayName,
        isLeader: isLeader,
      );
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to leave ride. Please try again.')),
        );
      }
    }
  }
}

class _InviteCodeButton extends StatelessWidget {
  final String code;

  const _InviteCodeButton({required this.code});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: code));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invite code copied!')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'INVITE CODE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: colorScheme.onPrimaryContainer.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Icon(Icons.copy, color: colorScheme.onPrimaryContainer.withAlpha(180)),
            ],
          ),
        ),
      ),
    );
  }
}
