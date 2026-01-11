part of 'event_post_model.dart';

enum EventSubtypeAnthropogenic {
  quarryBlast,
  miningExplosion,
  constructionBlast,
  sonicBoom,
  nuclearTest,
  other,
}

class EventAnthropogenic extends Event {
  final EventSubtypeAnthropogenic eventSubtype;

  // Man-made events
  String activityType = ""; // e.g., Quarry Blast, Nuclear Test, Induced (Fracking), Construction
  double? explosiveYieldKg;
  bool isConfirmedIntentional = true;

  EventAnthropogenic({
    super.id,
    required this.eventSubtype,
    }) : super(eventType: EventType.anthropogenic);
}
