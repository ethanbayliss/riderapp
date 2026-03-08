import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  final _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => currentUser != null;

  /// True when this device was signed out because the account logged in elsewhere.
  bool displacedSession = false;

  bool _intentionalLogout = false;

  AuthNotifier() {
    _authService.authStateChanges.listen((state) {
      if (state.event == AuthChangeEvent.signedOut && !_intentionalLogout) {
        displacedSession = true;
      }
      _intentionalLogout = false;
      notifyListeners();
    });
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final needsConfirmation = await _authService.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    notifyListeners();
    return needsConfirmation;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    displacedSession = false;
    await _authService.login(email: email, password: password);
    notifyListeners();
  }

  Future<void> logout() async {
    _intentionalLogout = true;
    await _authService.logout();
    notifyListeners();
  }

  Future<void> updateMarkerIcon(String icon) async {
    await _authService.updateMarkerIcon(icon);
    notifyListeners();
  }

  String get markerIcon =>
      currentUser?.userMetadata?['marker_icon'] as String? ?? 'motorcycle';
}
