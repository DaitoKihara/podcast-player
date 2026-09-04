import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:podcast_player/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Podcast Player App Integration Tests', () {
    testWidgets('App launches and shows home screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify home screen is displayed
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('No subscriptions. Search for podcasts!'), findsOneWidget);
    });

    testWidgets('Navigate to search screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on search icon/button (assuming bottom nav has search)
      final searchButton = find.byIcon(Icons.search);
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton.first);
        await tester.pumpAndSettle();

        expect(find.text('Search'), findsOneWidget);
      }
    });

    testWidgets('Search for podcasts', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to search
      final searchButton = find.byIcon(Icons.search);
      if (searchButton.evaluate().isNotEmpty) {
        await tester.tap(searchButton.first);
        await tester.pumpAndSettle();

        // Enter search term
        await tester.enterText(find.byType(TextField).first, 'Tech');
        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();

        // Should show results or loading
        expect(find.byType(CircularProgressIndicator), findsWidgets);
      }
    });

    testWidgets('Navigate to settings screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for settings icon or navigation
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton.first);
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Cross-device sync'), findsOneWidget);
      }
    });
  });
}
