part of '../screens/event_post_wizard.dart';

abstract class StepValidator {
  bool validate(EventPostWizardController controller);
  String? getErrorMessage(EventPostWizardController controller);

  bool _isValidDouble(String? s) {
    double? doubleVal = double.tryParse(s ?? '');
    if (doubleVal != null && doubleVal < 0) {
      return false;
    }
    return true;
  }

  bool _isValidInt(String? s) {
    int? intVal = int.tryParse(s ?? '');
    if (intVal != null && intVal < 0) {
      return false;
    }
    return true;
  }

  bool _isValidBool(String? s) {
    final validInputs = {'yes', 'true', 'no', 'false', '', 'unspecified'};
    if (!validInputs.contains(s?.toLowerCase() ?? '')) {
      return false;
    }
    return true;
  }
}

class BasicDetailsValidator extends StepValidator {
  @override
  bool validate(EventPostWizardController controller) {
    return controller.eventType != null && controller.eventSubtype != null;
  }
  
  @override
  String? getErrorMessage(EventPostWizardController controller) {
    if (controller.eventType == null) return 'Please select an event type';
    if (controller.eventSubtype == null) return 'Please select an event subtype';
    return null;
  }
}

class LocationValidator extends StepValidator {
  @override
  bool validate(EventPostWizardController controller) {
    return controller.location.isValid(); 
  }
  
  @override
  String? getErrorMessage(EventPostWizardController controller) {
    return 'Please provide either coordinates or state/province';
  }
}

class TimeRangeValidator extends StepValidator {
  @override
  bool validate(EventPostWizardController controller) {
    // if (controller.startTime == null || controller.endTime == null) return true;
    // return !controller.startTime!.isAfter(controller.endTime!);
    return controller.durationTime.isValid();
  }

  @override
  String? getErrorMessage(EventPostWizardController controller) {
    return 'Start time must precede end time';
  }
}

class EventTypeDetailsValidator extends StepValidator {  // extend
  @override
  bool validate(EventPostWizardController controller){
    switch (controller.eventType) {
      case EventType.anthropogenic:
        if (_isValidDouble(controller.explosiveYieldKg) == false) return false;
        if (_isValidBool(controller.isConfirmedIntentional) == false) return false;
        return true;
      case EventType.atmospheric_coupledSignals:
        if (_isValidDouble(controller.peakOverpressurePa) == false) return false;
        if (_isValidDouble(controller.altitudeKm) == false) return false;
        if (_isValidDouble(controller.estimatedEnergyJoules) == false) return false;
        return true;
      case EventType.cryoseismic_glacial:
        if (_isValidDouble(controller.iceThicknessMeters) == false) return false;
        if (_isValidDouble(controller.airTemperatureCelsius) == false) return false;
        if (_isValidDouble(controller.crackLengthMeters) == false) return false;
        return true;
      case EventType.geodetic_deformation:
        if (_isValidDouble(controller.displacementNorthMm) == false) return false;
        if (_isValidDouble(controller.displacementEastMm) == false) return false;
        if (_isValidDouble(controller.displacementVerticalMm) == false) return false;
        return true;
      case EventType.hydrothermal_fluidDriven:
        if (_isValidDouble(controller.waterTemperatureCelsius) == false) return false;
        if (_isValidDouble(controller.phLevel) == false) return false;
        if (_isValidDouble(controller.dischargeRateLitersPerSec) == false) return false;
        if (_isValidBool(controller.eruptionOccurred) == false) return false;
        return true;
      case EventType.massMovement_surfaceInstability:
        if (_isValidDouble(controller.volcanoName) == false) return false;
        if (_isValidDouble(controller.velocityMetersPerSecond) == false) return false;
        if (_isValidDouble(controller.runoutDistanceMeters) == false) return false;
        if (_isValidDouble(controller.slopeAngleDegrees) == false) return false;
        if (_isValidBool(controller.secondaryHazard) == false) return false;
        return true;
      case EventType.seismic_tectonic:
        if (_isValidDouble(controller.magnitude) == false) return false;
        if (_isValidDouble(controller.magnitudeType) == false) return false;
        if (_isValidDouble(controller.depth) == false) return false;
        if (_isValidDouble(controller.depthUncertainty) == false) return false;
        return true;
      case EventType.volcanicEruptive_surfaceProcess:
        if (_isValidDouble(controller.elevation) == false) return false;

        if (_isValidDouble(controller.plumeHeightMeters) == false) return false;
        if (_isValidInt(controller.vei) == false) return false;
        return true;
      case EventType.volcanicNonEruptive:
        if (_isValidDouble(controller.elevation) == false) return false;

        if (_isValidDouble(controller.groundDeformationMm) == false) return false;
        if (_isValidDouble(controller.so2Flux) == false) return false;
        if (_isValidDouble(controller.fumaroleTemperature) == false) return false;
        return true;
      case _:
        return true;
    }
    return true;
  }
  @override
  String? getErrorMessage(EventPostWizardController controller) {
    return 'Be sure to enter details in their right format (e.g. a number cannot have alphabetical characters)';
  }
}

class ExtraDetailsValidator extends StepValidator {
  @override
  bool validate(EventPostWizardController controller) {return true;}
  @override
  String? getErrorMessage(EventPostWizardController controller) {
    return 'Be sure to enter details in their right format (e.g. a number cannot have alphabetical characters)';
  }
}

class UploadValidator extends StepValidator {
  @override
  bool validate(EventPostWizardController controller) {return true;}
  @override
  String? getErrorMessage(EventPostWizardController controller) {
    return '';
  }
}
