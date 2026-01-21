// Basic smoke test for Digital Home Manager app.
import 'package:digital_home_manager/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App shows Home Card page on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const DigitalHomeManagerApp());

    // Expect the Home Card placeholder to be present
    expect(find.textContaining('Home Card'), findsOneWidget);
    expect(find.textContaining('Feature coming soon.'), findsOneWidget);
  });
}
