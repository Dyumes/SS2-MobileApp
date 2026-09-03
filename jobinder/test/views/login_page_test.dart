import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobinder/providers/auth_provider.dart';
import 'package:jobinder/view/login_view.dart';
import 'package:provider/provider.dart';

import '../fakes.dart';

void main() {
  testWidgets('email check is enforced', (tester) async {
    final authService = FakeAuthService();
    authService.signInError = 'Wrong password provided for that user.';

    // "Inject" the FakeAuthService into AuthProvider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authService),
        child: const MaterialApp(home: LoginView()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0),'oopsieIForgotTheAtSign.com',);
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');

    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await tester.pumpAndSettle(); // Waits for animations to finish

    expect(find.text('Please enter a valid email'), findsOneWidget);

    authService.dispose();
  });
}
