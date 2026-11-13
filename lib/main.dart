import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'models/somiti_model.dart';
import 'services/auth_service.dart';
import 'services/somiti_service.dart';
import 'services/feature_management_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/pending_approval_screen.dart';
import 'features/society/onboarding_screen.dart';
import 'features/society/somiti_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FeatureManagementService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }
  runApp(const SomitiApp());
}

class SomitiApp extends StatelessWidget {
  const SomitiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'স্মার্ট সমিতি প্ল্যাটফর্ম',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final somitiService = SomitiService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user != null) {
          return StreamBuilder<List<SomitiModel>>(
            stream: somitiService.getUserSomitisStream(user.email ?? '', user.uid),
            builder: (context, somitiSnapshot) {
              if (somitiSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final somitis = somitiSnapshot.data ?? [];
              final userEmail = (user.email ?? '').toLowerCase().trim();
              final isSuperAdmin = userEmail == 'hossansajjad1994@gmail.com';
              if (somitis.isEmpty) {
                if (isSuperAdmin) {
                  return OnboardingScreen(user: user);
                }
                return PendingApprovalScreen(user: user);
              }

              return SomitiListScreen(user: user, somitis: somitis);
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
