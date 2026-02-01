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
  
  // Event type specific sections
  final AnthropogenicSection anthropogenic = AnthropogenicSection();
  final AtmosphericSection atmospheric = AtmosphericSection();
  final CryoseismicSection cryoseismic = CryoseismicSection();
  final GeodeticSection geodetic = GeodeticSection();
  final HydrothermalSection hydrothermal = HydrothermalSection();
  final MassMovementSection massMovement = MassMovementSection();
  final SeismicSection seismic = SeismicSection();
  final VolcanicEruptiveSection volcanicEruptive = VolcanicEruptiveSection();
  final VolcanicNonEruptiveSection volcanicNonEruptive = VolcanicNonEruptiveSection();
  // final MultisensorSection multisensor = MultisensorSection();
  // final FalseTestSection falseTest = FalseTestSection();

  final ExtraDetailsSection extraDetails = ExtraDetailsSection();

  int currentStep = 0;

  // Step 0
  EventType? eventType;
  Enum? eventSubtype;

  // Step 4 - upload
  List<String>? mediaPaths = [];

  // ---- Build Event ----

  /// Returns list of available subtypes for current event type
  List<Enum> getAvailableSubtypes() {
    if (eventType == null) return [EventSubtype.unspecified];
    return getAvailableSubtypesForType(eventType!);
  }

  /// Gets the active event-specific section based on current event type
  FormSection? getActiveEventSection() {
    if (eventType == null) return null;
    
    switch (eventType!) {
      case EventType.anthropogenic:
        return anthropogenic;
      case EventType.atmospheric_coupledSignals:
        return atmospheric;
      case EventType.cryoseismic_glacial:
        return cryoseismic;
      case EventType.geodetic_deformation:
        return geodetic;
      case EventType.hydrothermal_fluidDriven:
        return hydrothermal;
      case EventType.massMovement_surfaceInstability:
        return massMovement;
      case EventType.seismic_tectonic:
        return seismic;
      case EventType.volcanicEruptive_surfaceProcess:
        return volcanicEruptive;
      case EventType.volcanicNonEruptive:
        return volcanicNonEruptive;
      default:
        return null;
    }
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

    // Apply event-specific details
    _applyEventSpecificDetails(event);

    // Apply extra details
    event.source = extraDetails.source ?? '';
    event.status = extraDetails.eventPostStatus ?? EventPostStatus.unspecified;
    event.description = extraDetails.description ?? '';

    return event;
  }

  void _applyEventSpecificDetails(Event event) {
    switch (eventType!) {
      case EventType.anthropogenic:
        final e = event as EventAnthropogenic;
        e.activityType = anthropogenic.activityType ?? '';
        e.explosiveYieldKg = double.tryParse(anthropogenic.explosiveYieldKg ?? '');
        e.isConfirmedIntentional = anthropogenic.isConfirmedIntentional?.toLowerCase() == 'true';
        break;

      case EventType.atmospheric_coupledSignals:
        final e = event as EventAtmospheric;
        e.phenomenon = atmospheric.phenomenon ?? '';
        e.peakOverpressurePa = double.tryParse(atmospheric.peakOverpressurePa ?? '');
        e.altitudeKm = double.tryParse(atmospheric.altitudeKm ?? '');
        e.estimatedEnergyJoules = double.tryParse(atmospheric.estimatedEnergyJoules ?? '');
        break;

      case EventType.cryoseismic_glacial:
        final e = event as EventCryoseismic;
        e.iceThicknessMeters = double.tryParse(cryoseismic.iceThicknessMeters ?? '');
        e.airTemperatureCelsius = double.tryParse(cryoseismic.airTemperatureCelsius ?? '');
        e.glacierIceBodyName = cryoseismic.glacierIceBodyName ?? '';
        e.crackLengthMeters = double.tryParse(cryoseismic.crackLengthMeters ?? '');
        break;

      case EventType.geodetic_deformation:
        final e = event as EventGeodetic;
        e.displacementNorthMm = double.tryParse(geodetic.displacementNorthMm ?? '');
        e.displacementEastMm = double.tryParse(geodetic.displacementEastMm ?? '');
        e.displacementVerticalMm = double.tryParse(geodetic.displacementVerticalMm ?? '');
        e.instrumentType = geodetic.instrumentType ?? '';
        break;

      case EventType.hydrothermal_fluidDriven:
        final e = event as EventHydrothermal;
        e.featureType = hydrothermal.featureType ?? '';
        e.waterTemperatureCelsius = double.tryParse(hydrothermal.waterTemperatureCelsius ?? '');
        e.phLevel = double.tryParse(hydrothermal.phLevel ?? '');
        e.dischargeRateLitersPerSec = double.tryParse(hydrothermal.dischargeRateLitersPerSec ?? '');
        e.eruptionOccurred = hydrothermal.eruptionOccurred?.toLowerCase() == 'true';
        break;

      case EventType.massMovement_surfaceInstability:
        final e = event as EventMassMovement;
        e.volumeM3 = double.tryParse(massMovement.volumeM3 ?? '');
        e.velocityMetersPerSecond = double.tryParse(massMovement.velocityMetersPerSecond ?? '');
        e.runoutDistanceMeters = double.tryParse(massMovement.runoutDistanceMeters ?? '');
        e.slopeAngleDegrees = double.tryParse(massMovement.slopeAngleDegrees ?? '');
        e.trigger = massMovement.trigger ?? '';
        e.secondaryHazard = massMovement.secondaryHazard?.toLowerCase() == 'true';
        break;

      case EventType.seismic_tectonic:
        final e = event as EventSeismic;
        e.magnitude = double.tryParse(seismic.magnitude ?? '');
        e.magnitudeType = seismic.magnitudeType ?? '';
        e.depth = double.tryParse(seismic.depth ?? '');
        e.depthUncertainty = double.tryParse(seismic.depthUncertainty ?? '');
        e.focalMechanism = seismic.focalMechanism ?? '';
        break;

      case EventType.volcanicEruptive_surfaceProcess:
        final e = event as EventVolcanicEruptive;
        e.volcanoName = volcanicEruptive.volcanoName ?? '';
        e.elevation = double.tryParse(volcanicEruptive.elevation ?? '');
        e.plumeHeightMeters = double.tryParse(volcanicEruptive.plumeHeightMeters ?? '');
        e.vei = int.tryParse(volcanicEruptive.vei ?? '');
        e.hazards = volcanicEruptive.hazards ?? [];
        break;

      case EventType.volcanicNonEruptive:
        final e = event as EventVolcanicNonEruptive;
        e.volcanoName = volcanicNonEruptive.volcanoName ?? '';
        e.elevation = double.tryParse(volcanicNonEruptive.elevation ?? '');
        e.groundDeformationMm = double.tryParse(volcanicNonEruptive.groundDeformationMm ?? '');
        e.so2Flux = double.tryParse(volcanicNonEruptive.so2Flux ?? '');
        e.fumaroleTemperature = double.tryParse(volcanicNonEruptive.fumaroleTemperature ?? '');
        break;

      default:
        break;
    }
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
    if (eventType != null) {
      if (location.longitude != null && location.latitude != null) {
        return true;
      }
      if (location.stateprovince != null) {
        return true;
      }
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
    extraDetails.reset();
    
    anthropogenic.reset();
    atmospheric.reset();
    cryoseismic.reset();
    geodetic.reset();
    hydrothermal.reset();
    massMovement.reset();
    seismic.reset();
    volcanicEruptive.reset();
    volcanicNonEruptive.reset();
    
    mediaPaths = [];
    _currentDraft = null;
    
    notifyListeners();
  }

  // ---- Serialization ----

  Map<String, dynamic> toJson() {
    return {
      'currentStep': currentStep,
      'eventType': eventType?.name,
      'eventSubtype': eventSubtype?.toString().split('.').last,
      'location': location.toJson(),
      'durationTime': durationTime.toJson(),
      'extraDetails': extraDetails.toJson(),
      'anthropogenic': anthropogenic.toJson(),
      'atmospheric': atmospheric.toJson(),
      'cryoseismic': cryoseismic.toJson(),
      'geodetic': geodetic.toJson(),
      'hydrothermal': hydrothermal.toJson(),
      'massMovement': massMovement.toJson(),
      'seismic': seismic.toJson(),
      'volcanicEruptive': volcanicEruptive.toJson(),
      'volcanicNonEruptive': volcanicNonEruptive.toJson(),
      'mediaPaths': mediaPaths,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    currentStep = json['currentStep'] ?? 0;
    
    if (json['eventType'] != null) {
      eventType = EventType.values.byName(json['eventType']);
    }

    if (json['eventSubtype'] != null && eventType != null) {
      final subtypes = getAvailableSubtypesForType(eventType!);
      final subtypeStr = json['eventSubtype'] as String;
      eventSubtype = subtypes.firstWhere(
        (s) => s.toString().split('.').last == subtypeStr,
        orElse: () => subtypes.first,
      );
    }
    
    location.fromJson(json['location'] ?? {});
    durationTime.fromJson(json['durationTime'] ?? {});
    extraDetails.fromJson(json['extraDetails'] ?? {});
    
    anthropogenic.fromJson(json['anthropogenic'] ?? {});
    atmospheric.fromJson(json['atmospheric'] ?? {});
    cryoseismic.fromJson(json['cryoseismic'] ?? {});
    geodetic.fromJson(json['geodetic'] ?? {});
    hydrothermal.fromJson(json['hydrothermal'] ?? {});
    massMovement.fromJson(json['massMovement'] ?? {});
    seismic.fromJson(json['seismic'] ?? {});
    volcanicEruptive.fromJson(json['volcanicEruptive'] ?? {});
    volcanicNonEruptive.fromJson(json['volcanicNonEruptive'] ?? {});
    // multisensor.fromJson(json['multisensor'] ?? {});
    // falseTest.fromJson(json['falseTest'] ?? {});
    
    mediaPaths = json['mediaPaths'] != null 
        ? List<String>.from(json['mediaPaths']) 
        : [];
    
    notifyListeners();
  }
}
