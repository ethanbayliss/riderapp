import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/ride_membership.dart';
import '../models/rider_location.dart';
import '../notifiers/ride_notifier.dart';
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
  final _mapController = MapController();

  List<RiderLocation> _riderLocations = [];
  Position? _myPosition;
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<List<RiderLocation>>? _locationsSub;
  Timer? _broadcastTimer;

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

    // Centre on initial position immediately
    final initial = await _locationService.getCurrentPosition();
    if (initial != null && mounted) {
      setState(() => _myPosition = initial);
      _mapController.move(LatLng(initial.latitude, initial.longitude), 15);
      _centred = true;
      await _upsertPosition(initial);
    }

    // Subscribe to live rider locations from Supabase
    _locationsSub = _locationService
        .riderLocationsStream(widget.membership.ride.id)
        .listen((locs) {
      if (mounted) setState(() => _riderLocations = locs);
    });

    // Stream GPS position updates → update map marker
    _positionSub = _locationService.positionStream().listen((pos) {
      if (!mounted) return;
      setState(() => _myPosition = pos);
      if (!_centred) {
        _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
        _centred = true;
      }
    });

    // Broadcast own position to Supabase every 4 seconds
    _broadcastTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      final pos = _myPosition;
      if (pos != null) await _upsertPosition(pos);
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

  @override
  void dispose() {
    _broadcastTimer?.cancel();
    _positionSub?.cancel();
    _locationsSub?.cancel();
    super.dispose();
  }

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

    _broadcastTimer?.cancel();
    _positionSub?.cancel();
    _locationsSub?.cancel();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.membership.ride.name),
        actions: [
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

    final riderCount = _riderLocations.length;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(0, 0),
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate: _isSatellite
                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.riderapp',
            ),
            MarkerLayer(markers: _buildMarkers(context)),
            if (!_isSatellite)
              const RichAttributionWidget(attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ]),
            if (_isSatellite)
              const RichAttributionWidget(attributions: [
                TextSourceAttribution('Esri'),
              ]),
          ],
        ),
        // Rider count chip
        Positioned(
          top: 12,
          right: 12,
          child: Chip(
            avatar: const Icon(Icons.directions_bike, size: 16),
            label: Text('$riderCount ${riderCount == 1 ? 'rider' : 'riders'}'),
          ),
        ),
        // Re-centre button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'centre',
            tooltip: 'Centre on my location',
            onPressed: () {
              final pos = _myPosition;
              if (pos != null) {
                _mapController.move(LatLng(pos.latitude, pos.longitude), _mapController.camera.zoom);
              }
            },
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers(BuildContext context) {
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
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

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
