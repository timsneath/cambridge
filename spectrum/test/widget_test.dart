// widget_test.dart -- test basic Flutter application

import 'package:flutter_test/flutter_test.dart';

import 'package:ui/main.dart';

void main() {
  testWidgets('Initial test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ProjectCambridge());

    expect(tester.allElements.length, greaterThan(0));
  });
}
