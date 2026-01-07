import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:patient_app/core/theme/app_theme.dart';
import 'package:patient_app/features/dashboard/presentation/pages/home_page.dart';
import 'package:patient_app/core/services/auth_service.dart'; // Moved here

import 'package:patient_app/features/profile/presentation/pages/profile_page.dart';
import 'package:patient_app/features/profile/presentation/pages/profile_details_page.dart';
import 'package:patient_app/features/auth/presentation/pages/login_page.dart';
import 'package:patient_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:patient_app/features/documents/presentation/pages/upload_page.dart';


import 'package:patient_app/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MedXApp(),
    ),
  );
}

// Auth State with Service Integration
// Auth State with Service Integration
class AuthNotifier extends StateNotifier<bool> {
  final AuthService _authService;
  
  AuthNotifier(this._authService) : super(false) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final isLoggedIn = await _authService.checkAuth();
    state = isLoggedIn;
  }

  Future<void> login(String email, String password) async {
    final success = await _authService.login(email, password);
    if (success) {
      state = true;
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    final success = await _authService.register(email, password, fullName);
    if (success) {
      state = true;
    }
  }

  void logout() {
    _authService.logout();
    state = false;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
final welcomeMessageProvider = StateProvider<String?>((ref) => null);

class MedXApp extends ConsumerWidget {
  const MedXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    final router = GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final onLoginPage = state.uri.toString() == '/login' || state.uri.toString() == '/signup';
        
        // If not logged in and not on login/signup page, go to login
        if (!isLoggedIn && !onLoginPage) return '/login';

        // If logged in and trying to access login page, go to home
        if (isLoggedIn && onLoginPage) return '/home';

        return null; // No redirect needed
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/documents',
          builder: (context, state) => const UploadPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
          routes: [
             GoRoute(
              path: 'personal-info',
              builder: (context, state) => const ProfileDetailsPage(
                title: "Personal Information",
                content: PersonalInfoContent(),
              ),
            ),
             GoRoute(
              path: 'insurance',
              builder: (context, state) => const ProfileDetailsPage(
                title: "Insurance Details",
                content: InsuranceContent(),
              ),
            ),
          ]
        ),
      ],
    );

    return MaterialApp.router(
      title: 'MedX Patient',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
