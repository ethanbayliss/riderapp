import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../notifiers/auth_notifier.dart';

class SettingsScreen extends StatelessWidget {
  final AuthNotifier authNotifier;

  const SettingsScreen({super.key, required this.authNotifier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () async {
              await authNotifier.logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Attributions', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Map data © OpenStreetMap contributors'),
            subtitle: const Text('openstreetmap.org/copyright'),
            onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search powered by Nominatim'),
            subtitle: const Text('nominatim.org'),
            onTap: () => launchUrl(Uri.parse('https://nominatim.org')),
          ),
          ListTile(
            leading: const Icon(Icons.satellite_alt),
            title: const Text('Satellite imagery © Esri'),
            subtitle: const Text('esri.com'),
            onTap: () => launchUrl(Uri.parse('https://www.esri.com')),
          ),
        ],
      ),
    );
  }
}
