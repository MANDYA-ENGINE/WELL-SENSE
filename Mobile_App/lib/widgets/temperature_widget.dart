import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TemperatureWidget extends StatelessWidget {
  final double temperature;

  const TemperatureWidget({
    super.key,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Temperature',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 35,
                    maximum: 42,
                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: 35,
                        endValue: 36.5,
                        color: Colors.blue,
                      ),
                      GaugeRange(
                        startValue: 36.5,
                        endValue: 37.5,
                        color: Colors.green,
                      ),
                      GaugeRange(
                        startValue: 37.5,
                        endValue: 42,
                        color: Colors.red,
                      ),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: temperature,
                        needleColor: _getTemperatureColor(temperature),
                        needleLength: 0.8,
                        needleStartWidth: 1,
                        needleEndWidth: 3,
                        knobStyle: const KnobStyle(
                          knobRadius: 0.08,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        angle: 90,
                        positionFactor: 1.3,
                        widget: Text(
                          '${temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getTemperatureStatus(temperature),
              style: TextStyle(
                color: _getTemperatureColor(temperature),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 36.5) {
      return Colors.blue;
    } else if (temperature <= 37.5) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String _getTemperatureStatus(double temperature) {
    if (temperature < 36.5) {
      return 'Low';
    } else if (temperature <= 37.5) {
      return 'Normal';
    } else {
      return 'High';
    }
  }
}
