import 'package:flutter_test/flutter_test.dart';
import 'package:gear_and_trail/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GearTrailApp());

    // Verify that our login screen is shown.
    expect(find.text('Gear & Trail'), findsOneWidget);
  });
}
