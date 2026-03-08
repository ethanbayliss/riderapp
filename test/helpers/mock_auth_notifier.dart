import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riderapp/notifiers/auth_notifier.dart';

/// A mock AuthNotifier that also correctly implements ChangeNotifier's
/// listener management so ListenableBuilder works in widget tests.
class MockAuthNotifier extends Mock implements AuthNotifier {
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  @override
  bool get hasListeners => _listeners.isNotEmpty;

  @override
  void dispose() {}

  void _notifyAll() {
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  /// Call this in tests to simulate a state change (e.g. after login).
  void notifyAll() => _notifyAll();
}
