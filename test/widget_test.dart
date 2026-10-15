// Basic smoke test for the SWIFT NET app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:swift_net/main.dart';

void main() {
  testWidgets('WelcomeLoginPage renders', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SwiftNetApp());

    // Verify the welcome login screen is shown.
    expect(find.text('WELCOME TO\nSWIFT NET'), findsOneWidget);
    expect(find.text('[ ENTER ]'), findsOneWidget);
  });
}
