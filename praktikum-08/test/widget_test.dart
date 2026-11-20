import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_08/main.dart';

void main() {
  testWidgets('Praktikum 08 displays User and Admin tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Praktikum08App());
    expect(find.textContaining('20240801218'), findsOneWidget);
  });
}
