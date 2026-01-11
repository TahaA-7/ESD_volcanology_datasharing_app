part of 'event_post_model.dart';

enum EventSubtypeCryoseismic {
  glacierCalving,
  glacialTremor,
  icefall,
  subglacialFlood,
  other,
}

class EventCryoseismic extends Event {
  // "Icequakes" or frost quakes
  final EventSubtypeCryoseismic eventSubtype;

  double? iceThicknessMeters;
  double? airTemperatureCelsius;
  String glacierIceBodyName = "";
  double? crackLengthMeters;

  EventCryoseismic({
    super.id, 
    required this.eventSubtype,
    }) : super(eventType: EventType.cryoseismic_glacial);
  // EventCryoseismic({required super.id});
}

  // EventCryoseismic({
  //   String? id, 
  //   required this.eventSubtype,
  //   }) : super(id: id, eventType: EventType.cryoseismic_glacial);
  // // EventCryoseismic({required super.id});
