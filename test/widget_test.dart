// Basic smoke test for the Alamein Patient Portal.
//
// It just checks that the app boots and shows the Dev Menu. Each developer
// should add focused tests for their own screen later.

import 'package:flutter_test/flutter_test.dart';

import 'package:abcde_app_v1_2/main.dart';

void main() {
  testWidgets('App boots and shows the Dev Menu', (WidgetTester tester) async {
    await tester.pumpWidget(const AlameinApp());

    expect(find.text('Dev Menu - pick a screen'), findsOneWidget);
    // TODO: add per-screen tests.
  });
}
