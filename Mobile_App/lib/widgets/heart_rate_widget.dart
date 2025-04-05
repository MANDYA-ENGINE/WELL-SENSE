import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HeartRateWidget extends StatelessWidget {
  final int heartRate;

  const HeartRateWidget({
    super.key,
    required this.heartRate,
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
              'Heart Rate',
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
                    minimum: 0,
                    maximum: 200,
                    ranges: <GaugeRange>[
                      GaugeRange(
                        startValue: 0,
                        endValue: 60,
                        color: Colors.blue,
                      ),
                      GaugeRange(
                        startValue: 60,
                        endValue: 100,
                        color: Colors.green,
                      ),
                      GaugeRange(
                        startValue: 100,
                        endValue: 200,
                        color: Colors.red,
                      ),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: heartRate.toDouble(),
                        needleColor: _getHeartRateColor(heartRate),
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
                          '$heartRate BPM',
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
              _getHeartRateStatus(heartRate),
              style: TextStyle(
                color: _getHeartRateColor(heartRate),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHeartRateColor(int heartRate) {
    if (heartRate < 60) {
      return Colors.blue;
    } else if (heartRate <= 100) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String _getHeartRateStatus(int heartRate) {
    if (heartRate < 60) {
      return 'Low';
    } else if (heartRate <= 100) {
      return 'Normal';
    } else {
      return 'High';
    }
  }
}
