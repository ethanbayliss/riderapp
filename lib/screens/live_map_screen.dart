import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/ride_destination.dart';
import '../models/ride_membership.dart';
import '../models/rider_location.dart';
import '../notifiers/ride_notifier.dart';
import '../services/audio_callout_service.dart';
import '../services/destination_service.dart';
import '../services/location_service.dart';

class LiveMapScreen extends StatefulWidget {
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
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final _locationService = LocationService();
  final _destinationService = DestinationService();
  final _audioCallouts = AudioCalloutService();
  final _mapController = MapController();

  List<RiderLocation> _riderLocations = [];
  RideDestination? _currentDestination;
  Position? _myPosition;

  StreamSubscription<Position>? _positionSub;
  StreamSubscription<List<RiderLocation>>? _locationsSub;
  StreamSubscription<RideDestination?>? _destinationSub;
  Timer? _broadcastTimer;
  Timer? _staleCheckTimer;

  bool _isSatellite = false;
  bool _permissionGranted = false;
  bool _centred = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final permission = await _locationService.requestPermission();
    if (!mounted) return;

    if (!_locationService.isGranted(permission)) {
      setState(() => _permissionGranted = false);
      return;
    }
    setState(() => _permissionGranted = true);

    final initial = await _locationService.getCurrentPosition();
    if (initial != null && mounted) {
      setState(() => _myPosition = initial);
      _mapController.move(LatLng(initial.latitude, initial.longitude), 15);
      _centred = true;
      await _upsertPosition(initial);
    }

    _locationsSub = _locationService
        .riderLocationsStream(widget.membership.ride.id)
        .listen((locs) {
      if (mounted) setState(() => _riderLocations = locs);
    });

    _destinationSub = _destinationService
        .currentDestinationStream(widget.membership.ride.id)
        .listen((dest) {
      if (mounted) setState(() => _currentDestination = dest);
    });

    _positionSub = _locationService.positionStream().listen((pos) {
      if (!mounted) return;
      setState(() => _myPosition = pos);
      if (!_centred) {
        _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
        _centred = true;
      }
    });

    _broadcastTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final pos = _myPosition;
      if (pos != null) await _upsertPosition(pos);
    });

    _staleCheckTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _upsertPosition(Position pos) => _locationService.upsertLocation(
        rideId: widget.membership.ride.id,
        userId: widget.userId,
        displayName: widget.displayName,
        latitude: pos.latitude,
        longitude: pos.longitude,
        heading: pos.heading,
      );

  void _cancelSubscriptions() {
    _broadcastTimer?.cancel();
    _staleCheckTimer?.cancel();
    _positionSub?.cancel();
    _locationsSub?.cancel();
    _destinationSub?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  // ── Destination ────────────────────────────────────────────────────────────

  Future<void> _setDestinationAt(LatLng point) async {
    try {
      final dest = await _destinationService.setDestination(
        rideId: widget.membership.ride.id,
        setBy: widget.userId,
        latitude: point.latitude,
        longitude: point.longitude,
      );
      await _audioCallouts.announceNewDestination(dest.placeName);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to set destination.')));
      }
    }
  }

  Future<void> _clearDestination() async {
    try {
      await _destinationService.clearDestination(widget.membership.ride.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to clear destination.')));
      }
    }
  }

  void _showHistory() async {
    final history = await _destinationService.getHistory(widget.membership.ride.id);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (_) => _DestinationHistorySheet(history: history),
    );
  }

  // ── Leave ──────────────────────────────────────────────────────────────────

  Future<void> _confirmLeave(BuildContext context) async {
    final isLeader = widget.membership.isLeader;
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

    _cancelSubscriptions();

    await _locationService.removeLocation(
      rideId: widget.membership.ride.id,
      userId: widget.userId,
    );
    await widget.rideNotifier.leaveRide(
      rideId: widget.membership.ride.id,
      userId: widget.userId,
      displayName: widget.displayName,
      isLeader: widget.membership.isLeader,
    );

    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLeader = widget.membership.isLeader;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.membership.ride.name),
        actions: [
          if (isLeader && _currentDestination != null)
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Destination history',
              onPressed: _showHistory,
            ),
          if (isLeader && _currentDestination != null)
            IconButton(
              icon: const Icon(Icons.wrong_location_outlined),
              tooltip: 'Clear destination',
              onPressed: _clearDestination,
            ),
          if (isLeader)
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search for destination',
              onPressed: () => _showSearchDialog(context),
            ),
          IconButton(
            icon: Icon(_isSatellite ? Icons.map : Icons.satellite_alt),
            tooltip: _isSatellite ? 'Standard view' : 'Satellite view',
            onPressed: () => setState(() => _isSatellite = !_isSatellite),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Leave ride',
            onPressed: () => _confirmLeave(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _InviteCodeBar(code: widget.membership.ride.inviteCode),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!_permissionGranted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Location permission is required to see the group on the map.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Geolocator.openAppSettings(),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    final activeRiderCount = _riderLocations.where((l) => !l.isStale).length;
    final dest = _currentDestination;
    final myPos = _myPosition;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(0, 0),
            initialZoom: 15,
            onLongPress: widget.membership.isLeader
                ? (_, point) => _setDestinationAt(point)
                : null,
          ),
          children: [
            TileLayer(
              urlTemplate: _isSatellite
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.riderapp',
            ),
            MarkerLayer(markers: _buildRiderMarkers(context)),
            if (dest != null)
              MarkerLayer(markers: [_buildDestinationMarker(context, dest)]),
            RichAttributionWidget(
              alignment: AttributionAlignment.bottomLeft,
              attributions: [
                TextSourceAttribution(
                  _isSatellite ? 'Esri' : '© OpenStreetMap contributors',
                  onTap: () => launchUrl(Uri.parse(_isSatellite
                      ? 'https://www.esri.com'
                      : 'https://www.openstreetmap.org/copyright')),
                ),
              ],
            ),
          ],
        ),
        // Rider count
        Positioned(
          top: 12,
          right: 12,
          child: Chip(
            avatar: const Icon(Icons.directions_bike, size: 16),
            label: Text('$activeRiderCount ${activeRiderCount == 1 ? 'rider' : 'riders'}'),
          ),
        ),
        // Re-centre
        Positioned(
          bottom: dest != null ? 88 : 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'centre',
            tooltip: 'Centre on my location',
            onPressed: () {
              if (myPos != null) {
                _mapController.move(
                    LatLng(myPos.latitude, myPos.longitude),
                    _mapController.camera.zoom);
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ),
        // Destination strip
        if (dest != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _DestinationStrip(
              destination: dest,
              distanceMeters: myPos != null
                  ? Geolocator.distanceBetween(
                      myPos.latitude, myPos.longitude,
                      dest.latitude, dest.longitude)
                  : null,
              isLeader: widget.membership.isLeader,
              onHistory: _showHistory,
            ),
          ),
      ],
    );
  }

  List<Marker> _buildRiderMarkers(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _riderLocations.map((loc) {
      final isMe = loc.userId == widget.userId;
      final color = isMe ? colorScheme.primary : colorScheme.secondary;
      final opacity = loc.isStale ? 0.35 : 1.0;

      return Marker(
        point: LatLng(loc.latitude, loc.longitude),
        width: 80,
        height: 56,
        child: Opacity(
          opacity: opacity,
          child: Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: color,
                child: Icon(
                  isMe ? Icons.person : Icons.directions_bike,
                  color: colorScheme.onPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  loc.displayName,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Marker _buildDestinationMarker(BuildContext context, RideDestination dest) {
    return Marker(
      point: LatLng(dest.latitude, dest.longitude),
      width: 48,
      height: 48,
      alignment: Alignment.bottomCenter,
      child: GestureDetector(
        onTap: () => _showDestinationDetail(context, dest),
        child: const Icon(Icons.location_on, color: Colors.red, size: 48),
      ),
    );
  }

  void _showDestinationDetail(BuildContext context, RideDestination dest) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _DestinationDetailSheet(destination: dest),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _DestinationSearchDialog(
        onSelected: (result) => _setDestinationAt(
          LatLng(result.latitude, result.longitude),
        ),
        destinationService: _destinationService,
      ),
    );
  }
}

// ── Invite code bar ──────────────────────────────────────────────────────────

class _InviteCodeBar extends StatelessWidget {
  final String code;
  const _InviteCodeBar({required this.code});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primaryContainer,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: code));
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Invite code copied!')));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text('INVITE CODE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: colorScheme.onPrimaryContainer.withAlpha(180))),
                  const SizedBox(height: 2),
                  Text(code,
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                          color: colorScheme.onPrimaryContainer)),
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

// ── Destination strip (bottom bar) ───────────────────────────────────────────

class _DestinationStrip extends StatelessWidget {
  final RideDestination destination;
  final double? distanceMeters;
  final bool isLeader;
  final VoidCallback onHistory;

  const _DestinationStrip({
    required this.destination,
    required this.distanceMeters,
    required this.isLeader,
    required this.onHistory,
  });

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.round()} m';
  }

  @override
  Widget build(BuildContext context) {
    final dist = distanceMeters;
    return Material(
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.flag, color: Colors.red, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(destination.placeName ?? 'Unknown location',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (dist != null)
                      Text(_formatDistance(dist),
                          style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (isLeader)
                IconButton(
                  icon: const Icon(Icons.history, size: 20),
                  tooltip: 'Destination history',
                  onPressed: onHistory,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Destination detail bottom sheet ─────────────────────────────────────────

class _DestinationDetailSheet extends StatelessWidget {
  final RideDestination destination;
  const _DestinationDetailSheet({required this.destination});

  Future<void> _openInMaps(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps app.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = destination.latitude;
    final lng = destination.longitude;
    final name = destination.placeName ?? 'Selected location';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.flag, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 4),
          Text('$lat, $lng', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text('© OpenStreetMap contributors · Nominatim',
              style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 20),
          const Text('Open in…', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _openInMaps(context,
                    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
                child: const Text('Google Maps'),
              ),
              OutlinedButton(
                onPressed: () => _openInMaps(context,
                    'https://maps.apple.com/?daddr=$lat,$lng'),
                child: const Text('Apple Maps'),
              ),
              OutlinedButton(
                onPressed: () => _openInMaps(context,
                    'https://waze.com/ul?ll=$lat,$lng&navigate=yes'),
                child: const Text('Waze'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Destination history bottom sheet ─────────────────────────────────────────

class _DestinationHistorySheet extends StatelessWidget {
  final List<RideDestination> history;
  const _DestinationHistorySheet({required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Destination History',
                style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        if (history.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No destinations set yet.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            itemCount: history.length,
            itemBuilder: (context, i) {
              final dest = history[i];
              final time = dest.createdAt.toLocal();
              final label =
                  '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              return ListTile(
                leading: Icon(
                  dest.isActive ? Icons.flag : Icons.flag_outlined,
                  color: dest.isActive ? Colors.red : null,
                ),
                title: Text(dest.placeName ?? 'Unknown location',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(label),
                dense: true,
              );
            },
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Destination search dialog ────────────────────────────────────────────────

class _DestinationSearchDialog extends StatefulWidget {
  final ValueChanged<NominatimResult> onSelected;
  final DestinationService destinationService;

  const _DestinationSearchDialog({
    required this.onSelected,
    required this.destinationService,
  });

  @override
  State<_DestinationSearchDialog> createState() => _DestinationSearchDialogState();
}

class _DestinationSearchDialogState extends State<_DestinationSearchDialog> {
  final _controller = TextEditingController();
  List<NominatimResult> _results = [];
  bool _loading = false;
  Timer? _debounce;

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _loading = true);
      final results = await widget.destinationService.searchPlaces(query);
      if (mounted) setState(() { _results = results; _loading = false; });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search for a location…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onChanged,
            ),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            if (!_loading && _results.isEmpty && _controller.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No results found.'),
              ),
            if (_results.isNotEmpty) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, i) => ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(_results[i].displayName,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelected(_results[i]);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  '© OpenStreetMap contributors · Nominatim',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
