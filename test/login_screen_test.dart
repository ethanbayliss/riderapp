import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riderapp/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helpers/mock_auth_notifier.dart';

Widget _makeApp(MockAuthNotifier notifier) => MaterialApp(
      home: LoginScreen(authNotifier: notifier),
    );

void main() {
  late MockAuthNotifier authNotifier;

  setUp(() {
    authNotifier = MockAuthNotifier();
    when(() => authNotifier.isLoggedIn).thenReturn(false);
    when(() => authNotifier.currentUser).thenReturn(null);
  });

  testWidgets('shows email, password fields and login button', (tester) async {
    await tester.pumpWidget(_makeApp(authNotifier));

    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Log In'), findsOneWidget);
  });

  testWidgets('shows sign-up link', (tester) async {
    await tester.pumpWidget(_makeApp(authNotifier));

    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
  });

  testWidgets('validates empty fields without calling login', (tester) async {
    await tester.pumpWidget(_makeApp(authNotifier));

    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pump();

    verifyNever(() => authNotifier.login(email: any(named: 'email'), password: any(named: 'password')));
    expect(find.text('Enter your email'), findsOneWidget);
  });

  testWidgets('calls login with entered credentials', (tester) async {
    when(() => authNotifier.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenAnswer((_) async {});

    await tester.pumpWidget(_makeApp(authNotifier));

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'rider@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pump();

    verify(() => authNotifier.login(email: 'rider@example.com', password: 'password123')).called(1);
  });

  testWidgets('shows generic error on invalid credentials', (tester) async {
    when(() => authNotifier.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(const AuthException('Invalid login credentials'));

    await tester.pumpWidget(_makeApp(authNotifier));

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'rider@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrongpass');
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pump();

    expect(find.text('Invalid email or password.'), findsOneWidget);
    // Must not reveal which field is wrong
    expect(find.text('Invalid email.'), findsNothing);
    expect(find.text('Invalid password.'), findsNothing);
  });

  testWidgets('shows email-not-confirmed message when applicable', (tester) async {
    when(() => authNotifier.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(const AuthException('Email not confirmed'));

    await tester.pumpWidget(_makeApp(authNotifier));

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'rider@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
    await tester.pump();

    expect(
      find.text('Please verify your email before logging in. Check your inbox for the verification link.'),
      findsOneWidget,
    );
  });
}
