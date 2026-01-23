part of '../event_post_wizard.dart';

class _ExtraDetailsStepState extends State<_ExtraDetailsStep> {
  late final Map<String, TextEditingController> _controllers;
  // Map<String, dynamic Function(EventPostWizardController)>

@override
void initState() {
  super.initState();
  final wizard = context.read<EventPostWizardController>();

  _controllers = {
    // anthropogenic
    'activityType': TextEditingController(text: wizard.activityType ?? ''),
    'explosiveYieldKg':
        TextEditingController(text: wizard.explosiveYieldKg?.toString() ?? ''),
    'isConfirmedIntentional':
        TextEditingController(text: wizard.isConfirmedIntentional?.toString() ?? ''),

    // atmospheric
    'phenomenon': TextEditingController(text: wizard.phenomenon ?? ''),
    'peakOverpressurePa':
        TextEditingController(text: wizard.peakOverpressurePa?.toString() ?? ''),
    'altitudeKm':
        TextEditingController(text: wizard.altitudeKm?.toString() ?? ''),
    'estimatedEnergyJoules':
        TextEditingController(text: wizard.estimatedEnergyJoules?.toString() ?? ''),

    // cryoseismic
    'iceThicknessMeters':
        TextEditingController(text: wizard.iceThicknessMeters?.toString() ?? ''),
    'airTemperatureCelsius':
        TextEditingController(text: wizard.airTemperatureCelsius?.toString() ?? ''),
    'glacierIceBodyName':
        TextEditingController(text: wizard.glacierIceBodyName ?? ''),
    'crackLengthMeters':
        TextEditingController(text: wizard.crackLengthMeters?.toString() ?? ''),

    // geodetic
    'displacementNorthMm':
        TextEditingController(text: wizard.displacementNorthMm?.toString() ?? ''),
    'displacementEastMm':
        TextEditingController(text: wizard.displacementEastMm?.toString() ?? ''),
    'displacementVerticalMm':
        TextEditingController(text: wizard.displacementVerticalMm?.toString() ?? ''),
    'instrumentType':
        TextEditingController(text: wizard.instrumentType ?? ''),

    // hydrothermal
    'featureType':
        TextEditingController(text: wizard.featureType ?? ''),
    'waterTemperatureCelsius':
        TextEditingController(text: wizard.waterTemperatureCelsius?.toString() ?? ''),
    'phLevel':
        TextEditingController(text: wizard.phLevel?.toString() ?? ''),
    'dischargeRateLitersPerSec':
        TextEditingController(text: wizard.dischargeRateLitersPerSec?.toString() ?? ''),
    'eruptionOccurred':
        TextEditingController(text: wizard.eruptionOccurred?.toString() ?? ''),

    // mass movement
    'volumeM3':
        TextEditingController(text: wizard.volumeM3?.toString() ?? ''),
    'velocityMetersPerSecond':
        TextEditingController(text: wizard.velocityMetersPerSecond?.toString() ?? ''),
    'runoutDistanceMeters':
        TextEditingController(text: wizard.runoutDistanceMeters?.toString() ?? ''),
    'slopeAngleDegrees':
        TextEditingController(text: wizard.slopeAngleDegrees?.toString() ?? ''),
    'trigger':
        TextEditingController(text: wizard.trigger ?? ''),
    'secondaryHazard':
        TextEditingController(text: wizard.secondaryHazard ?? ''),

    // seismic
    'magnitude':
        TextEditingController(text: wizard.magnitude?.toString() ?? ''),
    'magnitudeType':
        TextEditingController(text: wizard.magnitudeType ?? ''),
    'depth':
        TextEditingController(text: wizard.depth?.toString() ?? ''),
    'depthUncertainty':
        TextEditingController(text: wizard.depthUncertainty?.toString() ?? ''),
    'focalMechanism':
        TextEditingController(text: wizard.focalMechanism ?? ''),

    // volcanic
    'volcanoName':
        TextEditingController(text: wizard.volcanoName ?? ''),
    'elevation':
        TextEditingController(text: wizard.elevation?.toString() ?? ''),

    // volcanic eruptive
    'plumeHeightMeters':
        TextEditingController(text: wizard.plumeHeightMeters?.toString() ?? ''),
    'vei':
        TextEditingController(text: wizard.vei?.toString() ?? ''),
    'hazards':
        TextEditingController(text: wizard.hazards ?? ''),

    // volcanic non-eruptive
    'groundDeformationMm':
        TextEditingController(text: wizard.groundDeformationMm?.toString() ?? ''),
    'so2Flux':
        TextEditingController(text: wizard.so2Flux?.toString() ?? ''),
    'fumaroleTemperature':
        TextEditingController(text: wizard.fumaroleTemperature?.toString() ?? ''),
  };
}


  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventPostWizardController>();
    
    // Determine which fields to show based on event type
    List<Widget> fields = [];
    
    if (controller.eventType == null) {
      return const Center(
        child: Text(
          'Please select an event type first',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }
    
    // Helper function to create text fields
    Widget buildTextField(String key, String label, {Function(String)? onSubmit}) {
      return Column(
        children: [
          TextField(
            controller: _controllers[key],
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: const Color(0xFF8C8B9E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: onSubmit ?? (value) {
              // Default submission handler - you'll need to add setters to controller
              controller.notifyListeners();
            },
          ),
          const SizedBox(height: 8),
        ],
      );
    }
    
    // Add fields based on event type
    switch (controller.eventType) {
      case EventType.anthropogenic:
        fields.addAll([
          buildTextField('activityType', 'Activity Type', 
            onSubmit: (v) { controller.activityType = v; controller.notifyListeners(); }),
          buildTextField('explosiveYieldKg', 'Explosive Yield (kg)',
            onSubmit: (v) { controller.explosiveYieldKg = v; controller.notifyListeners(); }),
          buildTextField('isConfirmedIntentional', 'Confirmed Intentional (true/false)',
            onSubmit: (v) { controller.isConfirmedIntentional = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.atmospheric_coupledSignals:
        fields.addAll([
          buildTextField('phenomenon', 'Phenomenon',
            onSubmit: (v) { controller.phenomenon = v; controller.notifyListeners(); }),
          buildTextField('peakOverpressurePa', 'Peak Overpressure (Pa)',
            onSubmit: (v) { controller.peakOverpressurePa = v; controller.notifyListeners(); }),
          buildTextField('altitudeKm', 'Altitude (km)',
            onSubmit: (v) { controller.altitudeKm = v; controller.notifyListeners(); }),
          buildTextField('estimatedEnergyJoules', 'Estimated Energy (Joules)',
            onSubmit: (v) { controller.estimatedEnergyJoules = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.cryoseismic_glacial:
        fields.addAll([
          buildTextField('iceThicknessMeters', 'Ice Thickness (m)',
            onSubmit: (v) { controller.iceThicknessMeters = v; controller.notifyListeners(); }),
          buildTextField('airTemperatureCelsius', 'Air Temperature (°C)',
            onSubmit: (v) { controller.airTemperatureCelsius = v; controller.notifyListeners(); }),
          buildTextField('glacierIceBodyName', 'Glacier/Ice Body Name',
            onSubmit: (v) { controller.glacierIceBodyName = v; controller.notifyListeners(); }),
          buildTextField('crackLengthMeters', 'Crack Length (m)',
            onSubmit: (v) { controller.crackLengthMeters = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.geodetic_deformation:
        fields.addAll([
          buildTextField('displacementNorthMm', 'Displacement North (mm)',
            onSubmit: (v) { controller.displacementNorthMm = v; controller.notifyListeners(); }),
          buildTextField('displacementEastMm', 'Displacement East (mm)',
            onSubmit: (v) { controller.displacementEastMm = v; controller.notifyListeners(); }),
          buildTextField('displacementVerticalMm', 'Displacement Vertical (mm)',
            onSubmit: (v) { controller.displacementVerticalMm = v; controller.notifyListeners(); }),
          buildTextField('instrumentType', 'Instrument Type',
            onSubmit: (v) { controller.instrumentType = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.hydrothermal_fluidDriven:
        fields.addAll([
          buildTextField('featureType', 'Feature Type',
            onSubmit: (v) { controller.featureType = v; controller.notifyListeners(); }),
          buildTextField('waterTemperatureCelsius', 'Water Temperature (°C)',
            onSubmit: (v) { controller.waterTemperatureCelsius = v; controller.notifyListeners(); }),
          buildTextField('phLevel', 'pH Level',
            onSubmit: (v) { controller.phLevel = v; controller.notifyListeners(); }),
          buildTextField('dischargeRateLitersPerSec', 'Discharge Rate (L/s)',
            onSubmit: (v) { controller.dischargeRateLitersPerSec = v; controller.notifyListeners(); }),
          buildTextField('eruptionOccurred', 'Eruption Occurred (true/false)',
            onSubmit: (v) { controller.eruptionOccurred = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.massMovement_surfaceInstability:
        fields.addAll([
          buildTextField('volumeM3', 'Volume (m³)',
            onSubmit: (v) { controller.volumeM3 = v; controller.notifyListeners(); }),
          buildTextField('velocityMetersPerSecond', 'Velocity (m/s)',
            onSubmit: (v) { controller.velocityMetersPerSecond = v; controller.notifyListeners(); }),
          buildTextField('runoutDistanceMeters', 'Runout Distance (m)',
            onSubmit: (v) { controller.runoutDistanceMeters = v; controller.notifyListeners(); }),
          buildTextField('slopeAngleDegrees', 'Slope Angle (degrees)',
            onSubmit: (v) { controller.slopeAngleDegrees = v; controller.notifyListeners(); }),
          buildTextField('trigger', 'Trigger',
            onSubmit: (v) { controller.trigger = v; controller.notifyListeners(); }),
          buildTextField('secondaryHazard', 'Secondary Hazard',
            onSubmit: (v) { controller.secondaryHazard = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.seismic_tectonic:
        fields.addAll([
          buildTextField('magnitude', 'Magnitude',
            onSubmit: (v) { controller.magnitude = v; controller.notifyListeners(); }),
          buildTextField('magnitudeType', 'Magnitude Type',
            onSubmit: (v) { controller.magnitudeType = v; controller.notifyListeners(); }),
          buildTextField('depth', 'Depth (km)',
            onSubmit: (v) { controller.depth = v; controller.notifyListeners(); }),
          buildTextField('depthUncertainty', 'Depth Uncertainty (km)',
            onSubmit: (v) { controller.depthUncertainty = v; controller.notifyListeners(); }),
          buildTextField('focalMechanism', 'Focal Mechanism',
            onSubmit: (v) { controller.focalMechanism = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.volcanicEruptive_surfaceProcess || EventType.volcanicNonEruptive:
        fields.addAll([
          buildTextField('volcanoName', 'Volcano Name',
            onSubmit: (v) { controller.volcanoName = v; controller.notifyListeners(); }),
          buildTextField('elevation', 'Elevation (m)',
            onSubmit: (v) { controller.elevation = v; controller.notifyListeners(); }),
        ]);
        
        // Check subtype for additional fields
        switch (controller.eventType)
        {
        case EventType.volcanicEruptive_surfaceProcess:
          fields.addAll([
            buildTextField('plumeHeightMeters', 'Plume Height (m)',
              onSubmit: (v) { controller.plumeHeightMeters = v; controller.notifyListeners(); }),
            buildTextField('vei', 'VEI (Volcanic Explosivity Index)',
              onSubmit: (v) { controller.vei = v; controller.notifyListeners(); }),
            buildTextField('hazards', 'Hazards',
              onSubmit: (v) { controller.hazards = v; controller.notifyListeners(); }),
          ]);
          break;
          
         case EventType.volcanicNonEruptive:
          fields.addAll([
            buildTextField('groundDeformationMm', 'Ground Deformation (mm)',
              onSubmit: (v) { controller.groundDeformationMm = v; controller.notifyListeners(); }),
            buildTextField('so2Flux', 'SO₂ Flux',
              onSubmit: (v) { controller.so2Flux = v; controller.notifyListeners(); }),
            buildTextField('fumaroleTemperature', 'Fumarole Temperature (°C)',
              onSubmit: (v) { controller.fumaroleTemperature = v; controller.notifyListeners(); }),
          ]);
          break;

          case _:
            break;
        }
        break;
        
      default:
        return const Center(
          child: Text(
            'No additional details required for this event type',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Extra Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 16),
        ...fields,
      ],
    );
  }
}
