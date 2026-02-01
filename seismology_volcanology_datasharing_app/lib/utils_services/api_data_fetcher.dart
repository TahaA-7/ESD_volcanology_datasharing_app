import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/event_post_model.dart';
import '../utils_services/event_drafter_submitter.dart';

class ReportGenerator {
  final EventSubmissionService _submissionService;

  ReportGenerator({EventSubmissionService? submissionService})
      : _submissionService = submissionService ?? EventSubmissionService();

  Future<List<Event>> fetchAndSubmitIngvEvents({
    DateTime? startTime,
    double minMagnitude = 2.0,  // otherwise too many
    bool asDraft = false,
  }) async {
    final events = await _fetchIngvEvents(
      startTime: startTime ?? DateTime.now().subtract(const Duration(days: 1)),
      minMagnitude: minMagnitude,
    );

    final submitted = <Event>[];

    for (final event in events) {
      try {
        event.draft = asDraft;
        await _submissionService.submit(event, draft: asDraft);
        submitted.add(event);
      } catch (e) {
        print('Failed to submit event: $e');
      }
    }

    return submitted;
  }

  Future<List<Event>> fetchAndPreview({
    DateTime? startTime,
    double minMagnitude = 2.0,
  }) async {
    return _fetchIngvEvents(
      startTime: startTime ?? DateTime.now().subtract(const Duration(days: 1)),
      minMagnitude: minMagnitude,
    );
  }

  // for now only INGV data supported

  Future<List<Event>> _fetchIngvEvents({
    required DateTime startTime,
    required double minMagnitude,
  }) async {
    final baseUrl = Uri.parse('https://webservices.ingv.it/fdsnws/event/1/query');

    // FDSN API requires this specific format (YYYY-MM-DDTHH:MM:SS without Z)
    final formattedStartTime = startTime.toUtc().toString().split('.')[0];

    final uri = baseUrl.replace(queryParameters: {
      'starttime': formattedStartTime,
      'minmagnitude': minMagnitude.toString(),
      'format': 'geojson',
      'orderby': 'time',
    });

    print('Fetching from INGV: $uri');

    final http.Response response;
    try {
      response = await http.get(uri);
    } catch (e) {
      throw Exception('Network error contacting INGV: $e');
    }

    if (response.statusCode != 200) {
      throw Exception('INGV returned HTTP ${response.statusCode}. Response: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final features = json['features'] as List<dynamic>? ?? [];

    if (features.isEmpty) {
      print('No events found for the given criteria');
      return [];
    }

    return features.map(_parseFeatureToEvent).toList();
  }

    // for now we only have seismic and volcanic events

  EventSeismic _parseFeatureToEvent(dynamic feature) {
    final props = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coords = geometry['coordinates'] as List<dynamic>;

    // GeoJSON order: [longitude, latitude, depth_km]
    final double longitude = (coords[0] as num).toDouble();
    final double latitude = (coords[1] as num).toDouble();
    final double? depthKm = coords.length > 2 ? (coords[2] as num).toDouble() : null;

    // Parse time - INGV can return it as ISO8601 string or milliseconds
    final dynamic timeValue = props['time'];
    final DateTime eventTime;
    
    if (timeValue is String) {
      // Parse ISO8601 string (e.g., "2026-01-30T12:34:56.789Z")
      eventTime = DateTime.parse(timeValue);
    } else if (timeValue is int) {
      // Parse epoch milliseconds
      eventTime = DateTime.fromMillisecondsSinceEpoch(timeValue, isUtc: true);
    } else {
      // Fallback to current time if parsing fails
      print('Warning: Could not parse time value: $timeValue');
      eventTime = DateTime.now();
    }

    final event = EventSeismic(
      eventSubtype: EventSubtypeSeismic.unspecified,
    );

    // There is no way we can populate `event.country` that easily...
    event.longitude = longitude;
    event.latitude = latitude;
    event.startTime = eventTime;
    event.timeRange = DateTimeRange(start: eventTime, end: eventTime);
    event.duration = event.timeRange!.duration;  // otherwise it won't work with auto-imported INGV events
    event.source = 'INGV (auto-imported)';
    event.description = props['place'] as String? ?? '';
    event.status = EventPostStatus.automatic;
    event.draft = true;

    // Populating SOME seismic-specific fields, this can be expanded to include other fields too
    event.magnitude = (props['mag'] as num?)?.toDouble();
    event.magnitudeType = props['magType'] as String?;
    event.depth = depthKm;

    return event;
  }
}
