// test/presentation/widgets/login_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:getx/features/auth/presentation/widgets/login_form.dart';

void main() {
  testWidgets('CRITICAL: LoginPage renders and submits', (tester) async {
    bool didSubmit = false;
    await tester.pumpWidget(MaterialApp(
        // home: Scaffold(
        //   body: LoginPage(
        //     onLogin: (email, pass) {
        //       didSubmit = true;
        //     },
        //   ),
        // ),
        ));

    // Verify form fields are present
    expect(find.byType(LoginForm), findsOneWidget);

    // Enter and submit
    await tester.enterText(find.byType(TextField).first, 'u@e.com');
    await tester.enterText(find.byType(TextField).last, 'Pass@123');
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(didSubmit, true);
  });
}
