import 'package:flutter/material.dart';
import '../notifiers/auth_notifier.dart';

class HomeScreen extends StatelessWidget {
  final AuthNotifier authNotifier;

  const HomeScreen({super.key, required this.authNotifier});

  @override
  Widget build(BuildContext context) {
    final displayName = authNotifier.currentUser?.userMetadata?['display_name'] ?? 'Rider';

    return Scaffold(
      appBar: AppBar(
        title: const Text('RiderApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () async {
              await authNotifier.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome, $displayName!'),
      ),
    );
  }
}
