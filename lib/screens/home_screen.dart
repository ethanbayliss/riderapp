import 'package:flutter/material.dart';
import '../notifiers/auth_notifier.dart';
import 'settings_screen.dart';

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
        child: Text('Welcome, $displayName!'),
      ),
    );
  }
}
