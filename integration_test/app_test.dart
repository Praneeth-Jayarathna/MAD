import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fuel_tracker/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App integration', () {
    testWidgets('renders generators list with seeded data',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FuelTrackerApp());
      await tester.pumpAndSettle();

      // AppTitle is visible
      expect(find.text('Fuel Tracker'), findsOneWidget);

      // Generators tab is selected by default; seeded generators exist
      expect(find.text('Generator 01'), findsOneWidget);
      expect(find.text('Generator 02'), findsOneWidget);
      expect(find.text('Generator 03'), findsOneWidget);
      expect(find.text('Generator 04'), findsOneWidget);
    });

    testWidgets('bottom navigation switches tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FuelTrackerApp());
      await tester.pumpAndSettle();

      // Tap Report tab
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      // Report screen is visible
      expect(find.text('Last Week'), findsOneWidget);
      expect(find.text('Last Month'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);

      // Tap Generators tab
      await tester.tap(find.text('Generators'));
      await tester.pumpAndSettle();

      // Generator list is visible again
      expect(find.text('Generator 01'), findsOneWidget);
    });

    testWidgets('navigates to generator detail on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(const FuelTrackerApp());
      await tester.pumpAndSettle();

      // Tap first generator card
      await tester.tap(find.text('Generator 01'));
      await tester.pumpAndSettle();

      // Detail screen shows generator name
      expect(find.text('Generator 01'), findsOneWidget);

      // Detail screen has action buttons
      expect(find.text('Record Run'), findsOneWidget);
      expect(find.text('Add Fuel'), findsOneWidget);

      // Go back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Back on generator list
      expect(find.text('Generator 01'), findsOneWidget);
    });
  });
}
