import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HealthData {
  final double heartRate;
  final double temperature;
  final int timestamp;
  final String? status;

  HealthData({
    required this.heartRate,
    required this.temperature,
    required this.timestamp,
    this.status,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) {
    return HealthData(
      heartRate: (json['heartRate'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      timestamp: json['timestamp'] as int,
      status: json['status'] as String?,
    );
  }
}

class FirebaseService {
  final _database = FirebaseDatabase.instance;

  Stream<HealthData> getHealthDataStream() {
    return _database.ref('sensor/livedata').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      return HealthData.fromJson(Map<String, dynamic>.from(data));
    });
  }

  Future<List<HealthData>> getHistoricalData({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final snapshot = await _database
        .ref('sensor/livedata')
        .orderByChild('timestamp')
        .startAt(startTime.millisecondsSinceEpoch)
        .endAt(endTime.millisecondsSinceEpoch)
        .get();

    if (snapshot.value == null) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return [HealthData.fromJson(Map<String, dynamic>.from(data))];
  }
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

final healthDataStreamProvider = StreamProvider<HealthData>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getHealthDataStream();
});
