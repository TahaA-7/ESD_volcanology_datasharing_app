import '../models/event_post_model.dart';

EventType? selectedType;
Enum? selectedSubtype;

List<Enum> getAvailableSubtypes(EventType type) {
  switch (type) {
    case EventType.anthropogenic:
      return EventSubtypeAnthropogenic.values;
    case EventType.atmospheric_coupledSignals:
      return EventSubtypeAtmospheric.values;
    case EventType.cryoseismic_glacial:
      return EventSubtypeCryoseismic.values;
    case EventType.geodetic_deformation:
      return EventSubtypeGeodetic.values;
    case EventType.hydrothermal_fluidDriven:
      return EventSubtypeHydrothermal.values;
    case EventType.massMovement_surfaceInstability:
      return EventSubtypeMM.values;
    case EventType.seismic_tectonic:
      return EventSubtypeSeismic.values;
    case EventType.volcanicEruptive_surfaceProcess:
      return EventSubtypeVolcanicE.values;
    case EventType.volcanicNonEruptive:
      return EventSubtypeVolcanicNE.values;
    default:
      return EventSubtype.values;
  }
}


Event buildEvent() {
  switch (selectedType) {
    case EventType.anthropogenic:
      return EventAnthropogenic(
        eventSubtype: selectedSubtype as EventSubtypeAnthropogenic,
      );
    case EventType.atmospheric_coupledSignals:
      return EventAtmospheric(
        eventSubtype: selectedSubtype as EventSubtypeAtmospheric,
      );
    case EventType.cryoseismic_glacial:
      return EventCryoseismic(
        eventSubtype: selectedSubtype as EventSubtypeCryoseismic,
      );
    case EventType.geodetic_deformation:
      return EventGeodetic(
        eventSubtype: selectedSubtype as EventSubtypeGeodetic,
      );
    case EventType.hydrothermal_fluidDriven:
      return EventHydrothermal(
        eventSubtype: selectedSubtype as EventSubtypeHydrothermal,
      );
    case EventType.massMovement_surfaceInstability:
      return EventMassMovement(
        eventSubtype: selectedSubtype as EventSubtypeMM,
      );
    case EventType.seismic_tectonic:
      return EventSeismic(
        eventSubtype: selectedSubtype as EventSubtypeSeismic,
      );
    case EventType.volcanicEruptive_surfaceProcess:
      return EventVolcanicEruptive(
        eventSubtype: selectedSubtype as EventSubtypeVolcanicE,
      );
    case EventType.volcanicNonEruptive:
      return EventVolcanicNonEruptive(
        eventSubtype: selectedSubtype as EventSubtypeVolcanicNE,
      );
    default:
      throw UnsupportedError('Unknown event type');
  }
}
