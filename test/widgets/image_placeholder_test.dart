import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tracker/screens/generators_screen.dart';

void main() {
  testWidgets('imagePlaceholder renders with default height',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: imagePlaceholder(null, null),
        ),
      ),
    );

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(
      find.byType(Container),
      findsWidgets,
    );
  });

  testWidgets('imagePlaceholder renders with custom dimensions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: imagePlaceholder(200, 150),
        ),
      ),
    );

    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
  });

  testWidgets('buildGeneratorImage works with asset path',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: buildGeneratorImage(
            'assets/images/gen1.jpeg',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );

    // Widget renders without crashing
    expect(find.byType(Image), findsOneWidget);
  });
}
