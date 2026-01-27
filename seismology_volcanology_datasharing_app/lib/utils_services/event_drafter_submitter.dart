import '../models/event_post_model.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';



class EventSubmissionService {
  Future<void> submit(Event event, {bool draft=false}) async {
    try {
      final Map<String, dynamic> eventJson = _toJson(event, draft: draft);
      // final File file = File('../events.json');
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/events.json');
      print('File saved in: ${directory.path}');

      // Load existing events, if none create new dataset
      List<dynamic> currentEvents = [];
      if (await file.exists()) {
        final String content = await file.readAsString();
        if (content.isNotEmpty) {
          currentEvents = jsonDecode(content);
        }
      }

      // Add and save
      currentEvents.add(eventJson);
      await file.writeAsString(jsonEncode(currentEvents), mode: FileMode.write);
      
    } catch (e) {
      throw Exception("Error saving event: $e");
    }
  }

   Map<String, dynamic> _toJson(Event event, {bool draft=false}) {
    final Map<String, dynamic> baseData = {
      'id': event.id,
      'eventType': event.eventType.name,
      'country': event.country.name,
      'stateProvince': event.stateProvince,
      'townCity': event.townCity,
      'longitude': event.longitude,
      'latitude': event.latitude,
      // 'duration': event.duration,
      'duration_ms': event.duration.inMilliseconds,
      'startTime': event.startTime?.toIso8601String(),
      'timeRange': event.timeRange != null
          ? {
              'start': event.timeRange!.start.toIso8601String(),
              'end': event.timeRange!.end.toIso8601String(),
            }
          : null,

      'draftBool': draft,
    };

    final Map<String, dynamic> specificData = switch (event) {
      EventAnthropogenic e => {'activityType': e.activityType, 'explosiveYieldKg': e.explosiveYieldKg, 'isConfirmedIntentional': e.isConfirmedIntentional,},
      EventAtmospheric e => {'phenomenon': e.phenomenon, 'peakOverPressurePa': e.peakOverpressurePa,
        'altitudeKm': e.altitudeKm, 'estimatedEnergyJoules': e.estimatedEnergyJoules,},
      EventCryoseismic e => {'iceThicknessMeters': e.iceThicknessMeters, 'airTemperatureCelsius': e.airTemperatureCelsius,
        'glacierIceBodyName': e.glacierIceBodyName, 'crackLengthMeters': e.crackLengthMeters,},
      EventGeodetic e => {'displacementNorthMm': e.displacementNorthMm, 'displacementEastMm': e.displacementEastMm,
        'displacementVerticalMm': e.displacementVerticalMm, 'instrumentType': e.instrumentType,},
      EventHydrothermal e => {'featureType': e.featureType, 'waterTemperatureCelsius': e.waterTemperatureCelsius, 'phLevel': e.phLevel,
        'dischargeRateLitersPerSec': e.dischargeRateLitersPerSec, 'eruptionOccured': e.eruptionOccurred,},
      EventMassMovement e => {'volumeM3': e.volumeM3, 'velocityMetersPerSecond': e.velocityMetersPerSecond,
        'runoutDistanceMeters': e.runoutDistanceMeters, 'slopeAngleDegrees': e.slopeAngleDegrees, 'trigger': e.trigger, 
        'secondaryHazard': e.secondaryHazard,},
      EventSeismic e => {'magnitude': e.magnitude, 'magnitudeType': e.magnitudeType, 'depth': e.depth,
        'depthUncertainty': e.depthUncertainty, 'focalMechanism': e.focalMechanism},
      EventVolcanicEruptive e => {
        'volcanoName': e.volcanoName,
        'elevation': e.elevation,
        'eventSubtype': e.eventSubtype.name,
        'plumeHeightMeters': e.plumeHeightMeters,
        'vei': e.vei,
        'hazards': e.hazards,
      },
      EventVolcanicNonEruptive e => {
        'volcanoName': e.volcanoName,
        'elevation': e.elevation,
        'eventSubtype': e.eventSubtype.name,
        'groundDeformationMm': e.groundDeformationMm,
        'so2Flux': e.so2Flux,
        'fumaroleTemperature': e.fumaroleTemperature,
      },
      // otherwise it won't compile because of _EventVolcanic...
      _ => {}
    };

    return {...baseData, ...specificData};
   }
}
