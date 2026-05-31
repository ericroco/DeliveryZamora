import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_customer/main.dart';

void main() {
  testWidgets('app smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DeliveryZamoraApp()));
    await tester.pump();
    expect(find.byType(DeliveryZamoraApp), findsOneWidget);
  });
}
