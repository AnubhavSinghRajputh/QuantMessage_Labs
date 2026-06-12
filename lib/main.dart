import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your screens
import 'screens/splash_screen.dart';
import 'screens/auth_guard.dart';
import 'screens/home_screen.dart'; // <--- ADDED IMPORT for the route

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://dmgwkgadhnpjnnjklnqh.supabase.co',
      publishableKey: 'sb_publishable_Lspy0F1ek5gInIYOkY087A_IGPG3Xkg',
    );
    debugPrint("Supabase initialized successfully.");
  } catch (e) {
    debugPrint("Error initializing Supabase: $e");
  }

  runApp(const QuantMessageApp());
}

class QuantMessageApp extends StatelessWidget {
  const QuantMessageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuantMessage',
      debugShowCheckedModeBanner: false,

      // --- PREMIUM THEME CONFIGURATION ---
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070709),
        useMaterial3: true,
        primaryColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
      ),

      /*
        1. INITIAL START:
        The app starts at the SplashScreen.
        The SplashScreen then handles the transition to the AuthGuard.
      */
      home: const SplashScreen(),

      /*
        2. NAMED ROUTES:
        This is where we define the "addresses" of our pages.
        The CongratsPage calls '/home' to redirect the user after success.
      */
      routes: {
        '/home': (context) => const HomeScreen(),
        // If you have a specific Dashboard page, add it here:
        // '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

/// Global Supabase client shortcut.
SupabaseClient get supabase => Supabase.instance.client;
