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
