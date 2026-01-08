import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_app/main.dart';

class ProfileDetailsPage extends StatelessWidget {
  final String title;
  final Widget content;

  const ProfileDetailsPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: content,
      ),
    );
  }
}

class PersonalInfoContent extends ConsumerWidget {
  const PersonalInfoContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final String fullName = user?['full_name'] ?? "N/A";
    final String dob = user?['date_of_birth'] ?? "N/A";
    final String gender = user?['gender'] ?? "N/A";
    final String phone = user?['phone'] ?? "N/A";
    final String email = user?['email'] ?? "N/A";
    final String address = user?['address'] ?? "N/A";

    return Column(
      children: [
        _InfoRow(label: "Full Name", value: fullName),
        _InfoRow(label: "Date of Birth", value: dob),
        _InfoRow(label: "Gender", value: gender),
        _InfoRow(label: "Phone", value: phone),
        _InfoRow(label: "Email", value: email),
        _InfoRow(label: "Address", value: address),
      ],
    );
  }
}

class InsuranceContent extends StatelessWidget {
  const InsuranceContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
               BoxShadow(color: const Color(0xFF007AFF).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6)),
            ]
          ),
          padding: const EdgeInsets.all(20),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text("BlueCross", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                   Icon(Icons.shield, color: Colors.white54),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("MEMBER ID", style: TextStyle(color: Colors.white70, fontSize: 10)),
                   Text("XYZ-883920-001", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("PLAN", style: TextStyle(color: Colors.white70, fontSize: 10)),
                   Text("Gold PPO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _InfoRow(label: "Provider", value: "BlueCross BlueShield"),
        _InfoRow(label: "Group Number", value: "GRP-998877"),
        _InfoRow(label: "Copay (PCP)", value: "\$25.00"),
        _InfoRow(label: "Copay (Specialist)", value: "\$50.00"),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
