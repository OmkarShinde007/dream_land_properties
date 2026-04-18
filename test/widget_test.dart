import 'package:flutter_test/flutter_test.dart';

import 'package:dream_land_properties/app.dart';

void main() {
  testWidgets('renders multipage Dream Land Properties website',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DreamLandPropertiesApp());
    await tester.pumpAndSettle();

    expect(find.text('Dream Land Properties'), findsOneWidget);
    expect(find.text('Dream Land Properties Information Website'), findsOneWidget);

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(find.text('All Projects'), findsOneWidget);
    expect(find.text('Dream Orchid Residency'), findsOneWidget);

    await tester.tap(find.text('Contact Us'));
    await tester.pumpAndSettle();
    expect(find.text('Request Callback'), findsOneWidget);
    expect(find.text('Submit Enquiry'), findsOneWidget);

    await tester.tap(find.text('About Us'));
    await tester.pumpAndSettle();
    expect(find.text('LEGACY JOURNEY'), findsOneWidget);
    expect(find.text('Manoj More'), findsOneWidget);
    expect(find.text('Vaibhav Shinde'), findsOneWidget);
    expect(find.text('2000'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
  });
}
