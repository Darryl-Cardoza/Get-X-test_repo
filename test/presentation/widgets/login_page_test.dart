import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx/features/auth/presentation/views/login_page.dart';
import 'package:getx/features/auth/presentation/widgets/login_form.dart';

void main() {
  testWidgets('CRITICAL: LoginPage renders and submits', (tester) async {
    bool didSubmit = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LoginPage(
          // onLogin: (email, pass) {
          //   didSubmit = true;
          // },
        ),
      ),
    ));

    // Wait for everything to build
    await tester.pumpAndSettle();

    // Verify LoginForm is present
    expect(find.byType(LoginForm), findsOneWidget);

    // Enter email and password
    await tester.enterText(find.byType(TextField).first, 'u@e.com');
    await tester.enterText(find.byType(TextField).last, 'Pass@123');

    // Tap login button
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify submit was called
    expect(didSubmit, true);
  });
}
