part of 'event_post_model.dart';

enum EventSubtypeMM {
  debrisFlow,
  mudFlow,
  lahar,
  avalanche,
  slopeFailure,
  groundCollapse,
  sinkholeFormation,
  other,
}

class EventMassMovement extends Event {
  final EventSubtypeMM eventSubtype;

  double? volumeM3;              // Estimated volume
  double? velocityMetersPerSecond;
  double? runoutDistanceMeters;  // Horizontal travel distance
  double? slopeAngleDegrees;

  String trigger = ""; // earthquake, rainfall, eruption
  bool secondaryHazard = false; // Triggered by another event?

  // int? fatalities;
  // int? injuries;
  // int? displaced;

  // String material = ""; // rock, soil, ice, debris
  // String damageDescription = "";

  EventMassMovement({
    super.id,
    required this.eventSubtype,
    }) : super(eventType: EventType.massMovement_surfaceInstability);
}