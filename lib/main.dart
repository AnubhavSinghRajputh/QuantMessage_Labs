import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your screens
import 'screens/splash_screen.dart';
import 'screens/auth_guard.dart';
import 'screens/home_screen.dart';

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
        The app starts at the SplashScreen.
        SplashScreen handles the transition to AuthGuard / HomeScreen.
      */
      home: const SplashScreen(),

      routes: {
        '/home': (context) => const HomeScreen(),
        // Add other routes as needed:
        // '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

/// Global Supabase client shortcut.
SupabaseClient get supabase => Supabase.instance.client;
