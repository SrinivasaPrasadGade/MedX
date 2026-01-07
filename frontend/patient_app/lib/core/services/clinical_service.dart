import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:patient_app/core/services/api_client.dart';

// --- Models ---

class InteractionResponse {
  final String? warning;
  final String? severity;

  InteractionResponse({this.warning, this.severity});

  factory InteractionResponse.fromJson(Map<String, dynamic> json) {
    return InteractionResponse(
      warning: json['warning'],
      severity: json['severity'],
    );
  }
}

class ExtractionResponse {
  final String? name;
  final String? dosage;
  final String? time;

  ExtractionResponse({this.name, this.dosage, this.time});

  factory ExtractionResponse.fromJson(Map<String, dynamic> json) {
    return ExtractionResponse(
      name: json['name'],
      dosage: json['dosage'],
      time: json['time'],
    );
  }
}

class DocumentAnalysisResponse {
  final String status;
  final String? data; // Raw JSON string from AI
  final String? note;

  DocumentAnalysisResponse({required this.status, this.data, this.note});

  factory DocumentAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return DocumentAnalysisResponse(
      status: json['status'],
      data: json['data'],
      note: json['note'],
    );
  }
}

// --- Service ---


class ClinicalService {
  final ApiClient _apiClient;

  ClinicalService(this._apiClient);

  Future<InteractionResponse?> checkInteractions(String newMed, List<String> currentMeds) async {
    try {
      final response = await _apiClient.client.post('/clinical/interactions/check', 
        data: {
          'new_med': newMed,
          'current_meds': currentMeds
        }
      );
      
      if (response.statusCode == 200) {
        return InteractionResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Interaction Check Failed: $e");
      return null; 
    }
  }

  Future<ExtractionResponse?> extractMedication(String text) async {
    try {
      final response = await _apiClient.client.post('/clinical/nlp/extract', 
        data: { 'text': text }
      );
      
      if (response.statusCode == 200) {
        return ExtractionResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("NLP Extraction Failed: $e");
      return null;
    }
  }

  Future<DocumentAnalysisResponse?> analyzeDocument(XFile file) async {
    try {
      MultipartFile multipartFile;
      
      if (kIsWeb) {
        // Web: Use bytes
        final bytes = await file.readAsBytes();
        multipartFile = MultipartFile.fromBytes(bytes, filename: file.name);
      } else {
        // Mobile: Use path (better for large files)
        multipartFile = await MultipartFile.fromFile(file.path, filename: file.name);
      }

      FormData formData = FormData.fromMap({
        "file": multipartFile,
      });

      final response = await _apiClient.client.post('/clinical/documents/analyze', 
        data: formData
      );
      
      if (response.statusCode == 200) {
        return DocumentAnalysisResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print("Document Analysis Failed: $e");
      return null;
    }
  }

  Future<String?> chatWithAI(String sessionId, String message) async {
    try {
      final response = await _apiClient.client.post('/clinical/chat', 
        data: {
          'session_id': sessionId,
          'message': message
        }
      );
      
      if (response.statusCode == 200) {
        return response.data['response'];
      }
      return null;
    } catch (e) {
      print("Chat Failed: $e");
      return null;
    }
  }
}

final clinicalServiceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ClinicalService(apiClient);
});
