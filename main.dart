import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/splash.dart'; // Import the separated Splash Screen
import 'screens/welcome.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://klwaqemvildisaisafpb.supabase.co',
    anonKey: 'sb_publishable_h08bBUGjoap1SQDzgAQ4TA_g4bi24L7',
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoClan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Define routes for easy navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(), // Initial screen with delay
        '/welcome': (context) =>
            const WelcomeScreen(), // The screen with buttons
      },
      debugShowCheckedModeBanner: false,
    );
  }
}