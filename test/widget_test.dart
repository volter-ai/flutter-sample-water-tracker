import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:water_tracker/main.dart';

void main() {
  testWidgets('Water tracker initial state test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the provider to load data
    await tester.pumpAndSettle();

    // Verify that the app shows water tracker elements
    expect(find.text('Water Tracker'), findsOneWidget);
    expect(find.text('ml'), findsAtLeastNWidgets(1));
    expect(find.text('Quick Add'), findsOneWidget);

    // Verify quick add buttons exist
    expect(find.text('250 ml'), findsOneWidget);
    expect(find.text('500 ml'), findsOneWidget);
    expect(find.text('750 ml'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('Add water test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for the provider to load data
    await tester.pumpAndSettle();

    // Find and tap the 250ml button
    await tester.tap(find.text('250 ml'));
    await tester.pumpAndSettle();

    // Verify that an entry was added to the list
    expect(find.text('Today\'s Entries'), findsOneWidget);
    expect(find.byIcon(Icons.water_drop), findsAtLeastNWidgets(1));
  });
}
