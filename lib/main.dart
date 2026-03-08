import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notifiers/auth_notifier.dart';
import 'notifiers/ride_notifier.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const RiderApp());
}

class RiderApp extends StatefulWidget {
  const RiderApp({super.key});

  @override
  State<RiderApp> createState() => _RiderAppState();
}

class _RiderAppState extends State<RiderApp> {
  final _authNotifier = AuthNotifier();
  final _rideNotifier = RideNotifier();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiderApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: ListenableBuilder(
        listenable: _authNotifier,
        builder: (context, _) {
          if (_authNotifier.isLoggedIn) {
            return HomeScreen(authNotifier: _authNotifier, rideNotifier: _rideNotifier);
          }
          return LoginScreen(authNotifier: _authNotifier);
        },
      ),
    );
  }
}
