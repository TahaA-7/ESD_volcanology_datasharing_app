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
    if (controller.durationTime.isValid() == IsValidFormInput.valid) return true;
    return false;
  }
  
  @override
  String? getErrorMessage(EventPostWizardController controller) {
    return 'Please provide either coordinates or state/province';
  }
}

class TimeRangeValidator extends StepValidator {
  @override
  bool validate(EventPostWizardController controller) {
    if (controller.durationTime.isValid() == IsValidFormInput.valid) return true;
    return false;
  }

  @override
  String? getErrorMessage(EventPostWizardController controller) {
    switch (controller.durationTime.isValid()) {
      case IsValidFormInput.valid:
        return null;
      case IsValidFormInput.invalid_integer:
        return 'Duration fields must be numerical and cannot include alphabetical characters';
      case IsValidFormInput.starttime_after_endtime:
        return 'Start time must precede end time';
      case IsValidFormInput.timerange_duration_mismatch:
        return 'Duration does not match the time range between start and end times';
      case IsValidFormInput.unallowed_time_nullables:
        return 'Submit a start date-time and/or end date-time';
      default:
        return 'Invalid time range';
    }
  }
}

class EventTypeDetailsValidator extends StepValidator {
  @override
  bool validate(EventPostWizardController controller) {
    final activeSection = controller.getActiveEventSection();
    if (activeSection == null) return true;
    return activeSection.isValid() == IsValidFormInput.valid;
  }

  @override
  String? getErrorMessage(EventPostWizardController controller) {
    final activeSection = controller.getActiveEventSection();
    if (activeSection == null) return null;
    
    final validationResult = activeSection.isValid();
    
    switch (validationResult) {
      case IsValidFormInput.valid:
        return null;
      case IsValidFormInput.invalid_double:
        return 'Numeric fields must contain valid decimal numbers';
      case IsValidFormInput.invalid_integer:
        return 'Integer fields must contain valid whole numbers';
      case IsValidFormInput.volanic_invalid_vei:
        return 'VEI must be an integer between 0 and 8';
      default:
        return 'Please ensure all fields are filled in correctly';
    }
  }
}

class ExtraDetailsValidator extends StepValidator {
  @override
  bool validate(EventPostWizardController controller) {return true;}
  @override
  // for now this method is completely useless and will never be called, but that could perhaps change in the future
  String? getErrorMessage(EventPostWizardController controller) {
    return 'Be sure to enter details in their right format (e.g. a number cannot have alphabetical characters)';
  }
}

class UploadValidator extends StepValidator {
  @override
  bool validate(EventPostWizardController controller) {return true;}
  @override
  // also a useless method for now as there are no extra steps (uploading media = not implemented)
  String? getErrorMessage(EventPostWizardController controller) {
    return '';
  }
}
