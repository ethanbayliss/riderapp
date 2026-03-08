import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riderapp/notifiers/ride_notifier.dart';

class MockRideNotifier extends Mock implements RideNotifier {
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  bool get hasListeners => _listeners.isNotEmpty;

  @override
  void dispose() {}
}
