import 'event_post_model.dart';

enum EventSubtypeAnthropogenic {
  quarryBlast,
  miningExplosion,
  constructionBlast,
  sonicBoom,
  nuclearTest,
  other,
}

enum EventSubtypeAtmospheric {
  ifrasound,
  shockwave,
  lightning,
  ashCloudDetection,
  other,
}

class EventAtmospheric extends Event {
  // Focus on events that mimic or trigger seismic signals
  String phenomenon = ""; // e.g., Bolide/Meteor, Sonic Boom, Lightning, Tornado
  double? peakOverpressurePa; // Pascals (Infrasound data)
  double? altitudeKm;
  double? estimatedEnergyJoules;

  EventAtmospheric({required super.id});
}
