import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:patient_app/core/services/medication_service.dart';
import 'package:patient_app/core/services/clinical_service.dart';
import 'package:patient_app/features/dashboard/presentation/providers/medication_provider.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  XFile? _imageFile; // Changed from File to XFile for Web support
  final ImagePicker _picker = ImagePicker();
  bool _isAnalyzing = false;
  String? _result;
  
  // State variables for parsed data
  Map<String, dynamic>? _parsedData;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _result = null;
          _parsedData = null;
        });
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  Future<void> _analyze() async {
    if (_imageFile == null) return;
    
    setState(() {
      _isAnalyzing = true;
      _parsedData = null;
      _result = null;
    });
    
    final service = ref.read(clinicalServiceProvider);
    final response = await service.analyzeDocument(_imageFile!);
    
    setState(() {
      _isAnalyzing = false;
      if (response != null && response.data != null) {
        try {
          // Decode JSON string from 'data' field
          _parsedData = jsonDecode(response.data!);
        } catch (e) {
          _result = "Failed to parse result: ${response.data}";
        }
      } else {
        _result = response?.note ?? "Analysis failed.";
      }
    });
  }

  Future<void> _addToSchedule(Map<String, dynamic> med) async {
    // Basic extraction of fields, defaulting if missing
    final name = med['name'] ?? 'Unknown Med';
    final dosage = med['dosage'] ?? '';
    final freq = med['frequency'] ?? '';
    // Construct a time string (simplified for demo)
    String time = "9:00 AM"; 
    if (freq.toString().toLowerCase().contains("pm") || freq.toString().toLowerCase().contains("night")) {
      time = "9:00 PM";
    }

    // Use Provider Notifier instead of raw Service to ensure HomePage updates
    final success = await ref.read(medicationProvider.notifier).addMedication(name, dosage, time);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Added $name to schedule"), 
          backgroundColor: Colors.green
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to add medication"), 
          backgroundColor: Colors.red
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan Documents", style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF5F5F7),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview Area
              GestureDetector(
                onTap: () => _showPickOptions(),
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                  ),
                  child: _imageFile != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18), 
                        child: kIsWeb 
                          ? Image.network(_imageFile!.path, fit: BoxFit.cover) 
                          : Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.document_scanner_rounded, size: 48, color: Colors.indigo.shade400),
                          const SizedBox(height: 12),
                          Text("Tap to scan medical report", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500))
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Analyze Button
              ElevatedButton.icon(
                onPressed: (_imageFile != null && !_isAnalyzing) ? _analyze : null,
                icon: _isAnalyzing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.analytics_outlined),
                label: Text(_isAnalyzing ? "Analyzing with Gemini..." : "Analyze Document"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
              ),
              const SizedBox(height: 24),

              // Results Area - Parsed
              if (_parsedData != null) ...[
                _buildInfoCard(),
                const SizedBox(height: 16),
                Text("Detected Medications", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildMedicationList(),
              ],

              // Fallback Results Area - Raw Text (Error case)
              if (_result != null && _parsedData == null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(_result!, style: GoogleFonts.robotoMono(fontSize: 13, color: Colors.red.shade800))
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildRow(Icons.person, "Patient", _parsedData!['patient_name'] ?? 'N/A'),
          const Divider(),
          _buildRow(Icons.calendar_today, "Date", _parsedData!['date'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget _buildMedicationList() {
    final List meds = _parsedData!['medications'] ?? [];
    if (meds.isEmpty) return const Text("No medications found.");

    return Column(
      children: meds.map((med) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.medication, color: Colors.blue.shade700),
            ),
            title: Text(med['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${med['dosage'] ?? ''} • ${med['frequency'] ?? ''}"),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF34C759), size: 32),
              onPressed: () => _addToSchedule(med),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
