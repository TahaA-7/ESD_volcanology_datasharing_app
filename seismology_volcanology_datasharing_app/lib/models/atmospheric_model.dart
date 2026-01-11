part of 'event_post_model.dart';

enum EventSubtypeAtmospheric {
  ifrasound,
  shockwave,
  lightning,
  ashCloudDetection,
  other,
}

class EventAtmospheric extends Event {
  // Focus on events that mimic or trigger seismic signals
  final EventSubtypeAtmospheric eventSubtype;

  String phenomenon = ""; // e.g., Bolide/Meteor, Sonic Boom, Lightning, Tornado
  double? peakOverpressurePa; // Pascals (Infrasound data)
  double? altitudeKm;
  double? estimatedEnergyJoules;

  EventAtmospheric({
    super.id,
    required this.eventSubtype,
    }) : super(eventType: EventType.atmospheric_coupledSignals);
}
