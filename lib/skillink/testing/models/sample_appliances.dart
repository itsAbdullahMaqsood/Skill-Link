import 'package:skilllink/skillink/domain/models/anomaly.dart';
import 'package:skilllink/skillink/domain/models/appliance.dart';
import 'package:skilllink/skillink/domain/models/sensor_reading.dart';

class SampleAppliances {
  SampleAppliances._();

  static const List<Appliance> all = <Appliance>[
    Appliance(
      id: 'appl_ac_living_room',
      userId: 'homeowner_001',
      type: 'ac',
      brand: 'Haier',
      model: '1.5 Ton Inverter',
      iotDeviceId: 'esp32_001',
    ),
    Appliance(
      id: 'appl_fridge_kitchen',
      userId: 'homeowner_001',
      type: 'fridge',
      brand: 'Dawlance',
      model: '14 cu ft',
      iotDeviceId: 'esp32_002',
    ),
    Appliance(
      id: 'appl_heater_bedroom',
      userId: 'homeowner_001',
      type: 'heater',
      brand: 'NasGas',
      model: 'Gas Heater',
      iotDeviceId: 'esp32_003',
    ),
  ];

  static const Map<String, ({double voltage, double current, double wattage})>
      nominalBand = {
    'appl_ac_living_room': (voltage: 220, current: 5.5, wattage: 1210),
    'appl_fridge_kitchen': (voltage: 220, current: 0.7, wattage: 154),
    'appl_heater_bedroom': (voltage: 220, current: 4.1, wattage: 900),
  };

  static Anomaly seededAnomaly({DateTime? detectedAt}) => Anomaly(
        id: 'an_seed_001',
        applianceId: 'appl_ac_living_room',
        applianceName: 'Living Room AC',
        type: 'voltage_spike',
        message: 'Voltage briefly spiked to 246V — check the outlet wiring.',
        severity: 'high',
        detectedAt: detectedAt ??
            DateTime.now().subtract(const Duration(minutes: 8)),
        suggestedTrade: 'electrician',
      );

  static List<SensorReading> history({
    required String applianceId,
    required Duration duration,
    int points = 60,
  }) {
    final band = nominalBand[applianceId] ??
        const (voltage: 220, current: 1, wattage: 220);
    final now = DateTime.now();
    final step = duration ~/ points;
    final seed = applianceId.hashCode;
    final list = <SensorReading>[];
    for (var i = 0; i < points; i++) {
      final t = now.subtract(step * (points - 1 - i));
      final wobble = (((i * 17 + seed) & 0x3f) / 0x3f) - 0.5;
      final watt = band.wattage * (1 + wobble * 0.1);
      final amp = band.current * (1 + wobble * 0.08);
      list.add(SensorReading(
        voltage: band.voltage + wobble * 4,
        current: amp,
        wattage: watt,
        timestamp: t,
      ));
    }
    return list;
  }
}
