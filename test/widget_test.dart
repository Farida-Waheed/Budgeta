import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budgeta_app/app/app.dart'; 

void main() {
  testWidgets('Budgeta smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BudgetaApp());

    // Verify at least one widget renders.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
