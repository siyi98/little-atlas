import 'package:flutter_test/flutter_test.dart';
import 'package:baby_tracker/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const BabyTrackerApp());
    expect(find.text('Little Atlas'), findsOneWidget);
  });
}
