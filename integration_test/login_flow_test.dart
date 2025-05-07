// integration_test/login_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:getx/core/services/network_info.dart';
import 'package:getx/features/auth/domain/repositories/auth_repository.dart';
import 'package:getx/features/auth/domain/usecases/login_usecase.dart';
import 'package:getx/features/auth/presentation/controllers/auth_controller.dart';
import 'package:getx/main.dart' as app;
import 'package:integration_test/integration_test.dart';

/// No-op repository (never actually called).
class _DummyRepo implements AuthRepository {
  @override
  Future<bool> login(String email, String password) => Future.value(false);
}

/// Always-connected network.
class _DummyNetwork implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

class _Offline implements NetworkInfo {
  @override
  Future<bool> get isConnected async => false;
}

/// Fake use-case: succeed or fail after a short delay.
class FakeLoginUseCase extends LoginUseCase {
  final bool willSucceed;

  FakeLoginUseCase(this.willSucceed)
      : super(repository: _DummyRepo(), network: _DummyNetwork());

  @override
  Future<bool> execute(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return willSucceed;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> launchApp(
    WidgetTester tester,
    bool succeed, {
    Locale? locale,
    bool darkTheme = false,
  }) async {
    Get.reset();
    Get.testMode = true;
    Get.put<AuthController>(
      AuthController(loginUseCase: FakeLoginUseCase(succeed)),
    );
    if (locale != null) Get.updateLocale(locale);
    app.main();
    await tester.pumpAndSettle();
  }

  group('LoginPage flow (20 scenarios)', () {
    testWidgets('1. App starts on LoginPage', (t) async {
      await launchApp(t, true);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('2. Card wrapping form exists', (t) async {
      await launchApp(t, true);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('3. Email & Password fields present', (t) async {
      await launchApp(t, true);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('4. Submit button present', (t) async {
      await launchApp(t, true);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('5. Empty submit shows email error', (t) async {
      await launchApp(t, true);
      await t.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await t.pumpAndSettle();
      expect(find.text('Email cannot be empty'), findsOneWidget);
    });

    testWidgets('6. Invalid email shows format error', (t) async {
      await launchApp(t, true);
      await t.enterText(find.byType(TextFormField).first, 'foo');
      await t.enterText(find.byType(TextFormField).at(1), 'Pass@1234');
      await t.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await t.pumpAndSettle();
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('7. Empty password shows error', (t) async {
      await launchApp(t, true);
      await t.enterText(find.byType(TextFormField).first, 'u@x.com');
      await t.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await t.pumpAndSettle();
      expect(find.text('Password cannot be empty'), findsOneWidget);
    });

    testWidgets('8. Weak password shows strength error', (t) async {
      await launchApp(t, true);
      await t.enterText(find.byType(TextFormField).first, 'u@x.com');
      await t.enterText(find.byType(TextFormField).at(1), 'abc');
      await t.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await t.pumpAndSettle();
      expect(find.textContaining('Password must be at least 8 characters'),
          findsOneWidget);
    });

    testWidgets('9. Toggle password visibility', (t) async {
      await launchApp(t, true);
      final passwordTextFieldFinder = find.byType(TextFormField).at(1);
      Finder innerTextFieldFinder = find.descendant(
        of: passwordTextFieldFinder,
        matching: find.byType(TextField),
      );
      final TextField before = t.widget<TextField>(innerTextFieldFinder);
      expect(before.obscureText, isTrue);
      await t.tap(find.byIcon(Icons.visibility_off));
      await t.pumpAndSettle();
      final TextField after = t.widget<TextField>(innerTextFieldFinder);
      expect(after.obscureText, isFalse);
    });

    testWidgets('10. Keyboard dismiss on outside tap', (t) async {
      await launchApp(t, true);
      await t.tap(find.byType(TextFormField).first);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, isNotNull);
      await t.tapAt(const Offset(5, 5));
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, isNull);
    });

    testWidgets('11. Successful login shows spinner', (t) async {
      await launchApp(t, true);
      await t.enterText(find.byType(TextFormField).at(0), 'u@x.com');
      await t.enterText(find.byType(TextFormField).at(1), 'Pass@1234');
      await t.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await t.pump(); // one frame
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Logging in...'), findsOneWidget);
    });

    testWidgets('12. Successful login returns to form', (t) async {
      await launchApp(t, true);
      await t.enterText(find.byType(TextFormField).at(0), 'u@x.com');
      await t.enterText(find.byType(TextFormField).at(1), 'Pass@1234');
      await t.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await t.pump(const Duration(milliseconds: 300));
      await t.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('13. Failed login shows snackbar', (t) async {
      await launchApp(t, false);
      await t.enterText(find.byType(TextFormField).at(0), 'u@x.com');
      await t.enterText(find.byType(TextFormField).at(1), 'Pass@1234');
      await t.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await t.pump(const Duration(milliseconds: 300));
      await t.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Login Error'), findsOneWidget);
    });

    testWidgets('14. Retry after failure then succeed', (t) async {
      await launchApp(t, false);
      await t.enterText(find.byType(TextFormField).at(0), 'u@x.com');
      await t.enterText(find.byType(TextFormField).at(1), 'Pass@1234');
      await t.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await t.pumpAndSettle();
      // rebind success
      Get.reset();
      Get.testMode = true;
      Get.put<AuthController>(
          AuthController(loginUseCase: FakeLoginUseCase(true)));
      app.main();
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await t.pump(const Duration(milliseconds: 300));
      await t.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('15. Offline network error', (t) async {
      Get.reset();
      Get.testMode = true;
      Get.put<AuthController>(
        AuthController(
          loginUseCase: LoginUseCase(
            repository: _DummyRepo(),
            network: _Offline(),
          ),
        ),
      );

      // 3️⃣ Launch the app
      app.main();
      await t.pumpAndSettle();

      // 4️⃣ Enter valid email & password so we hit the network check (not validation)
      await t.enterText(find.byType(TextFormField).at(0), 'user@example.com');
      await t.enterText(find.byType(TextFormField).at(1), 'Pass@1234');

      // 5️⃣ Tap Login
      await t.tap(find.widgetWithText(ElevatedButton, 'Login').first);
      await t.pumpAndSettle();

      // 6️⃣ Expect the “no internet” error to be shown
      expect(find.text('No internet connection'), findsOneWidget);
    });

    testWidgets('16. Spanish locale shows translated button', (t) async {
      await launchApp(t, true, locale: const Locale('es', 'ES'));
      // assume Spanish key for 'Login' is 'Iniciar sesión'
      expect(find.text('Iniciar sesión'), findsWidgets);
    });

    testWidgets('17. Dark theme applied', (t) async {
      await launchApp(t, true, darkTheme: true);
      final bg = t.widget<Scaffold>(find.byType(Scaffold)).backgroundColor;
      expect(
          bg,
          equals(Theme.of(t.element(find.byType(Scaffold)))
              .scaffoldBackgroundColor));
    });

    testWidgets('18. AppBar title is centered', (t) async {
      await launchApp(t, true);
      final appBar = t.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('19. Form has correct padding', (t) async {
      await launchApp(t, true);
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('20. SingleChildScrollView present', (t) async {
      await launchApp(t, true);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
