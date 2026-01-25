import 'package:flutter/material.dart';

import '../models/event_post_model.dart';

import '../utils_services/event_builder.dart';

class EventPostWizardController extends ChangeNotifier {
  int currentStep = 0;

  // Step 1
  EventType? eventType;
  Enum? eventSubtype;


  // Step 1.1 – location
  Country? country;
  String? stateprovince;
  String? towncity;
  double? longitude;
  double? latitude;

  // Step 1.2 – duration
  String? years;
  String? days;
  String? hours;
  String? minutes;
  String? seconds;
  String? microseconds;

  // Step 1.2 – absolute time
  DateTime? startTime;
  DateTime? endTime;

  // Step 2 - event type details
  String? activityType;
  String? explosiveYieldKg;
  String? isConfirmedIntentional;

  String? phenomenon;
  String? peakOverpressurePa;
  String? altitudeKm;
  String? estimatedEnergyJoules;

  String? iceThicknessMeters;
  String? airTemperatureCelsius;
  String? glacierIceBodyName;
  String? crackLengthMeters;

  String? displacementNorthMm;
  String? displacementEastMm;
  String? displacementVerticalMm;
  String? instrumentType;

  String? featureType;
  String? waterTemperatureCelsius;
  String? phLevel;
  String? dischargeRateLitersPerSec;
  String? eruptionOccurred;

  String? volumeM3;
  String? velocityMetersPerSecond;
  String? runoutDistanceMeters;
  String? slopeAngleDegrees;
  String? trigger;
  String? secondaryHazard;

  String? magnitude;
  String? magnitudeType;
  String? depth;
  String? depthUncertainty;
  String? focalMechanism;

  String? volcanoName;
  String? elevation;

  String? plumeHeightMeters;
  String? vei;
  String? hazards;

  String? groundDeformationMm;
  String? so2Flux;
  String? fumaroleTemperature;


  // Step 3 - extra details
  String? source;
  EventPostStatus? eventPostStatus;
  String? description;

  // Step 4 - upload
  List<String>? mediaPaths=[];

    // ---- Build Event ----

  /// Returns list of available subtypes for current event type
  List<Enum> getAvailableSubtypes() {
    if (eventType == null) return [EventSubtype.unspecified];
    return getAvailableSubtypesForType(eventType!);
  }

  Event buildEventDuration() {
    // Build base event
    if (eventType == null || eventSubtype == null) {
      throw UnsupportedError('Cannot build event: eventType or eventSubtype is null');
    }
    Event event = buildEvent(eventType!, eventSubtype!);

    // Apply location data
    event.country = country ?? Country.unspecified;
    event.stateProvince = stateprovince ?? '';
    event.townCity = towncity ?? '';
    event.longitude = longitude;
    event.latitude = latitude;

    // Parse and apply duration
    final durationYears = int.tryParse(years ?? '0') ?? 0;
    final durationDays = int.tryParse(days ?? '0') ?? 0;
    final durationHours = int.tryParse(hours ?? '0') ?? 0;
    final durationMinutes = int.tryParse(minutes ?? '0') ?? 0;
    final durationSeconds = int.tryParse(seconds ?? '0') ?? 0;
    final durationMicroseconds = int.tryParse(microseconds ?? '0') ?? 0;

    event.duration = Duration(
      days: durationYears * 365 + durationDays,
      hours: durationHours,
      minutes: durationMinutes,
      seconds: durationSeconds,
      microseconds: durationMicroseconds,
    );

    // Apply time range
    event.startTime = startTime;
    if (startTime != null && endTime != null) {
      event.timeRange = DateTimeRange(start: startTime!, end: endTime!);
    }

    return event;
  }

  // ---- Navigation ----

  void nextStep() {
    if (currentStep < 5) {
      currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }

  // ---- Validation ----

  bool get isTimeRangeValid {
    if (startTime == null || endTime == null) return true;
    return !startTime!.isAfter(endTime!);
  }

  bool get canProceed {
    switch (currentStep) {
      case 0:
        return eventType != null;
      case 2:
        return isTimeRangeValid;
      default:
        return true;
    }
  }

  bool get canBuildEvent {
    if (eventType != null){
      if (longitude != null && latitude != null) {
        return true;
      }
      if (stateprovince != null) {return true;}
    }
    return false;
  }

  // ---- Draft & Submit ----

  Event? _currentDraft;

  Event? get currentDraft => _currentDraft;

  void saveDraft() {
    if (canBuildEvent) {
      _currentDraft = buildEventDuration();
      notifyListeners();
    }
  }

  void clearDraft() {
    _currentDraft = null;
    notifyListeners();
  }

  // ---- Reset ----

  void reset() {
    currentStep = 0;
    eventType = null;
    eventSubtype = null;
    country = null;
    stateprovince = null;
    towncity = null;
    longitude = null;
    latitude = null;
    years = null;
    days = null;
    hours = null;
    minutes = null;
    seconds = null;
    microseconds = null;
    startTime = null;
    endTime = null;
    mediaPaths = null;
    _currentDraft = null;
    notifyListeners();
  }
}
