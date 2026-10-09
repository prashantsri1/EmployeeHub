import 'package:employee_hub/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const EmployeeHub());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
