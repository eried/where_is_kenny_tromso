import 'package:flutter_test/flutter_test.dart';
import 'package:where_is_kenny/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const WhereIsKennyApp());

    // Verify the app title appears somewhere
    expect(find.textContaining('Kenny'), findsWidgets);
  });
}
