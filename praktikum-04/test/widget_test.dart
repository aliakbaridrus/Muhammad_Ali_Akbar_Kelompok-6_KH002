import 'package:flutter_test/flutter_test.dart';
import 'package:praktikum_04/main.dart';

void main() {
  testWidgets('Profile card displays user info and GitHub button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Personal Profile Card'), findsOneWidget);
    expect(find.text('Muhammad Ali Akbar'), findsOneWidget);
    expect(find.text('20240801218'), findsOneWidget);
    expect(find.text('Kunjungi GitHub Saya'), findsOneWidget);
  });
}
