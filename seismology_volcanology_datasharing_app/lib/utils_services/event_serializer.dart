part of '../screens/event_post_wizard.dart';

// Abstract serializer interface
abstract class EventSerializer<T extends Event> {
  Map<String, dynamic> serializeSpecific(T event);
  T deserialize(Map<String, dynamic> json);
}


class AnthropogenicEventSerializer extends EventSerializer<EventAnthropogenic> {
  @override
  Map<String, dynamic> serializeSpecific(EventAnthropogenic event) {
    return {
      'activityType': event.activityType,
      'explosiveYieldKg': event.explosiveYieldKg,
      'isConfirmedIntentional': event.isConfirmedIntentional,
    };
  }
  
  @override
  EventAnthropogenic deserialize(Map<String, dynamic> json) {
    return EventAnthropogenic(eventSubtype: EventSubtypeAnthropogenic.other)
      ..activityType = json['activityType']
      ..explosiveYieldKg = json['explosiveYieldKg']
      ..isConfirmedIntentional = json['isConfirmedIntentional'];
  }
}


class AtmosphericEventSerializer extends EventSerializer<EventAtmospheric> {
  @override
  Map<String, dynamic> serializeSpecific(EventAtmospheric event) {
    return {
      'phenomenon': event.phenomenon,
      'peakOverpressurePa': event.peakOverpressurePa,
      'altitudeKm': event.altitudeKm,
      'estimatedEnergyJoules': event.estimatedEnergyJoules,
    };
  }
  
  @override
  EventAtmospheric deserialize(Map<String, dynamic> json) {
    return EventAtmospheric(eventSubtype: EventSubtypeAtmospheric.other)
      ..phenomenon = json['phenomenon']
      ..peakOverpressurePa = json['peakOverpressurePa']
      ..altitudeKm = json['altitudeKm']
      ..estimatedEnergyJoules = json['estimatedEnergyJoules'];
  }
}


class CryoseismicEventSerializer extends EventSerializer<EventCryoseismic> {
  @override
  Map<String, dynamic> serializeSpecific(EventCryoseismic event) {
    return {
      'iceThicknessMeters': event.iceThicknessMeters,
      'airTemperatureCelsius': event.airTemperatureCelsius,
      'glacierIceBodyName': event.glacierIceBodyName,
      'crackLengthMeters': event.crackLengthMeters,
    };
  }
  
  @override
  EventCryoseismic deserialize(Map<String, dynamic> json) {
    return EventCryoseismic(eventSubtype: EventSubtypeCryoseismic.other)
      ..iceThicknessMeters = json['iceThicknessMeters']
      ..airTemperatureCelsius = json['airTemperatureCelsius']
      ..glacierIceBodyName = json['glacierIceBodyName']
      ..crackLengthMeters = json['crackLengthMeters'];
  }
}


class GeodeticEventSerializer extends EventSerializer<EventGeodetic> {
  @override
  Map<String, dynamic> serializeSpecific(EventGeodetic event) {
    return {
      'displacementNorthMm': event.displacementNorthMm,
      'displacementEastMm': event.displacementEastMm,
      'displacementVerticalMm': event.displacementVerticalMm,
      'instrumentType': event.instrumentType,
    };
  }
  
  @override
  EventGeodetic deserialize(Map<String, dynamic> json) {
    return EventGeodetic(eventSubtype: EventSubtypeGeodetic.other)
      ..displacementNorthMm = json['displacementNorthMm']
      ..displacementEastMm = json['displacementEastMm']
      ..displacementVerticalMm = json['displacementVerticalMm']
      ..instrumentType = json['instrumentType'];
  }
}


class HydrothermalEventSerializer extends EventSerializer<EventHydrothermal> {
  @override
  Map<String, dynamic> serializeSpecific(EventHydrothermal event) {
    return {
      'featureType': event.featureType,
      'waterTemperatureCelsius': event.waterTemperatureCelsius,
      'phLevel': event.phLevel,
      'dischargeRateLitersPerSec': event.dischargeRateLitersPerSec,
      'eruptionOccurred': event.eruptionOccurred,
    };
  }
  
  @override
  EventHydrothermal deserialize(Map<String, dynamic> json) {
    return EventHydrothermal(eventSubtype: EventSubtypeHydrothermal.other)
      ..featureType = json['featureType']
      ..waterTemperatureCelsius = json['waterTemperatureCelsius']
      ..phLevel = json['phLevel']
      ..dischargeRateLitersPerSec = json['dischargeRateLitersPerSec']
      ..eruptionOccurred = json['eruptionOccurred'];
  }
}


class MassMovementEventSerializer extends EventSerializer<EventMassMovement> {
  @override
  Map<String, dynamic> serializeSpecific(EventMassMovement event) {
    return {
      'volumeM3': event.volumeM3,
      'velocityMetersPerSecond': event.velocityMetersPerSecond,
      'runoutDistanceMeters': event.runoutDistanceMeters,
      'slopeAngleDegrees': event.slopeAngleDegrees,
      'trigger': event.trigger,
      'secondaryHazard': event.secondaryHazard,
    };
  }
  
  @override
  EventMassMovement deserialize(Map<String, dynamic> json) {
    return EventMassMovement(eventSubtype: EventSubtypeMM.other)
      ..volumeM3 = json['volumeM3']
      ..velocityMetersPerSecond = json['velocityMetersPerSecond']
      ..runoutDistanceMeters = json['runoutDistanceMeters']
      ..slopeAngleDegrees = json['slopeAngleDegrees']
      ..trigger = json['trigger']
      ..secondaryHazard = json['secondaryHazard'];
  }
}


class SeismicEventSerializer extends EventSerializer<EventSeismic> {
  @override
  Map<String, dynamic> serializeSpecific(EventSeismic event) {
    return {
      'magnitude': event.magnitude,
      'magnitudeType': event.magnitudeType,
      'depth': event.depth,
      'depthUncertainty': event.depthUncertainty,
      'focalMechanism': event.focalMechanism,
    };
  }
  
  @override
  EventSeismic deserialize(Map<String, dynamic> json) {
    return EventSeismic(eventSubtype: EventSubtypeSeismic.unspecified)
      ..magnitude = json['magnitude']
      ..magnitudeType = json['magnitudeType']
      ..depth = json['depth']
      ..depthUncertainty = json['depthUncertainty']
      ..focalMechanism = json['focalMechanism'];
  }
}


class VolcanicEruptiveEventSerializer extends EventSerializer<EventVolcanicEruptive> {
  @override
  Map<String, dynamic> serializeSpecific(EventVolcanicEruptive event) {
    return {
      'volcanoName': event.volcanoName,
      'elevation': event.elevation,
      'plumeHeightMeters': event.plumeHeightMeters,
      'vei': event.vei,
      'hazards': event.hazards,
    };
  }
  
  @override
  EventVolcanicEruptive deserialize(Map<String, dynamic> json) {
    return EventVolcanicEruptive(eventSubtype: EventSubtypeVolcanicE.other)
      ..volcanoName = json['volcanoName']
      ..elevation = json['elevation']
      ..plumeHeightMeters = json['plumeHeightMeters']
      ..vei = json['vei']
      ..hazards = json['hazards'];
  }
}


class VolcanicNonEruptiveEventSerializer extends EventSerializer<EventVolcanicNonEruptive> {
  @override
  Map<String, dynamic> serializeSpecific(EventVolcanicNonEruptive event) {
    return {
      'volcanoName': event.volcanoName,
      'elevation': event.elevation,
      'groundDeformationMm': event.groundDeformationMm,
      'so2Flux': event.so2Flux,
      'fumaroleTemperature': event.fumaroleTemperature,
    };
  }
  
  @override
  EventVolcanicNonEruptive deserialize(Map<String, dynamic> json) {
    return EventVolcanicNonEruptive(eventSubtype: EventSubtypeVolcanicNE.other)
      ..volcanoName = json['volcanoName']
      ..elevation = json['elevation']
      ..groundDeformationMm = json['groundDeformationMm']
      ..so2Flux = json['so2Flux']
      ..fumaroleTemperature = json['fumaroleTemperature'];
  }
}


// Registry to map event types to serializers
class EventSerializerRegistry {
  static final Map<EventType, EventSerializer> _serializers = {
    EventType.seismic_tectonic: SeismicEventSerializer(),
    EventType.anthropogenic: AnthropogenicEventSerializer(),
    EventType.atmospheric_coupledSignals: AtmosphericEventSerializer(),
    EventType.cryoseismic_glacial: CryoseismicEventSerializer(),
    EventType.geodetic_deformation: GeodeticEventSerializer(),
    EventType.hydrothermal_fluidDriven: HydrothermalEventSerializer(),
    EventType.massMovement_surfaceInstability: MassMovementEventSerializer(),
    EventType.volcanicEruptive_surfaceProcess: VolcanicEruptiveEventSerializer(),
    EventType.volcanicNonEruptive: VolcanicNonEruptiveEventSerializer(),
  };
  
  static EventSerializer getSerializer(EventType type) {
    final serializer = _serializers[type];
    if (serializer == null) {
      throw ArgumentError('No serializer registered for EventType: $type');
    }
    return serializer;
  }
  
  static bool hasSerializer(EventType type) {
    return _serializers.containsKey(type);
  }
}
