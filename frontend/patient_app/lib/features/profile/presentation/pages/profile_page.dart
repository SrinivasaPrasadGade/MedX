import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_app/main.dart'; // For authProvider

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 30),
          // User Header
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=John+Doe&background=007AFF&color=fff'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF007AFF), shape: BoxShape.circle),
                        child: const Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text("John Doe", style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text("Patient ID: #883920", style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          // Settings Group
          _SettingsGroup(
            title: "Account",
            children: [
              _SettingsTile(
                icon: Icons.person_outline, 
                title: "Personal Information", 
                onTap: () => context.go('/profile/personal-info'),
              ),
              _SettingsTile(
                icon: Icons.shield_outlined, 
                title: "Insurance Details", 
                onTap: () => context.go('/profile/insurance'),
                isLast: true,
              ),
            ],
          ),
          
           _SettingsGroup(
            title: "App Settings",
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined, 
                title: "Notifications", 
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notification settings updated")));
                }, 
                trailing: Switch.adaptive(value: true, onChanged: (_) {})
              ),
              _SettingsTile(
                icon: Icons.lock_outline, 
                title: "Privacy & Security", 
                onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Privacy Policy Opening...")));
                }, 
                isLast: true
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Sign Out"),
                  content: const Text("Are you sure you want to sign out?"),
                  actions: [
                    TextButton(onPressed: () => ctx.pop(), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () {
                        ctx.pop();
                        // Call logout on AuthNotifier
                        ref.read(authProvider.notifier).logout();
                        // Router redirect will handle navigation to /login automatically
                      }, 
                      child: const Text("Sign Out", style: TextStyle(color: Colors.red))
                    ),
                  ],
                )
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF3B30),
              backgroundColor: const Color(0xFFFF3B30).withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Sign Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;
  
  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93))),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isLast;

  const _SettingsTile({required this.icon, required this.title, required this.onTap, this.trailing, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: const Color(0xFF007AFF), size: 24),
          title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFC7C7CC)),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.only(left: 56),
            child: Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),
          ),
      ],
    );
  }
}
