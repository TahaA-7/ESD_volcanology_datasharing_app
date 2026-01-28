import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

// NOTE: this code basically doesn't use assets/events_mock.json since JSON files are read-only in development mode (so during runtime),
// but the file is still needed to seed the locally stored document that is used as a mock runup to show events on the timeline ALONGSIDE
// the events that the user can upload, so it is NOT the only file

class MockDataUpdater {
  static Future<void> updateMockDataTimestamps() async {
    try {
      // Load the mock JSON from assets
      final String jsonString = await rootBundle.loadString('assets/events_mock.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> events = data['events'] as List<dynamic>;
      
      final DateTime now = DateTime.now();
      final Random random = Random();
      
      // Update each event's timestamps
      for (var event in events) {
        // Generate random offset (0-3 days in the past)
        final int hoursOffset = random.nextInt(72); // 0-72 hours (3 days)
        final DateTime endTime = now.subtract(Duration(hours: hoursOffset));
        
        // Parse original duration
        final int durationMs = event['duration'] as int;
        final DateTime startTime = endTime.subtract(Duration(milliseconds: durationMs));
        
        // Update the event
        event['startTime'] = startTime.toIso8601String();
        event['timeRange'] = {
          'start': startTime.toIso8601String(),
          'end': endTime.toIso8601String(),
        };
      }
      
      // Save to app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/events_mock.json');
      
      // Write updated events
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert({'events': events}), mode: FileMode.write);
      // await file.writeAsString(jsonEncode({'events': events}));
      
      print('Mock data updated successfully with recent timestamps');
      print('Events saved to: assets/events.json');
    } catch (e) {
      print('Error updating mock data: $e');
      // Don't throw - app should continue even if mock data update fails
    }
  }
  
  /// Check if mock data needs updating (file doesn't exist or is old)
  static Future<bool> shouldUpdateMockData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      // final file = File('assets/events_mock.json'); 
      final file = File('${directory.path}/events_mock.json');
      
      if (!await file.exists()) {
        return true;
      }
      
      // Check if file is older than 1 day
      final stat = await file.stat();
      final age = DateTime.now().difference(stat.modified);
      return age.inDays >= 1;
    } catch (e) {
      return true;
    }
  }

  /// Load events (from documents dir if exists, otherwise from assets)
  static Future<List<dynamic>> loadEvents() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/events_mock.json');
    
    if (await file.exists()) {
      final String jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return data['events'] as List<dynamic>;
    } else {
      // Fall back to assets
      final String jsonString = await rootBundle.loadString('assets/events_mock.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return data['events'] as List<dynamic>;
    }
  }
}
