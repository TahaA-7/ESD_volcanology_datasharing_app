part of '../screens/event_post_wizard.dart';

abstract class FormSection {
  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> json);
  void reset();
  bool isValid();
}

// Step 1.1 - location
class LocationSection extends FormSection {
  Country? country;
  String? stateprovince;
  String? towncity;
  double? longitude;
  double? latitude;
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'country': country?.name,
      'stateprovince': stateprovince,
      'towncity': towncity,
      'longitude': longitude,
      'latitude': latitude,
    };
  }
  
  @override
  void fromJson(Map<String, dynamic> json) {
    country = Country.values.byName(json['country'] ?? 'unspecified');
    stateprovince = json['stateprovince'];
    towncity = json['towncity'];
    longitude = json['longitude'];
    latitude = json['latitude'];
  }
  
  @override
  void reset() {
    country = null;
    stateprovince = null;
    towncity = null;
    longitude = null;
    latitude = null;
  }
  
  @override
  bool isValid() {
    return (longitude != null && latitude != null) || stateprovince != null;
  }
}

// Step 1.2 - duration
// Step 1.2 - absolute time
class TimeSection extends FormSection {
  String? years; String? days; String? hours; String? minutes; String? seconds; String? microseconds;
  DateTime? startTime; DateTime? endTime;

  @override
  Map<String, dynamic> toJson() {
    return {
      'years': years,
      'days': days,
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
      'microseconds': microseconds,

      'startTime': startTime,
      'endTime': endTime,
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    years = json['years'];
    days = json['days'];
    hours = json['hours'];
    minutes = json['minutes'];
    seconds = json['seconds'];
    microseconds = json['microseconds'];

    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  void reset() {
    years = null; days = null; hours = null; minutes = null; seconds = null; microseconds = null;
    startTime = null; endTime = null;
  }

  @override
  bool isValid() {
    final timeValues = [years, days, hours, minutes, seconds, microseconds];
    bool isValid = true;

    for (var val in timeValues) {
      // If a field is not null but contains non-numeric text, it's invalid
      if (val != null && int.tryParse(val) == null) {
        isValid = false; 
        break;
      }
    }

    if (startTime != null && endTime != null) {
      if (startTime!.isAfter(endTime!)) isValid = false;
    }

    return isValid;
  }
}

// Step 3 - extra details
class ExtraDetailsSection extends FormSection {
  EventPostStatus? eventPostStatus; String? source; String? description;

  @override
  Map<String, dynamic> toJson() {
    return {
      'eventPostStatus': eventPostStatus?.name,
      'source': source,
      'description': description,
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    eventPostStatus = json['eventPostStatus'] != null 
        ? EventPostStatus.values.byName(json['eventPostStatus']) 
        : null;
    source = json['source'];
    description = json['description'];
  }

  void reset () {
    eventPostStatus = null; source = null; description = null;
  }

  bool isValid() {
    return true;
  }
}









// Step 2 - Anthropogenic event details
class AnthropogenicSection extends FormSection {
  String? activityType;
  String? explosiveYieldKg;
  String? isConfirmedIntentional;

  @override
  Map<String, dynamic> toJson() {
    return {
      'activityType': activityType,
      'explosiveYieldKg': explosiveYieldKg,
      'isConfirmedIntentional': isConfirmedIntentional,
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    activityType = json['activityType'];
    explosiveYieldKg = json['explosiveYieldKg'];
    isConfirmedIntentional = json['isConfirmedIntentional'];
  }

  @override
  void reset() {
    activityType = null;
    explosiveYieldKg = null;
    isConfirmedIntentional = null;
  }

  @override
  bool isValid() {
    if (explosiveYieldKg != null && explosiveYieldKg!.isNotEmpty) {
      return double.tryParse(explosiveYieldKg!) != null;
    }
    return true;
  }
}

// Step 2 - Atmospheric event details
class AtmosphericSection extends FormSection {
  String? phenomenon;
  String? peakOverpressurePa;
  String? altitudeKm;
  String? estimatedEnergyJoules;

  @override
  Map<String, dynamic> toJson() {
    return {
      'phenomenon': phenomenon,
      'peakOverpressurePa': peakOverpressurePa,
      'altitudeKm': altitudeKm,
      'estimatedEnergyJoules': estimatedEnergyJoules,
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    phenomenon = json['phenomenon'];
    peakOverpressurePa = json['peakOverpressurePa'];
    altitudeKm = json['altitudeKm'];
    estimatedEnergyJoules = json['estimatedEnergyJoules'];
  }

  @override
  void reset() {
    phenomenon = null;
    peakOverpressurePa = null;
    altitudeKm = null;
    estimatedEnergyJoules = null;
  }

  @override
  bool isValid() {
    final numericFields = [peakOverpressurePa, altitudeKm, estimatedEnergyJoules];
    for (var field in numericFields) {
      if (field != null && field.isNotEmpty && double.tryParse(field) == null) {
        return false;
      }
    }
    return true;
  }
}

// Step 2 - Cryoseismic event details
class CryoseismicSection extends FormSection {
  String? iceThicknessMeters;
  String? airTemperatureCelsius;
  String? glacierIceBodyName;
  String? crackLengthMeters;

  @override
  Map<String, dynamic> toJson() {
    return {
      'iceThicknessMeters': iceThicknessMeters,
      'airTemperatureCelsius': airTemperatureCelsius,
      'glacierIceBodyName': glacierIceBodyName,
      'crackLengthMeters': crackLengthMeters,
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    iceThicknessMeters = json['iceThicknessMeters'];
    airTemperatureCelsius = json['airTemperatureCelsius'];
    glacierIceBodyName = json['glacierIceBodyName'];
    crackLengthMeters = json['crackLengthMeters'];
  }

  @override
  void reset() {
    iceThicknessMeters = null;
    airTemperatureCelsius = null;
    glacierIceBodyName = null;
    crackLengthMeters = null;
  }

  @override
  bool isValid() {
    final numericFields = [iceThicknessMeters, airTemperatureCelsius, crackLengthMeters];
    for (var field in numericFields) {
      if (field != null && field.isNotEmpty && double.tryParse(field) == null) {
        return false;
      }
    }
    return true;
  }
}

// Step 2 - Geodetic event details
class GeodeticSection extends FormSection {
  String? displacementNorthMm;
  String? displacementEastMm;
  String? displacementVerticalMm;
  String? instrumentType;

  @override
  Map<String, dynamic> toJson() {
    return {
      'displacementNorthMm': displacementNorthMm,
      'displacementEastMm': displacementEastMm,
      'displacementVerticalMm': displacementVerticalMm,
      'instrumentType': instrumentType,
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    displacementNorthMm = json['displacementNorthMm'];
    displacementEastMm = json['displacementEastMm'];
    displacementVerticalMm = json['displacementVerticalMm'];
    instrumentType = json['instrumentType'];
  }

  @override
  void reset() {
    displacementNorthMm = null;
    displacementEastMm = null;
    displacementVerticalMm = null;
    instrumentType = null;
  }

  @override
  bool isValid() {
    final numericFields = [displacementNorthMm, displacementEastMm, displacementVerticalMm];
    for (var field in numericFields) {
      if (field != null && field.isNotEmpty && double.tryParse(field) == null) {
        return false;
      }
    }
    return true;
  }
}

// Step 2 - Hydrothermal event details
class HydrothermalSection extends FormSection {
  String? featureType;
  String? waterTemperatureCelsius;
  String? phLevel;
  String? dischargeRateLitersPerSec;
  String? eruptionOccurred;

  @override
  Map<String, dynamic> toJson() {
    return {
      'featureType': featureType,
      'waterTemperatureCelsius': waterTemperatureCelsius,
      'phLevel': phLevel,
      'dischargeRateLitersPerSec': dischargeRateLitersPerSec,
      'eruptionOccurred': eruptionOccurred,
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    featureType = json['featureType'];
    waterTemperatureCelsius = json['waterTemperatureCelsius'];
    phLevel = json['phLevel'];
    dischargeRateLitersPerSec = json['dischargeRateLitersPerSec'];
    eruptionOccurred = json['eruptionOccurred'];
  }

  @override
  void reset() {
    featureType = null;
    waterTemperatureCelsius = null;
    phLevel = null;
    dischargeRateLitersPerSec = null;
    eruptionOccurred = null;
  }

  @override
  bool isValid() {
    final numericFields = [waterTemperatureCelsius, phLevel, dischargeRateLitersPerSec];
    for (var field in numericFields) {
      if (field != null && field.isNotEmpty && double.tryParse(field) == null) {
        return false;
      }
    }
    return true;
  }
}

// Step 2 - Mass Movement event details
class MassMovementSection extends FormSection {
  String? volumeM3;
  String? velocityMetersPerSecond;
  String? runoutDistanceMeters;
  String? slopeAngleDegrees;
  String? trigger;
  String? secondaryHazard;

  @override
  Map<String, dynamic> toJson() {
    return {
      'volumeM3': volumeM3,
      'velocityMetersPerSecond': velocityMetersPerSecond,
      'runoutDistanceMeters': runoutDistanceMeters,
      'slopeAngleDegrees': slopeAngleDegrees,
      'trigger': trigger,
      'secondaryHazard': secondaryHazard,
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    volumeM3 = json['volumeM3'];
    velocityMetersPerSecond = json['velocityMetersPerSecond'];
    runoutDistanceMeters = json['runoutDistanceMeters'];
    slopeAngleDegrees = json['slopeAngleDegrees'];
    trigger = json['trigger'];
    secondaryHazard = json['secondaryHazard'];
  }

  @override
  void reset() {
    volumeM3 = null;
    velocityMetersPerSecond = null;
    runoutDistanceMeters = null;
    slopeAngleDegrees = null;
    trigger = null;
    secondaryHazard = null;
  }

  @override
  bool isValid() {
    final numericFields = [volumeM3, velocityMetersPerSecond, runoutDistanceMeters, slopeAngleDegrees];
    for (var field in numericFields) {
      if (field != null && field.isNotEmpty && double.tryParse(field) == null) {
        return false;
      }
    }
    return true;
  }
}

// Step 2 - Seismic event details
class SeismicSection extends FormSection {
  String? magnitude;
  String? magnitudeType;
  String? depth;
  String? depthUncertainty;
  String? focalMechanism;

  @override
  Map<String, dynamic> toJson() {
    return {
      'magnitude': magnitude,
      'magnitudeType': magnitudeType,
      'depth': depth,
      'depthUncertainty': depthUncertainty,
      'focalMechanism': focalMechanism,
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    magnitude = json['magnitude'];
    magnitudeType = json['magnitudeType'];
    depth = json['depth'];
    depthUncertainty = json['depthUncertainty'];
    focalMechanism = json['focalMechanism'];
  }

  @override
  void reset() {
    magnitude = null;
    magnitudeType = null;
    depth = null;
    depthUncertainty = null;
    focalMechanism = null;
  }

  @override
  bool isValid() {
    final numericFields = [magnitude, magnitudeType, depth, depthUncertainty];
    for (var field in numericFields) {
      if (field != null && field.isNotEmpty && double.tryParse(field) == null) {
        return false;
      }
    }
    return true;
  }
}

// Step 2 - Volcanic event details (base)
class VolcanicBaseSection extends FormSection {
  String? volcanoName;
  String? elevation;

  @override
  Map<String, dynamic> toJson() {
    return {
      'volcanoName': volcanoName,
      'elevation': elevation,
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    volcanoName = json['volcanoName'];
    elevation = json['elevation'];
  }

  @override
  void reset() {
    volcanoName = null;
    elevation = null;
  }

  @override
  bool isValid() {
    if (elevation != null && elevation!.isNotEmpty) {
      return double.tryParse(elevation!) != null;
    }
    return true;
  }
}

// Step 2 - Volcanic Eruptive event details
class VolcanicEruptiveSection extends VolcanicBaseSection {
  String? plumeHeightMeters;
  String? vei;
  List<String>? hazards;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'plumeHeightMeters': plumeHeightMeters,
      'vei': vei,
      'hazards': hazards,
    });
    return json;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    plumeHeightMeters = json['plumeHeightMeters'];
    vei = json['vei'];
    hazards = json['hazards'] != null ? List<String>.from(json['hazards']) : null;
  }

  @override
  void reset() {
    super.reset();
    plumeHeightMeters = null;
    vei = null;
    hazards = null;
  }

  @override
  bool isValid() {
    if (!super.isValid()) return false;
    
    if (plumeHeightMeters != null && plumeHeightMeters!.isNotEmpty) {
      if (double.tryParse(plumeHeightMeters!) == null) return false;
    }
    
    if (vei != null && vei!.isNotEmpty) {
      final veiInt = int.tryParse(vei!);
      if (veiInt == null || veiInt < 0 || veiInt > 8) return false;
    }
    
    return true;
  }
}

// Step 2 - Volcanic Non-Eruptive event details
class VolcanicNonEruptiveSection extends VolcanicBaseSection {
  String? groundDeformationMm;
  String? so2Flux;
  String? fumaroleTemperature;

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'groundDeformationMm': groundDeformationMm,
      'so2Flux': so2Flux,
      'fumaroleTemperature': fumaroleTemperature,
    });
    return json;
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    super.fromJson(json);
    groundDeformationMm = json['groundDeformationMm'];
    so2Flux = json['so2Flux'];
    fumaroleTemperature = json['fumaroleTemperature'];
  }

  @override
  void reset() {
    super.reset();
    groundDeformationMm = null;
    so2Flux = null;
    fumaroleTemperature = null;
  }

  @override
  bool isValid() {
    if (!super.isValid()) return false;
    
    final numericFields = [groundDeformationMm, so2Flux, fumaroleTemperature];
    for (var field in numericFields) {
      if (field != null && field.isNotEmpty && double.tryParse(field) == null) {
        return false;
      }
    }
    
    return true;
  }
}

// class MultisensorSection extends FormSection {

// }
