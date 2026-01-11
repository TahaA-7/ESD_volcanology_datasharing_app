import 'event_post_model.dart';

enum EventSubtypeCryoseismic {
  glacierCalving,
  glacialTremor,
  icefall,
  subglacialFlood,
  other,
}

class EventCryoseismic extends Event {
  // "Icequakes" or frost quakes
  double? iceThicknessMeters;
  double? airTemperatureCelsius;
  String glacierIceBodyName = "";
  double? crackLengthMeters;

  EventCryoseismic({required super.id});
}
