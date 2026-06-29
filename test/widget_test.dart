import 'package:flutter_test/flutter_test.dart';
import 'package:dice_days/main.dart';

void main() {
  testWidgets('App renders join screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DiceDaysApp());
    expect(find.text('DICE DAYS'), findsOneWidget);
    expect(find.text('Beitreten'), findsOneWidget);
  });
}
