import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('shows the NOVOX login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NovoxApp());

    expect(find.text('NOVOX'), findsOneWidget);
    expect(find.text('Education Management'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
