part of 'event_post_model.dart';

enum EventSubtypeVolcanicE {
  ashEmission,
  lavaFlow,
  prycoclasticFlow,
  prycoclasticSurge,
  lavaFountain,
  ballisticEjection,
  tephraFall,
  phreaticEruption,
  phreatoMagneticEruption,
  other,
}

enum EventSubtypeVolcanicNE {
  longPeriod,
  veryLongPeriod,
  hybrid,
  volcanicTectonic,
  magmaIntrusion,
  dikeIntrustion,
  conduitResonance,
  lavaDomeGrowth,
  lavaDomeCollapse,
  degassingEpisode,
  fumarolicActivity,
  other,
}

class _EventVolcanic extends Event {
  String volcanoName = "";
  double? elevation;

  _EventVolcanic({super.id}) : super(eventType: EventType.unspecified_anomalous);
}

class EventVolcanicEruptive extends _EventVolcanic {
  final EventSubtypeVolcanicE eventSubtype;

  double? plumeHeightMeters;
  int? vei; // Volcanic Explosivity Index (0-8)
  List<String> hazards = []; // ["ash_fall", "lava_flow"]

  EventVolcanicEruptive({
    super.id,
    required this.eventSubtype,
    });
}

class EventVolcanicNonEruptive extends _EventVolcanic {
  final EventSubtypeVolcanicNE eventSubtype;

  double? groundDeformationMm; // Millimeters of uplift/subsidence
  double? so2Flux; // Tonnes/day of Sulfur Dioxide
  double? fumaroleTemperature; // Heat changes in vents

  EventVolcanicNonEruptive({
    super.id,
    required this.eventSubtype
    });
}
