import 'event_post_model.dart';

enum EventSubtypeHydrothermal {
  hydrothermalExplosion,
  boilingEvent,
  fluidMigration,
  pressurization,
  other,
}

class EventHydrothermal extends Event {
  String featureType = ""; // e.g., Geyser, Hot Spring, Mud Pot
  double? waterTemperatureCelsius;
  double? phLevel;
  double? dischargeRateLitersPerSec;
  bool eruptionOccurred = false;

  EventHydrothermal({required super.id});
}
