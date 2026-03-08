import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/marker_icons.dart';
import '../notifiers/auth_notifier.dart';
import '../services/audio_callout_service.dart';

class SettingsScreen extends StatefulWidget {
  final AuthNotifier authNotifier;

  const SettingsScreen({super.key, required this.authNotifier});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _audio = AudioCalloutService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Account ──────────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Account', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out'),
            onTap: () async {
              await widget.authNotifier.logout();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),

          // ── Ride preferences ─────────────────────────────────────────────
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('Ride preferences', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          ListTile(
            leading: const Icon(Icons.volume_off_outlined),
            title: const Text('Mute audio callouts'),
            trailing: Switch(
              value: _audio.muted,
              onChanged: (v) => setState(() => _audio.muted = v),
            ),
          ),
          ListTile(
            leading: Icon(iconForKey(widget.authNotifier.markerIcon)),
            title: const Text('Map marker icon'),
            subtitle: Text(widget.authNotifier.markerIcon),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showIconPicker(context),
          ),

          // ── Attributions ─────────────────────────────────────────────────
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

  void _showIconPicker(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (_) => _IconPickerDialog(current: widget.authNotifier.markerIcon),
    ).then((selected) async {
      if (selected == null || selected == widget.authNotifier.markerIcon) return;
      await widget.authNotifier.updateMarkerIcon(selected);
      if (mounted) setState(() {});
    });
  }
}

class _IconPickerDialog extends StatefulWidget {
  final String current;
  const _IconPickerDialog({required this.current});

  @override
  State<_IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<_IconPickerDialog> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Choose your marker'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: kMarkerIcons.entries.map((entry) {
          final isSelected = entry.key == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = entry.key),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                border: isSelected
                    ? Border.all(color: colorScheme.primary, width: 2)
                    : null,
              ),
              child: Icon(entry.value,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
