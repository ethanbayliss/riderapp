import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Returns true if email confirmation is required before the user can log in.
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    if (response.user == null) {
      throw Exception('Registration failed. Please try again.');
    }

    if (response.user!.identities?.isEmpty ?? false) {
      throw const AuthException('An account with this email already exists.');
    }

    return response.session == null;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
