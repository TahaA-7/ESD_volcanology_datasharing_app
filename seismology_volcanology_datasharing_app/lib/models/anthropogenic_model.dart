import 'event_post_model.dart';

class EventAnthropogenic extends Event {
  // Man-made events
  String activityType = ""; // e.g., Quarry Blast, Nuclear Test, Induced (Fracking), Construction
  double? explosiveYieldKg;
  bool isConfirmedIntentional = true;

  EventAnthropogenic({required super.id});
}
