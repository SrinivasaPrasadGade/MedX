import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_app/core/services/api_client.dart';

class Medication {
  final String id;
  final String name;
  final String dose;
  final String time;
  final bool isTaken;
  final String status;
  final String type; // Pill, Injection, Liquid

  Medication({
    required this.id, 
    required this.name, 
    required this.dose, 
    required this.time, 
    this.isTaken = false, 
    this.status = "Scheduled", 
    this.type = "Pill"
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      dose: json['dosage'], // Backend uses 'dosage'
      time: json['time'],
      isTaken: json['isTaken'],
      // Defaults for fields missing in MVP backend
      status: json['isTaken'] ? "Taken" : "Scheduled",
      type: "Pill"
    );
  }

  Medication copyWith({bool? isTaken, String? status}) {
    return Medication(
      id: id, 
      name: name, 
      dose: dose, 
      time: time, 
      isTaken: isTaken ?? this.isTaken,
      status: status ?? (isTaken ?? this.isTaken ? "Taken" : this.status),
      type: type,
    );
  }
}


class MedicationService {
  final ApiClient _apiClient;

  MedicationService(this._apiClient);

  Future<List<Medication>> getDailyMedications() async {
    try {
      // ApiClient base is http://localhost:8080
      // Previous call was to /medications (relative to /medications base) -> /medications/medications
      final response = await _apiClient.client.get('/medications/medications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Medication.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
        print("Fetch Meds Failed: $e");
        return [];
    }
  }

  Future<bool> markAsTaken(String id, bool isTaken) async {
    try {
        final response = await _apiClient.client.patch('/medications/medications/$id/toggle');
        return response.statusCode == 200;
    } catch (e) {
        print("Toggle Med Failed: $e");
        return false;
    }
  }

  Future<bool> addMedication(String name, String dosage, String time) async {
    try {
      final response = await _apiClient.client.post('/medications/medications', 
        data: {
          'name': name,
          'dosage': dosage,
          'time': time
        }
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Add Med Failed: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getWeeklyAnalytics() async {
    try {
      // Note: Endpoint is /analytics/weekly (on medication service)
      // ApiClient maps /medications -> http://127.0.0.1:8001
      // So we need to call /medications/analytics/weekly via Gateway if mapped that way,
      // OR direct service call via Gateway.
      // Gateway Main.py:
      // "medications": "http://127.0.0.1:8001"
      // Route: @app.api_route("/medications/{path:path}")
      // So Gateway /medications/analytics/weekly -> Service /analytics/weekly
      
      final response = await _apiClient.client.get('/analytics/weekly-adherence');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print("Analytics Failed: $e");
      return [];
    }
  }
}

final medicationServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MedicationService(apiClient);
});
