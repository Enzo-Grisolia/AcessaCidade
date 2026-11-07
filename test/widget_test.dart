import 'package:acessacidade/core/app_theme.dart';
import 'package:acessacidade/models/incident.dart';
import 'package:acessacidade/widgets/ui_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('o status confirmado tem rótulo textual além da cor', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: appTheme(),
      home: const Scaffold(body: StatusChip(status: IncidentStatus.confirmed)),
    ));
    expect(find.text('Confirmado'), findsOneWidget);
  });
}
