import 'package:flutter/material.dart';
import '../models/event_post_model.dart';

class EventColorHelper {
  static Color getColorForEventType(EventType type) {
    switch (type) {
      case EventType.seismic_tectonic:
        return Colors.deepOrange;
      case EventType.volcanicEruptive_surfaceProcess:
        return Colors.red;
      case EventType.volcanicNonEruptive:
        return Colors.redAccent;
      case EventType.massMovement_surfaceInstability:
        return Colors.brown;
      case EventType.cryoseismic_glacial:
        return Colors.lightBlue;
      case EventType.hydrothermal_fluidDriven:
        return Colors.teal;
      case EventType.atmospheric_coupledSignals:
        return Colors.indigo;
      case EventType.anthropogenic:
        return Colors.purple;
      case EventType.geodetic_deformation:
        return Colors.green;
      case EventType.multiSensor:
        return Colors.cyan;
      case EventType.unspecified_anomalous:
        return Colors.yellow;
      case EventType.false_test:
        return Colors.grey;
    }
  }
}