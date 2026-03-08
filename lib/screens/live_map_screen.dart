import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ride.dart';

class LiveMapScreen extends StatelessWidget {
  final Ride ride;

  const LiveMapScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ride.name)),
      body: Column(
        children: [
          _InviteCodeButton(code: ride.inviteCode),
          const Expanded(
            child: Center(
              child: Text('Map coming soon'),
            ),
          ),
        ],
      ),
    );
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
