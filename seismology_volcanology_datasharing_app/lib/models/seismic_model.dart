import 'event_post_model.dart';

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
  double? magnitude;
  double? magnitudeType;
  double? depth;
  double? depthUncertainty;
  String focalMechanism = "";

  EventSeismic({required String id}) : super(id: id);
}
