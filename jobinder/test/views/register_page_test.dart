import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/view/register_view.dart';
import 'package:provider/provider.dart';

import '../fakes.dart';

void main() {
  testWidgets('email check is enforced', (tester) async {
    final authService = FakeAuthService();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authService),
        child: const MaterialApp(home: RegisterView()),
      ),
    );

    // Email
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'oopsieIForgotTheAtSign.com',
    );

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Register'),
    );

    await tester.tap(
      find.widgetWithText(FilledButton, 'Register'),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a valid email'),
      findsOneWidget,
    );

    authService.dispose();
  });

  testWidgets('password confirmation must match', (tester) async {
    final authService = FakeAuthService();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authService),
        child: const MaterialApp(home: RegisterView()),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'John',
    );

    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Doe',
    );

    await tester.enterText(
      find.byType(TextFormField).at(3),
      'secret123',
    );

    await tester.enterText(
      find.byType(TextFormField).at(4),
      'different123',
    );

    await tester.enterText(
      find.byType(TextFormField).at(5),
      'Main Street 10',
    );

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Register'),
    );

    await tester.tap(
      find.widgetWithText(FilledButton, 'Register'),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Passwords do not match'),
      findsOneWidget,
    );

    authService.dispose();
  });

  testWidgets('student address is required', (tester) async {
    final authService = FakeAuthService();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authService),
        child: const MaterialApp(home: RegisterView()),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'user@example.com',
    );

    await tester.enterText(
      find.byType(TextFormField).at(1),
      'John',
    );

    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Doe',
    );

    await tester.enterText(
      find.byType(TextFormField).at(3),
      'secret123',
    );

    await tester.enterText(
      find.byType(TextFormField).at(4),
      'secret123',
    );

    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Register'),
    );

    await tester.tap(
      find.widgetWithText(FilledButton, 'Register'),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('Please enter an address'),
      findsOneWidget,
    );

    authService.dispose();
  });

  testWidgets('student fields are shown by default', (tester) async {
    final authService = FakeAuthService();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authService),
        child: const MaterialApp(home: RegisterView()),
      ),
    );
  
    expect(find.text('Choose a role'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Employer'), findsOneWidget);

    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Work history'), findsOneWidget);

    expect(find.text('Company'), findsNothing);
    expect(find.text('Canton'), findsNothing);

    authService.dispose();
  });

}