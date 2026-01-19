part of 'event_post_model.dart';

enum EventSubtypeSeismic {
  unspecified,
  aftershock,
  foreshock,
  slowSlip,
  creep,
  inducedSeismicity,
  tectonicTremor,
  microseismic,
  seismicSwarm,
  faultRupture,
  other,
}

class EventSeismic extends Event {
  final EventSubtypeSeismic eventSubtype;

  double? magnitude;
  double? magnitudeType;
  double? depth;
  double? depthUncertainty;
  String focalMechanism = "";

  EventSeismic({
    super.id,
    required this.eventSubtype,
   }) : super(eventType: EventType.seismic_tectonic);


  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'eventSubtype': eventSubtype.name,
      'magnitude': magnitude,
      'magnitudeType': magnitudeType,
      'depth': depth,
      'depthUncertainty': depthUncertainty,
      'focalMechanism': focalMechanism,
    });
    return json;
  }
}
