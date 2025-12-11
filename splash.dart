import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // The primary dark blue background color from Logo.png
  static const Color primaryDarkBlue = Color(0xFF003399);

  @override
  void initState() {
    super.initState();
    // Start a timer for 5 seconds
    Timer(const Duration(seconds: 5), () {
      // After 5 seconds, navigate to the WelcomeScreen and replace the current route
      Navigator.of(context).pushReplacementNamed('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // Set the background color to match Logo.png's dark blue
      backgroundColor: primaryDarkBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display the bucket/QR code logo (Logo.png)
            // Ensure 'assets/Logo.png' is correct for your project structure
            Image(
              image: AssetImage('images/logo1.png'),
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              'EcoClan',
              style: TextStyle(
                fontFamily: 'Poppins',
                letterSpacing: 2.0,
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}