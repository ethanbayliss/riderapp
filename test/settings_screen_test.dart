import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riderapp/screens/home_screen.dart';
import 'package:riderapp/screens/login_screen.dart';
import 'package:riderapp/screens/settings_screen.dart';

import 'helpers/mock_auth_notifier.dart';
import 'helpers/mock_ride_notifier.dart';

/// Simulates the real app root — switches between Home and Login based on auth state.
Widget _makeApp(MockAuthNotifier notifier, MockRideNotifier rideNotifier) => MaterialApp(
      home: ListenableBuilder(
        listenable: notifier,
        builder: (context, _) {
          if (notifier.isLoggedIn) {
            return HomeScreen(authNotifier: notifier, rideNotifier: rideNotifier);
          }
          return LoginScreen(authNotifier: notifier);
        },
      ),
    );

void main() {
  late MockAuthNotifier authNotifier;
  late MockRideNotifier rideNotifier;

  setUp(() {
    authNotifier = MockAuthNotifier();
    rideNotifier = MockRideNotifier();
    when(() => authNotifier.currentUser).thenReturn(null);
    when(() => authNotifier.isLoggedIn).thenReturn(true);
    when(() => rideNotifier.myRides).thenReturn([]);
    when(() => rideNotifier.loadMyRides(any())).thenAnswer((_) async {});
  });

  testWidgets('home screen has settings icon in app bar', (tester) async {
    await tester.pumpWidget(_makeApp(authNotifier, rideNotifier));

    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('tapping settings icon navigates to SettingsScreen', (tester) async {
    await tester.pumpWidget(_makeApp(authNotifier, rideNotifier));

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('settings screen has log out option', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: SettingsScreen(authNotifier: authNotifier),
    ));

    expect(find.text('Log out'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });

  testWidgets('tapping log out navigates back to LoginScreen', (tester) async {
    when(() => authNotifier.logout()).thenAnswer((_) async {
      when(() => authNotifier.isLoggedIn).thenReturn(false);
      authNotifier.notifyAll();
    });

    await tester.pumpWidget(_makeApp(authNotifier, rideNotifier));

    // Navigate to Settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    // Tap Log out
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    // Should be on LoginScreen, not SettingsScreen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
  });
}
