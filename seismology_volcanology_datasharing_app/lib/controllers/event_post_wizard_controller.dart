part of '../screens/event_post_wizard.dart';

class EventPostWizardController extends ChangeNotifier {
  final List<StepValidator> _stepValidators = [
    BasicDetailsValidator(),      // Step 0
    LocationValidator(),           // Step 1
    TimeRangeValidator(),         // Step 2
    EventTypeDetailsValidator(),  // Step 3
    ExtraDetailsValidator(),      // Step 4
    UploadValidator(),            // Step 5
  ];

  final LocationSection location = LocationSection();
  final TimeSection durationTime = TimeSection();

  int currentStep = 0;

  // Step 1
  EventType? eventType;
  Enum? eventSubtype;


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
    event.country = location.country ?? Country.unspecified;
    event.stateProvince = location.stateprovince ?? '';
    event.townCity = location.towncity ?? '';
    event.longitude = location.longitude;
    event.latitude = location.latitude;

    // Parse and apply duration
    final durationYears = int.tryParse(durationTime.years ?? '0') ?? 0;
    final durationDays = int.tryParse(durationTime.days ?? '0') ?? 0;
    final durationHours = int.tryParse(durationTime.hours ?? '0') ?? 0;
    final durationMinutes = int.tryParse(durationTime.minutes ?? '0') ?? 0;
    final durationSeconds = int.tryParse(durationTime.seconds ?? '0') ?? 0;
    final durationMicroseconds = int.tryParse(durationTime.microseconds ?? '0') ?? 0;

    event.duration = Duration(
      days: durationYears * 365 + durationDays,
      hours: durationHours,
      minutes: durationMinutes,
      seconds: durationSeconds,
      microseconds: durationMicroseconds,
    );

    // Apply time range
    event.startTime = durationTime.startTime;
    if (durationTime.startTime != null && durationTime.endTime != null) {
      event.timeRange = DateTimeRange(start: durationTime.startTime!, end: durationTime.endTime!);
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

  bool get canProceed {
    return _stepValidators[currentStep].validate(this);
  }

  String? get currentStepError {
    return _stepValidators[currentStep].getErrorMessage(this);
  }

  bool get canBuildEvent {
    if (eventType != null){
      if (location.longitude != null && location.latitude != null) {
        return true;
      }
      if (location.stateprovince != null) {return true;}
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
    location.reset();
    durationTime.reset();
    mediaPaths = null;
    _currentDraft = null;
    notifyListeners();
  }
}
