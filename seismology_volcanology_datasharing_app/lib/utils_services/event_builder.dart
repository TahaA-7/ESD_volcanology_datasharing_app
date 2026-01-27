part of '../screens/event_post_wizard.dart';

// EventType? selectedType;
// Enum? selectedSubtype;

List<Enum> getAvailableSubtypesForType(EventType type) {
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
      return [EventSubtype.unspecified];
      // return EventSubtype.values;
  }
}


Event buildEvent(EventType eventType, Enum eventSubtype) {
  switch (eventType) {
    case EventType.anthropogenic:
      return EventAnthropogenic(
        eventSubtype: eventSubtype as EventSubtypeAnthropogenic,
      );
    case EventType.atmospheric_coupledSignals:
      return EventAtmospheric(
        eventSubtype: eventSubtype as EventSubtypeAtmospheric,
      );
    case EventType.cryoseismic_glacial:
      return EventCryoseismic(
        eventSubtype: eventSubtype as EventSubtypeCryoseismic,
      );
    case EventType.geodetic_deformation:
      return EventGeodetic(
        eventSubtype: eventSubtype as EventSubtypeGeodetic,
      );
    case EventType.hydrothermal_fluidDriven:
      return EventHydrothermal(
        eventSubtype: eventSubtype as EventSubtypeHydrothermal,
      );
    case EventType.massMovement_surfaceInstability:
      return EventMassMovement(
        eventSubtype: eventSubtype as EventSubtypeMM,
      );
    case EventType.seismic_tectonic:
      return EventSeismic(
        eventSubtype: eventSubtype as EventSubtypeSeismic,
      );
    case EventType.volcanicEruptive_surfaceProcess:
      return EventVolcanicEruptive(
        eventSubtype: eventSubtype as EventSubtypeVolcanicE,
      );
    case EventType.volcanicNonEruptive:
      return EventVolcanicNonEruptive(
        eventSubtype: eventSubtype as EventSubtypeVolcanicNE,
      );
    default:
      throw UnsupportedError('Unknown event type: $eventType');
  }
}
