import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  final _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  bool get isLoggedIn => currentUser != null;

  AuthNotifier() {
    _authService.authStateChanges.listen((_) => notifyListeners());
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
    await _authService.login(email: email, password: password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
