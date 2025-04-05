import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wellsense/services/firebase_service.dart';
import 'package:wellsense/widgets/heart_rate_widget.dart';
import 'package:wellsense/widgets/temperature_widget.dart';
import 'package:wellsense/screens/patient_info_screen.dart';

// Provider to store the graph data points
final graphDataProvider =
    StateNotifierProvider<GraphDataNotifier, GraphData>((ref) {
  return GraphDataNotifier();
});

// Data class to hold graph points
class GraphData {
  final List<FlSpot> heartRateSpots;
  final List<FlSpot> temperatureSpots;
  final int xValue;

  GraphData({
    this.heartRateSpots = const [],
    this.temperatureSpots = const [],
    this.xValue = 0,
  });

  GraphData copyWith({
    List<FlSpot>? heartRateSpots,
    List<FlSpot>? temperatureSpots,
    int? xValue,
  }) {
    return GraphData(
      heartRateSpots: heartRateSpots ?? this.heartRateSpots,
      temperatureSpots: temperatureSpots ?? this.temperatureSpots,
      xValue: xValue ?? this.xValue,
    );
  }
}

// Notifier to manage graph data
class GraphDataNotifier extends StateNotifier<GraphData> {
  static const int maxPoints = 20;

  GraphDataNotifier() : super(GraphData());

  void addDataPoint(double heartRate, double temperature) {
    final newHeartRateSpots = List<FlSpot>.from(state.heartRateSpots);
    final newTemperatureSpots = List<FlSpot>.from(state.temperatureSpots);
    final newXValue = state.xValue + 1;

    newHeartRateSpots.add(FlSpot(state.xValue.toDouble(), heartRate));
    newTemperatureSpots.add(FlSpot(state.xValue.toDouble(), temperature));

    if (newHeartRateSpots.length > maxPoints) {
      newHeartRateSpots.removeAt(0);
      newTemperatureSpots.removeAt(0);
    }

    state = state.copyWith(
      heartRateSpots: newHeartRateSpots,
      temperatureSpots: newTemperatureSpots,
      xValue: newXValue,
    );
  }
}

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Listen to health data stream
    ref.read(healthDataStreamProvider.stream).listen(
      (healthData) {
        if (mounted) {
          ref.read(graphDataProvider.notifier).addDataPoint(
                healthData.heartRate,
                healthData.temperature,
              );
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final healthDataAsync = ref.watch(healthDataStreamProvider);
    final graphData = ref.watch(graphDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WellSense'),
      ),
      body: _currentIndex == 0
          ? _DashboardContent(
              healthDataAsync: healthDataAsync,
              heartRateSpots: graphData.heartRateSpots,
              temperatureSpots: graphData.temperatureSpots,
            )
          : const PatientInfoScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Patient Info',
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final AsyncValue<HealthData> healthDataAsync;
  final List<FlSpot> heartRateSpots;
  final List<FlSpot> temperatureSpots;

  const _DashboardContent({
    required this.healthDataAsync,
    required this.heartRateSpots,
    required this.temperatureSpots,
  });

  @override
  Widget build(BuildContext context) {
    return healthDataAsync.when(
      data: (data) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: HeartRateWidget(heartRate: data.heartRate.toInt()),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TemperatureWidget(temperature: data.temperature),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Real-time Heart Rate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 16.0, left: 8.0),
                          child: LineChart(
                            LineChartData(
                              minY: 50, // Updated minimum heart rate
                              maxY: 120, // Updated maximum heart rate
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 20,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.shade300,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 45,
                                    interval: 20,
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: heartRateSpots,
                                  isCurved: true,
                                  color: Colors.red,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Real-time Temperature',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250, // Increased height for temperature graph
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 16.0, left: 8.0),
                          child: LineChart(
                            LineChartData(
                              minY: 25, // Updated minimum temperature
                              maxY: 40, // Updated maximum temperature
                              gridData: FlGridData(
                                show: true,
                                horizontalInterval: 5,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.shade300,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 45,
                                    interval: 5,
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: temperatureSpots,
                                  isCurved: true,
                                  color: Colors.orange,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}
