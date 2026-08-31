import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Firebase has to finish starting before runApp, and that needs the
  // Flutter engine to be ready first.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RestaurantReviewApp());
}

class RestaurantReviewApp extends StatelessWidget {
  const RestaurantReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Colombo Eats',
      debugShowCheckedModeBanner: false,

      // themeMode.system makes Flutter read the phone's own light/dark
      // setting and pick the matching theme automatically. Change the
      // device theme and the app follows without any code running.
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,

      home: const AuthGate(),
    );
  }
}

/// Decides whether to show the login screen or the app itself.
///
/// This is the route protection: MainScreen and everything reachable from
/// it can only be built when authChanges() has produced a signed-in user.
/// Signing out pushes null down the stream and this rebuilds to the login
/// screen on its own, with no navigation code anywhere else in the app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authChanges(),
      builder: (context, snapshot) {
        // Firebase is still checking whether a session was saved from a
        // previous run.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        return const MainScreen();
      },
    );
  }
}
