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
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeAnthropogenic.values.byName(subtypeStr)
        : EventSubtypeAnthropogenic.other;

    final event = EventAnthropogenic(eventSubtype: subtype)
      ..activityType = json['activityType']
      ..explosiveYieldKg = json['explosiveYieldKg']
      ..isConfirmedIntentional = json['isConfirmedIntentional'];

    _populateExtraFields(event, json);

    return event;
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
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeAtmospheric.values.byName(subtypeStr)
        : EventSubtypeAtmospheric.other;

    final event = EventAtmospheric(eventSubtype: subtype)
      ..phenomenon = json['phenomenon']
      ..peakOverpressurePa = json['peakOverpressurePa']
      ..altitudeKm = json['altitudeKm']
      ..estimatedEnergyJoules = json['estimatedEnergyJoules'];

    _populateExtraFields(event, json);

    return event;
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
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeCryoseismic.values.byName(subtypeStr)
        : EventSubtypeCryoseismic.other;

    final event = EventCryoseismic(eventSubtype: subtype)
      ..iceThicknessMeters = json['iceThicknessMeters']
      ..airTemperatureCelsius = json['airTemperatureCelsius']
      ..glacierIceBodyName = json['glacierIceBodyName']
      ..crackLengthMeters = json['crackLengthMeters'];

    _populateExtraFields(event, json);

    return event;
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
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeGeodetic.values.byName(subtypeStr)
        : EventSubtypeGeodetic.other;

    final event = EventGeodetic(eventSubtype: subtype)
      ..displacementNorthMm = json['displacementNorthMm']
      ..displacementEastMm = json['displacementEastMm']
      ..displacementVerticalMm = json['displacementVerticalMm']
      ..instrumentType = json['instrumentType'];

    _populateExtraFields(event, json);

    return event;
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
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeHydrothermal.values.byName(subtypeStr)
        : EventSubtypeHydrothermal.other;

    final event =  EventHydrothermal(eventSubtype: subtype)
      ..featureType = json['featureType']
      ..waterTemperatureCelsius = json['waterTemperatureCelsius']
      ..phLevel = json['phLevel']
      ..dischargeRateLitersPerSec = json['dischargeRateLitersPerSec']
      ..eruptionOccurred = json['eruptionOccurred'];

    _populateExtraFields(event, json);

    return event;
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
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeMM.values.byName(subtypeStr)
        : EventSubtypeMM.other;

    final event = EventMassMovement(eventSubtype: subtype)
      ..volumeM3 = json['volumeM3']
      ..velocityMetersPerSecond = json['velocityMetersPerSecond']
      ..runoutDistanceMeters = json['runoutDistanceMeters']
      ..slopeAngleDegrees = json['slopeAngleDegrees']
      ..trigger = json['trigger']
      ..secondaryHazard = json['secondaryHazard'];

    _populateExtraFields(event, json);

    return event;
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
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeSeismic.values.byName(subtypeStr)
        : EventSubtypeSeismic.unspecified;

    final event = EventSeismic(eventSubtype: subtype)
      ..magnitude = json['magnitude']
      ..magnitudeType = json['magnitudeType']
      ..depth = json['depth']
      ..depthUncertainty = json['depthUncertainty']
      ..focalMechanism = json['focalMechanism'];
    _populateExtraFields(event, json);

    return event;
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
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeVolcanicE.values.byName(subtypeStr)
        : EventSubtypeVolcanicE.other;

    final event = EventVolcanicEruptive(eventSubtype: subtype)
      ..volcanoName = json['volcanoName']
      ..elevation = json['elevation']
      ..plumeHeightMeters = json['plumeHeightMeters']
      ..vei = json['vei']
      ..hazards = json['hazards'];

    _populateExtraFields(event, json);

    return event;
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
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeVolcanicNE.values.byName(subtypeStr)
        : EventSubtypeVolcanicNE.other;

    final event = EventVolcanicNonEruptive(eventSubtype: subtype)
      ..volcanoName = json['volcanoName']
      ..elevation = json['elevation']
      ..groundDeformationMm = json['groundDeformationMm']
      ..so2Flux = json['so2Flux']
      ..fumaroleTemperature = json['fumaroleTemperature'];
  
    _populateExtraFields(event, json);

    return event;
  }
}


class MultisensorEventSerializer extends EventSerializer<EventMultisensor> {
  @override
  Map<String, dynamic> serializeSpecific(EventMultisensor event) {
    return {};
  }

  @override
  EventMultisensor deserialize(Map<String, dynamic> json) {
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeMultisensor.values.byName(subtypeStr)
        : EventSubtypeMultisensor.default_;

    final event = EventMultisensor(eventSubtype: subtype);
    _populateExtraFields(event, json);

    return event;
  }
}

class FalseTestEventSerializer extends EventSerializer<EventFalseTest> {
  @override
  Map<String, dynamic> serializeSpecific(EventFalseTest event) {
    return {};
  }

  @override
  EventFalseTest deserialize(Map<String, dynamic> json) {
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtypeFalseTest.values.byName(subtypeStr)
        : EventSubtypeFalseTest.default_;
    
    final event = EventFalseTest(eventSubtype: subtype);
    _populateExtraFields(event, json);

    return event;
  }
}

class UnspecifiedSerializer extends EventSerializer<Event> {
  @override
  Map<String, dynamic> serializeSpecific(Event event) {return {};}

  @override
  Event deserialize(Map<String, dynamic> json) {
    final subtypeStr = json['eventSubtype'] as String?;
    final subtype = subtypeStr != null
        ? EventSubtype.values.byName(subtypeStr)
        : EventSubtype.unspecified;

    final event = EventUnspecified(eventSubtype: subtype);
    _populateExtraFields(event, json);

    return event;
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
    EventType.multiSensor: MultisensorEventSerializer(),
    EventType.false_test: FalseTestEventSerializer(),
    EventType.unspecified_anomalous: UnspecifiedSerializer(),
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

// because annoying bug ¯\_(ツ)_/¯
void _populateExtraFields(Event event, Map<String, dynamic> json) {
  event.status = EventPostStatus.values.byName(json['status'] ?? 'unspecified');
  event.source = json['source'] ?? '';
  event.description = json['description'] ?? '';
}
