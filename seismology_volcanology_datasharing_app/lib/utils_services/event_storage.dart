import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/event_post_model.dart';
import 'package:flutter/material.dart';
import 'geocoding_helper.dart';
import 'mock_data_updater.dart';

class EventStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/events.json');
  }

  static Future<List<Event>> loadEvents() async {
    try {
      // Load user events
      final userEvents = await _loadUserEvents();
      
      // Load mock events
      final mockEvents = await _loadMockEvents();
      
      // Combine both lists
      return [...mockEvents, ...userEvents];
    } catch (e) {
      print('Error loading events: $e');
      return [];
    }
  }

  static Future<List<Event>> _loadUserEvents() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      
      return _parseEventsList(jsonList);
    } catch (e) {
      print('Error loading user events: $e');
      return [];
    }
  }

  static Future<List<Event>> _loadMockEvents() async {
    try {      
      // Load mock events
      final mockJsonList = await MockDataUpdater.loadEvents();
      return _parseEventsList(mockJsonList);
    } catch (e) {
      print('Error loading mock events: $e');
      return [];
    }
  }

  static List<Event> _parseEventsList(List<dynamic> jsonList) {
    return jsonList.map((json) {
      final eventTypeStr = json['eventType'] as String? ?? 'unspecified_anomalous';
      final eventType = EventType.values.firstWhere(
        (e) => e.name == eventTypeStr,
        orElse: () => EventType.unspecified_anomalous,
      );
      
      final Event event;
      switch (eventType) {
        case EventType.seismic_tectonic:
          event = EventSeismic(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeSeismic.other,
          );
          break;
        case EventType.volcanicEruptive_surfaceProcess:
          event = EventVolcanicEruptive(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeVolcanicE.other,
          );
          break;
        case EventType.volcanicNonEruptive:
          event = EventVolcanicNonEruptive(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeVolcanicNE.other,
          );
          break;
        case EventType.massMovement_surfaceInstability:
          event = EventMassMovement(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeMM.other,
          );
          break;
        case EventType.cryoseismic_glacial:
          event = EventCryoseismic(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeCryoseismic.other,
          );
          break;
        case EventType.hydrothermal_fluidDriven:
          event = EventHydrothermal(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeHydrothermal.other,
          );
          break;
        case EventType.atmospheric_coupledSignals:
          event = EventAtmospheric(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeAtmospheric.other,
          );
          break;
        case EventType.anthropogenic:
          event = EventAnthropogenic(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeAnthropogenic.other,
          );
          break;
        case EventType.geodetic_deformation:
          event = EventGeodetic(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeGeodetic.other,
          );
          break;
        case EventType.multiSensor:
          event = EventMultisensor(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeMultisensor.default_,
          );
          break;
        case EventType.false_test:
          event = EventFalseTest(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeFalseTest.default_,
          );
          break;
        case EventType.unspecified_anomalous:
        default:
          event = EventMultisensor(
            id: json['id'] as String?,
            eventSubtype: EventSubtypeMultisensor.default_,
          );
      }
      
      
      event.country = Country.values.firstWhere(
        (c) => c.name == (json['country'] as String? ?? 'unspecified'),
        orElse: () => Country.unspecified,
      );
      event.stateProvince = json['stateProvince'] as String? ?? '';
      event.townCity = json['townCity'] as String? ?? '';
      event.longitude = (json['longitude'] as num?)?.toDouble();
      event.latitude = (json['latitude'] as num?)?.toDouble();
      
      // If no coordinates, geocode from country
      if (event.latitude == null || event.longitude == null) {
        final coords = GeocodingHelper.getCoordinatesForEvent(event);
        if (coords != null) {
          event.latitude = coords.latitude;
          event.longitude = coords.longitude;
        }
      }
      
      event.duration = Duration(microseconds: (json['duration'] as int?) ?? 0);
      
      if (json['startTime'] != null) {
        event.startTime = DateTime.tryParse(json['startTime'] as String);
      }
      
      if (json['timeRange'] != null && json['timeRange'] is Map) {
        final tr = json['timeRange'] as Map;
        final start = DateTime.tryParse(tr['start'] as String? ?? '');
        final end = DateTime.tryParse(tr['end'] as String? ?? '');
        if (start != null && end != null) {
          event.timeRange = DateTimeRange(start: start, end: end);
        }
      }
      
      event.source = json['source'] as String? ?? '';
      event.description = json['description'] as String? ?? '';
      event.draft = json['draft'] as bool? ?? true;
      
      return event;
    }).toList();
  }

  static Future<void> saveEvents(List<Event> events) async {
    try {
      final file = await _localFile;
      final jsonList = events.map((e) => e.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      print('Events saved to: ${file.path}');
    } catch (e) {
      print('Error saving events: $e');
    }
  }

  static Future<void> addEvent(Event event) async {
    final events = await _loadUserEvents();
    events.add(event);
    await saveEvents(events);
  }
}