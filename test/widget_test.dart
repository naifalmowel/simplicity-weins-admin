import 'package:flutter_test/flutter_test.dart';
import 'package:simplicity_admin/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SimplicityAdminApp());
    expect(find.byType(SimplicityAdminApp), findsOneWidget);
  });
}
