part of '../event_post_wizard.dart';

class _EventTypeDetailsStepState extends State<_EventTypeDetailsStep> {
  late final Map<String, TextEditingController> _controllers;
  // Map<String, dynamic Function(EventPostWizardController)>

@override
void initState() {
  super.initState();
  final wizard = context.read<EventPostWizardController>();

  _controllers = {
    // anthropogenic
    'activityType': TextEditingController(text: wizard.anthropogenic.activityType ?? ''),
    'explosiveYieldKg':
        TextEditingController(text: wizard.anthropogenic.explosiveYieldKg?.toString() ?? ''),
    'isConfirmedIntentional':
        TextEditingController(text: wizard.anthropogenic.isConfirmedIntentional?.toString() ?? ''),

    // atmospheric
    'phenomenon': TextEditingController(text: wizard.atmospheric.phenomenon ?? ''),
    'peakOverpressurePa':
        TextEditingController(text: wizard.atmospheric.peakOverpressurePa?.toString() ?? ''),
    'altitudeKm':
        TextEditingController(text: wizard.atmospheric.altitudeKm?.toString() ?? ''),
    'estimatedEnergyJoules':
        TextEditingController(text: wizard.atmospheric.estimatedEnergyJoules?.toString() ?? ''),

    // cryoseismic
    'iceThicknessMeters':
        TextEditingController(text: wizard.cryoseismic.iceThicknessMeters?.toString() ?? ''),
    'airTemperatureCelsius':
        TextEditingController(text: wizard.cryoseismic.airTemperatureCelsius?.toString() ?? ''),
    'glacierIceBodyName':
        TextEditingController(text: wizard.cryoseismic.glacierIceBodyName ?? ''),
    'crackLengthMeters':
        TextEditingController(text: wizard.cryoseismic.crackLengthMeters?.toString() ?? ''),

    // geodetic
    'displacementNorthMm':
        TextEditingController(text: wizard.geodetic.displacementNorthMm?.toString() ?? ''),
    'displacementEastMm':
        TextEditingController(text: wizard.geodetic.displacementEastMm?.toString() ?? ''),
    'displacementVerticalMm':
        TextEditingController(text: wizard.geodetic.displacementVerticalMm?.toString() ?? ''),
    'instrumentType':
        TextEditingController(text: wizard.geodetic.instrumentType ?? ''),

    // hydrothermal
    'featureType':
        TextEditingController(text: wizard.hydrothermal.featureType ?? ''),
    'waterTemperatureCelsius':
        TextEditingController(text: wizard.hydrothermal.waterTemperatureCelsius?.toString() ?? ''),
    'phLevel':
        TextEditingController(text: wizard.hydrothermal.phLevel?.toString() ?? ''),
    'dischargeRateLitersPerSec':
        TextEditingController(text: wizard.hydrothermal.dischargeRateLitersPerSec?.toString() ?? ''),
    'eruptionOccurred':
        TextEditingController(text: wizard.hydrothermal.eruptionOccurred?.toString() ?? ''),

    // mass movement
    'volumeM3':
        TextEditingController(text: wizard.massMovement.volumeM3?.toString() ?? ''),
    'velocityMetersPerSecond':
        TextEditingController(text: wizard.massMovement.velocityMetersPerSecond?.toString() ?? ''),
    'runoutDistanceMeters':
        TextEditingController(text: wizard.massMovement.runoutDistanceMeters?.toString() ?? ''),
    'slopeAngleDegrees':
        TextEditingController(text: wizard.massMovement.slopeAngleDegrees?.toString() ?? ''),
    'trigger':
        TextEditingController(text: wizard.massMovement.trigger ?? ''),
    'secondaryHazard':
        TextEditingController(text: wizard.massMovement.secondaryHazard ?? ''),

    // seismic
    'magnitude':
        TextEditingController(text: wizard.seismic.magnitude?.toString() ?? ''),
    'magnitudeType':
        TextEditingController(text: wizard.seismic.magnitudeType ?? ''),
    'depth':
        TextEditingController(text: wizard.seismic.depth?.toString() ?? ''),
    'depthUncertainty':
        TextEditingController(text: wizard.seismic.depthUncertainty?.toString() ?? ''),
    'focalMechanism':
        TextEditingController(text: wizard.seismic.focalMechanism ?? ''),

    // volcanic
    // volcanic eruptive
    'volcanoNameEruptive':
        TextEditingController(text: wizard.volcanicEruptive.volcanoName ?? ''),
    'elevationEruptive':
        TextEditingController(text: wizard.volcanicEruptive.elevation?.toString() ?? ''),
    'plumeHeightMeters':
        TextEditingController(text: wizard.volcanicEruptive.plumeHeightMeters?.toString() ?? ''),
    'vei':
        TextEditingController(text: wizard.volcanicEruptive.vei?.toString() ?? ''),
    'hazards':
        TextEditingController(text: wizard.volcanicEruptive.hazards?.join(', ') ?? ''),

    // volcanic non-eruptive
    'volcanoNameNonEruptive':
        TextEditingController(text: wizard.volcanicNonEruptive.volcanoName ?? ''),
    'elevationNonEruptive':
        TextEditingController(text: wizard.volcanicNonEruptive.elevation?.toString() ?? ''),
    'groundDeformationMm':
        TextEditingController(text: wizard.volcanicNonEruptive.groundDeformationMm?.toString() ?? ''),
    'so2Flux':
        TextEditingController(text: wizard.volcanicNonEruptive.so2Flux?.toString() ?? ''),
    'fumaroleTemperature':
        TextEditingController(text: wizard.volcanicNonEruptive.fumaroleTemperature?.toString() ?? ''),
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
            onSubmit: (v) { controller.anthropogenic.activityType = v; controller.notifyListeners(); }),
          buildTextField('explosiveYieldKg', 'Explosive Yield (kg)',
            onSubmit: (v) { controller.anthropogenic.explosiveYieldKg = v; controller.notifyListeners(); }),
          buildTextField('isConfirmedIntentional', 'Confirmed Intentional (true/false)',
            onSubmit: (v) { controller.anthropogenic.isConfirmedIntentional = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.atmospheric_coupledSignals:
        fields.addAll([
          buildTextField('phenomenon', 'Phenomenon',
            onSubmit: (v) { controller.atmospheric.phenomenon = v; controller.notifyListeners(); }),
          buildTextField('peakOverpressurePa', 'Peak Overpressure (Pa)',
            onSubmit: (v) { controller.atmospheric.peakOverpressurePa = v; controller.notifyListeners(); }),
          buildTextField('altitudeKm', 'Altitude (km)',
            onSubmit: (v) { controller.atmospheric.altitudeKm = v; controller.notifyListeners(); }),
          buildTextField('estimatedEnergyJoules', 'Estimated Energy (Joules)',
            onSubmit: (v) { controller.atmospheric.estimatedEnergyJoules = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.cryoseismic_glacial:
        fields.addAll([
          buildTextField('iceThicknessMeters', 'Ice Thickness (m)',
            onSubmit: (v) { controller.cryoseismic.iceThicknessMeters = v; controller.notifyListeners(); }),
          buildTextField('airTemperatureCelsius', 'Air Temperature (°C)',
            onSubmit: (v) { controller.cryoseismic.airTemperatureCelsius = v; controller.notifyListeners(); }),
          buildTextField('glacierIceBodyName', 'Glacier/Ice Body Name',
            onSubmit: (v) { controller.cryoseismic.glacierIceBodyName = v; controller.notifyListeners(); }),
          buildTextField('crackLengthMeters', 'Crack Length (m)',
            onSubmit: (v) { controller.cryoseismic.crackLengthMeters = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.geodetic_deformation:
        fields.addAll([
          buildTextField('displacementNorthMm', 'Displacement North (mm)',
            onSubmit: (v) { controller.geodetic.displacementNorthMm = v; controller.notifyListeners(); }),
          buildTextField('displacementEastMm', 'Displacement East (mm)',
            onSubmit: (v) { controller.geodetic.displacementEastMm = v; controller.notifyListeners(); }),
          buildTextField('displacementVerticalMm', 'Displacement Vertical (mm)',
            onSubmit: (v) { controller.geodetic.displacementVerticalMm = v; controller.notifyListeners(); }),
          buildTextField('instrumentType', 'Instrument Type',
            onSubmit: (v) { controller.geodetic.instrumentType = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.hydrothermal_fluidDriven:
        fields.addAll([
          buildTextField('featureType', 'Feature Type',
            onSubmit: (v) { controller.hydrothermal.featureType = v; controller.notifyListeners(); }),
          buildTextField('waterTemperatureCelsius', 'Water Temperature (°C)',
            onSubmit: (v) { controller.hydrothermal.waterTemperatureCelsius = v; controller.notifyListeners(); }),
          buildTextField('phLevel', 'pH Level',
            onSubmit: (v) { controller.hydrothermal.phLevel = v; controller.notifyListeners(); }),
          buildTextField('dischargeRateLitersPerSec', 'Discharge Rate (L/s)',
            onSubmit: (v) { controller.hydrothermal.dischargeRateLitersPerSec = v; controller.notifyListeners(); }),
          buildTextField('eruptionOccurred', 'Eruption Occurred (true/false)',
            onSubmit: (v) { controller.hydrothermal.eruptionOccurred = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.massMovement_surfaceInstability:
        fields.addAll([
          buildTextField('volumeM3', 'Volume (m³)',
            onSubmit: (v) { controller.massMovement.volumeM3 = v; controller.notifyListeners(); }),
          buildTextField('velocityMetersPerSecond', 'Velocity (m/s)',
            onSubmit: (v) { controller.massMovement.velocityMetersPerSecond = v; controller.notifyListeners(); }),
          buildTextField('runoutDistanceMeters', 'Runout Distance (m)',
            onSubmit: (v) { controller.massMovement.runoutDistanceMeters = v; controller.notifyListeners(); }),
          buildTextField('slopeAngleDegrees', 'Slope Angle (degrees)',
            onSubmit: (v) { controller.massMovement.slopeAngleDegrees = v; controller.notifyListeners(); }),
          buildTextField('trigger', 'Trigger',
            onSubmit: (v) { controller.massMovement.trigger = v; controller.notifyListeners(); }),
          buildTextField('secondaryHazard', 'Secondary Hazard',
            onSubmit: (v) { controller.massMovement.secondaryHazard = v; controller.notifyListeners(); }),
        ]);
        break;
        
      case EventType.seismic_tectonic:
        fields.addAll([
          buildTextField('magnitude', 'Magnitude',
            onSubmit: (v) { controller.seismic.magnitude = v; controller.notifyListeners(); }),
          buildTextField('magnitudeType', 'Magnitude Type',
            onSubmit: (v) { controller.seismic.magnitudeType = v; controller.notifyListeners(); }),
          buildTextField('depth', 'Depth (km)',
            onSubmit: (v) { controller.seismic.depth = v; controller.notifyListeners(); }),
          buildTextField('depthUncertainty', 'Depth Uncertainty (km)',
            onSubmit: (v) { controller.seismic.depthUncertainty = v; controller.notifyListeners(); }),
          buildTextField('focalMechanism', 'Focal Mechanism',
            onSubmit: (v) { controller.seismic.focalMechanism = v; controller.notifyListeners(); }),
        ]);
        break;
        
      // case EventType.volcanicEruptive_surfaceProcess || EventType.volcanicNonEruptive:
      //   fields.addAll([
      //     buildTextField('volcanoName', 'Volcano Name',
      //       onSubmit: (v) { controller.volcanoName = v; controller.notifyListeners(); }),
      //     buildTextField('elevation', 'Elevation (m)',
      //       onSubmit: (v) { controller.elevation = v; controller.notifyListeners(); }),
      //   ]);
        
      case EventType.volcanicEruptive_surfaceProcess:
        fields.addAll([
          buildTextField('volcanoNameEruptive', 'Volcano Name',
            onSubmit: (v) { 
              controller.volcanicEruptive.volcanoName = v; 
              controller.notifyListeners(); 
            }),
          buildTextField('elevationEruptive', 'Elevation (m)',
            onSubmit: (v) { 
              controller.volcanicEruptive.elevation = v; 
              controller.notifyListeners(); 
            }),
          buildTextField('plumeHeightMeters', 'Plume Height (m)',
            onSubmit: (v) { 
              controller.volcanicEruptive.plumeHeightMeters = v; 
              controller.notifyListeners(); 
            }),
          buildTextField('vei', 'VEI (Volcanic Explosivity Index 0-8)',
            onSubmit: (v) { 
              controller.volcanicEruptive.vei = v; 
              controller.notifyListeners(); 
            }),
          buildTextField('hazards', 'Hazards (comma-separated)',
            onSubmit: (v) { 
              // Parse comma-separated list
              controller.volcanicEruptive.hazards = v
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              controller.notifyListeners(); 
            }),
        ]);
        break;
          
      case EventType.volcanicNonEruptive:
        fields.addAll([
          buildTextField('volcanoNameNonEruptive', 'Volcano Name',
            onSubmit: (v) { 
              controller.volcanicNonEruptive.volcanoName = v; 
              controller.notifyListeners(); 
            }),
          buildTextField('elevationNonEruptive', 'Elevation (m)',
            onSubmit: (v) { 
              controller.volcanicNonEruptive.elevation = v; 
              controller.notifyListeners(); 
            }),
          buildTextField('groundDeformationMm', 'Ground Deformation (mm)',
            onSubmit: (v) { 
              controller.volcanicNonEruptive.groundDeformationMm = v; 
              controller.notifyListeners(); 
            }),
          buildTextField('so2Flux', 'SO₂ Flux (tonnes/day)',
            onSubmit: (v) { 
              controller.volcanicNonEruptive.so2Flux = v; 
              controller.notifyListeners(); 
            }),
          buildTextField('fumaroleTemperature', 'Fumarole Temperature (°C)',
            onSubmit: (v) { 
              controller.volcanicNonEruptive.fumaroleTemperature = v; 
              controller.notifyListeners(); 
            }),
        ]);
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
          'Event Type Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 16),
        ...fields,
      ],
    );
  }
}
