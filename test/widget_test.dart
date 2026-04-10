// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trying_flutter/controllers/pet_controller.dart';
import 'package:trying_flutter/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts and shows Tamagotchi home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => PetController()..init(),
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tamagotchi'), findsOneWidget);
    expect(find.text('Alimentar'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
