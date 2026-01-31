import 'package:latlong2/latlong.dart';
import '../models/event_post_model.dart';
import 'dart:math' as math;

class EventCluster {
  final LatLng center;
  final List<Event> events;
  final int count;

  EventCluster({
    required this.center,
    required this.events,
  }) : count = events.length;

  bool get isCluster => count > 1;
}

class EventClusterManager {
  static const double _clusterRadiusPixels = 40.0; // Cluster if within 40 pixels
  
  /// Cluster events based on current zoom level
  static List<EventCluster> clusterEvents(
    List<Event> events,
    double zoom,
  ) {
    // At high zoom levels (>10), don't cluster
    if (zoom > 10) {
      return events
          .where((e) => e.latitude != null && e.longitude != null)
          .map((e) => EventCluster(
                center: LatLng(e.latitude!, e.longitude!),
                events: [e],
              ))
          .toList();
    }

    final clusters = <EventCluster>[];
    final processed = <Event>{};

    for (final event in events) {
      if (event.latitude == null || event.longitude == null) continue;
      if (processed.contains(event)) continue;

      final position = LatLng(event.latitude!, event.longitude!);
      final nearbyEvents = <Event>[event];

      // Find nearby events
      for (final otherEvent in events) {
        if (otherEvent.latitude == null || otherEvent.longitude == null) continue;
        if (processed.contains(otherEvent)) continue;
        if (event == otherEvent) continue;

        final otherPosition = LatLng(otherEvent.latitude!, otherEvent.longitude!);
        final distance = _calculateDistance(position, otherPosition);
        
        // Cluster radius decreases with zoom level
        final clusterRadius = _getClusterRadius(zoom);
        
        if (distance < clusterRadius) {
          nearbyEvents.add(otherEvent);
          processed.add(otherEvent);
        }
      }

      processed.add(event);

      // Calculate cluster center (average position)
      if (nearbyEvents.length > 1) {
        double avgLat = 0;
        double avgLng = 0;
        
        for (final e in nearbyEvents) {
          avgLat += e.latitude!;
          avgLng += e.longitude!;
        }
        
        avgLat /= nearbyEvents.length;
        avgLng /= nearbyEvents.length;

        clusters.add(EventCluster(
          center: LatLng(avgLat, avgLng),
          events: nearbyEvents,
        ));
      } else {
        clusters.add(EventCluster(
          center: position,
          events: nearbyEvents,
        ));
      }
    }

    return clusters;
  }

  static double _getClusterRadius(double zoom) {
    // Cluster radius in kilometers based on zoom level
    // Higher zoom = smaller cluster radius
    if (zoom < 3) return 500.0;
    if (zoom < 5) return 200.0;
    if (zoom < 7) return 100.0;
    if (zoom < 9) return 50.0;
    return 20.0;
  }

  static double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(point2.latitude - point1.latitude);
    final dLon = _toRadians(point2.longitude - point1.longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(point1.latitude)) *
            math.cos(_toRadians(point2.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}