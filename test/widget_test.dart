import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:unipoa_beneficiarios/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts on the splash screen and shows branding',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UnipoaApp());
    await tester.pump();

    expect(find.text('Uniodonto Porto Alegre'), findsOneWidget);
    expect(find.text('Beneficiários'), findsOneWidget);

    // Flush the splash screen's pending delayed future so the test doesn't
    // end with a dangling Timer.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('Splash navigates to the login screen once no session exists',
      (WidgetTester tester) async {
    await tester.pumpWidget(const UnipoaApp());
    await tester.pump();
    // Advance past the branding delay and the route transition animation.
    // Not using pumpAndSettle: the splash's indeterminate progress indicator
    // animates forever, so pumpAndSettle would never converge.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Número da carteirinha'), findsOneWidget);
  });
}
