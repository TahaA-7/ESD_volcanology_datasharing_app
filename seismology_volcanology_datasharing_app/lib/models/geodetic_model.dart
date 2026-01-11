part of 'event_post_model.dart';

enum EventSubtypeGeodetic {
  groundUplift,
  groundSubsidence,
  tiltEvent,
  surfaceFracture,
  crackOpening,
  other,
}

class EventGeodetic extends Event {
  // Slow-moving or static changes often viewed on timelines
  final EventSubtypeGeodetic eventSubtype;

  double? displacementNorthMm;
  double? displacementEastMm;
  double? displacementVerticalMm;
  String instrumentType = ""; // e.g., GNSS, Tiltmeter, InSAR Interferogram

  EventGeodetic({
    super.id,
    required this.eventSubtype
    }) : super(eventType: EventType.geodetic_deformation);
}