import 'package:flutter/material.dart';

import 'welcome.dart';
import 'welcome2.dart';

class Welcome1Screen extends StatelessWidget {
  const Welcome1Screen({super.key});

  // Define custom colors based on the design
  static const Color welcomeBackgroundBlue = Color(0xFF0D47A1);
  static const Color loginButtonGreen = Color(0xFF4CAF50);
  static const Color registerButtonBlue =
      Color(0xFF1E88E5); // A darker blue for register

Widget _buildProgressDot(bool isActive) {
    return Container(
      width: isActive ? 140 : 140, // Make active dot slightly longer
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: isActive ? const Color(0xFF0D47A1) : Colors.grey[300],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. PROGRESS INDICATOR
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildProgressDot(false),  // Active (Green)
                  _buildProgressDot(true), // Inactive (Gray)
                  _buildProgressDot(false), // Inactive (Gray)
                ],
              ),
              const SizedBox(height: 32),

              // 2. IMAGE SECTION (Using a placeholder for the provided image)
              Expanded(
                child: Center(
                  child: Container(
                    clipBehavior: Clip.antiAlias, // Clip for rounded corners on the image
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image(
                      // Placeholder image URL for 'family cleaning up trash'
                      image: AssetImage('images/wel.png'),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 200, color: Colors.grey),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 3. TITLE
              const Text(
                'Easy Waste Disposal',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 4. DESCRIPTION TEXT
              const Text(
                'Request a awste pickup from your home or drop off your waste directly at the nearest collection point.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 64),

              // 5. NEXT BUTTON
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement navigation logic here
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                        );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 16),
                      backgroundColor: Colors.white, // Blue color from design
                      
                      
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Previous',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement navigation logic here
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Welcome2Screen(),
                          ),
                        );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                     backgroundColor: const Color(0xFF0D47A1), // Blue color from design
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Next',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
            ],

          ),
        ),
      ),
    );
  }
}