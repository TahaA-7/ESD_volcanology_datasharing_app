part of 'event_post_model.dart';

enum EventSubtypeHydrothermal {
  hydrothermalExplosion,
  boilingEvent,
  fluidMigration,
  pressurization,
  other,
}

class EventHydrothermal extends Event {
  final EventSubtypeHydrothermal eventSubtype;

  String featureType = ""; // e.g., Geyser, Hot Spring, Mud Pot
  double? waterTemperatureCelsius;
  double? phLevel;
  double? dischargeRateLitersPerSec;
  bool eruptionOccurred = false;

  EventHydrothermal({
    super.id,
    required this.eventSubtype,
    }) : super(eventType: EventType.hydrothermal_fluidDriven);
}
