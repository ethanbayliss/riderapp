import 'package:flutter/material.dart';

const String kDefaultMarkerIcon = 'motorcycle';

/// Predefined set of icons a rider can choose to represent themselves on the map.
const Map<String, IconData> kMarkerIcons = {
  'motorcycle': Icons.motorcycle,
  'two_wheeler': Icons.two_wheeler,
  'directions_bike': Icons.directions_bike,
  'sports_motorsports': Icons.sports_motorsports,
  'local_shipping': Icons.local_shipping,
  'bolt': Icons.bolt,
  'star': Icons.star,
  'local_fire_department': Icons.local_fire_department,
};

IconData iconForKey(String? key) =>
    kMarkerIcons[key] ?? kMarkerIcons[kDefaultMarkerIcon]!;
