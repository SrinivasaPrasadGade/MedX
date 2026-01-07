import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_app/core/services/medication_service.dart';
import 'package:patient_app/core/services/notification_service.dart';

class MedicationNotifier extends StateNotifier<List<Medication>> {
  final MedicationService _service;
  final NotificationService _notifications;
  
  MedicationNotifier(this._service, this._notifications) : super([]) {
    loadMedications();
  }

  Future<void> loadMedications() async {
    state = await _service.getDailyMedications();
  }

  Future<void> toggleTaken(String id) async {
    // Optimistic Update
    final med = state.firstWhere((m) => m.id == id);
    final newItem = med.copyWith(isTaken: !med.isTaken);
    
    state = [
      for (final m in state)
        if (m.id == id) newItem else m
    ];
    
    // Trigger Notification for "Reminder" if unticking
    if (!newItem.isTaken) {
       await _notifications.showNotification(
         id: int.tryParse(id) ?? 0, 
         title: "Reminder Set", 
         body: "We'll remind you to take ${med.name} later!"
       );
    }
    
    // Call Service
    final success = await _service.markAsTaken(id, newItem.isTaken);
    if (!success) {
      // Revert if failed
       state = [
        for (final m in state)
          if (m.id == id) med else m
      ];
    }
  }
  
  Future<bool> addMedication(String name, String dosage, String time) async {
    final success = await _service.addMedication(name, dosage, time);
    if (success) {
      await loadMedications(); // Reload list to include new item
    }
    return success;
  }
}

final medicationProvider = StateNotifierProvider<MedicationNotifier, List<Medication>>((ref) {
  final service = ref.watch(medicationServiceProvider);
  final notifications = ref.watch(notificationServiceProvider);
  return MedicationNotifier(service, notifications);
});
