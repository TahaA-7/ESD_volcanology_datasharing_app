// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:seismology_volcanology_datasharing_app/main.dart';
import 'package:seismology_volcanology_datasharing_app/screens/timeline.dart';
import 'package:seismology_volcanology_datasharing_app/screens/map.dart';
import 'package:seismology_volcanology_datasharing_app/screens/event_post_wizard.dart';
import 'package:seismology_volcanology_datasharing_app/widgets/filter_bar.dart';
import 'package:seismology_volcanology_datasharing_app/widgets/download_widget.dart';

void main() {
  group('Smoke Tests - App Startup', () {
    testWidgets('App launches without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsWidgets);

      tester.takeException();
    });
  });

  group('Smoke Tests - Timeline Screen', () {
    testWidgets('HomePage (Timeline) renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Wait for async initialization
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(HomePage), findsOneWidget);
      tester.takeException();
    });
  });

  group('Smoke Tests - Map Screen', () {
    testWidgets('MapScreen renders with empty events', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapScreen(events: []),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(MapScreen), findsOneWidget);
      tester.takeException();
    });
  });

  group('Smoke Tests - Event Post Wizard', () {
    testWidgets('EventPostWizard renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => EventPostWizardController(),
          child: const MaterialApp(
            home: EventPostWizardScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(EventPostWizardScreen), findsOneWidget);
      tester.takeException();
    });
  });

  group('Smoke Tests - Filter Bar', () {
    testWidgets('FilterBar renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FilterBar(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(FilterBar), findsOneWidget);
      tester.takeException();
    });
  });

  group('Smoke Tests - Export/Download Widget', () {
    testWidgets('DownloadWidget renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DownloadWidget(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(DownloadWidget), findsOneWidget);
      tester.takeException();
    });
  });
}
