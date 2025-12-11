import 'package:flutter/material.dart';
// Supabase imports replace Firebase imports
import 'package:supabase_flutter/supabase_flutter.dart';


import 'profile.dart'; // Placeholder
import 'notif.dart'; // Placeholder
import 'reward.dart'; // Placeholder
import 'leaderboard.dart'; // Placeholder
import 'history.dart'; // Placeholder
import 'points.dart'; // Placeholder
import 'qr.dart'; // Placeholder
import 'tips.dart';
// --- Global Supabase Client Access ---
// Assumes the client is initialized in main.dart and available globally
final supabase = Supabase.instance.client;

// Navigation Imports (assuming these are simple placeholder pages)
 // Placeholder


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables for dynamic data
  String _userName = 'Loading...';
  String _userPoints = '0';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ----------------------------------------
  // ⭐ SUPABASE FUNCTION TO LOAD USER DATA
  // ----------------------------------------
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // 1. Get the current authenticated user
    final users = supabase.auth.currentUser;

    if (users != null) {
      try {
        // 2. Query the 'users' (profiles) table for the current user's data
        final response = await supabase
            .from('users')
            .select('name, points') // Select only the needed columns
            .eq('id', users.id)      // Filter by the user's authentication ID
            .maybeSingle();         // Use maybeSingle to get null if no row found

        if (response != null) {
          // The response is a Map<String, dynamic>
          final data = response as Map<String, dynamic>; 
          
          // 3. Set User Name
          _userName = data['name'] ?? 'EcoClan User';

          // 4. Set User Points
          final points = data['points'];
          if (points != null) {
            // Note: PostgreSQL integer/float is retrieved here
            _userPoints = points.toString();
          } else {
            // If the points field doesn't exist, initialize it to 0 in the database
            _userPoints = '0';
            
            // Initialize points in Supabase for a new user using UPDATE
            await supabase
                .from('users')
                .update({'points': 0})
                .eq('id', users.id);
          }
        } else {
          // Case: User exists in Auth but no profile row in 'users' table
          _userName = 'Profile Missing';
          _userPoints = '0';
        }

      } on PostgrestException catch (e) {
        // Handle database specific errors
        print('Supabase Database Error: ${e.message}');
        _userName = 'Error Loading';
        _userPoints = '0';
      } catch (e) {
        // Handle general errors
        print('Error fetching user data: $e');
        _userName = 'Error Loading';
        _userPoints = '0';
      }
    } else {
      // User is not logged in (should be handled by AuthGuard in main.dart)
      _userName = 'Guest';
      _userPoints = '0';
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Helper function to build each tip item
  Widget _buildTipItem(
      BuildContext context,
      {required String title,
      required String description}) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const TipsPage(),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for the image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.lightbulb_outline, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // 1. Header Section (Pass dynamic data)
            _HeaderSection(userName: _userName, isLoading: _isLoading),
            
            // 2. Points Card Section (Pass dynamic data)
            _PointsCard(userPoints: _userPoints, isLoading: _isLoading),
            
            // 3. Educational Tips Section
            Padding(
              // Adjusted top padding to clear the card and header
              padding: const EdgeInsets.only(top: 365.0, left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TipsHeader(),
                  const SizedBox(height: 16),
                  _buildTipItem(context, title: 'Recycle Right', description: 'Always rinse containers before recycling them to avoid contaminating other materials.'),
                  _buildTipItem(context, title: 'Compost Basics', description: 'Start a compost bin for food scraps and yard waste to enrich your soil naturally.'),
                  _buildTipItem(context, title: 'Save Water at Home', description: 'Turn off the tap while brushing your teeth and take shorter showers.'),
                  _buildTipItem(context, title: 'Choose Reusable Bags', description: 'Keep reusable shopping bags in your car or purse so you never need a plastic one.'),
                  _buildTipItem(context, title: 'Energy Efficiency', description: 'Unplug electronics and appliances when they are not in use to reduce "phantom load".'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _CustomBottomNavBar(),
    );
  }
}

// --- 1. Header Section Widget ---
class _HeaderSection extends StatelessWidget {
  final String userName;
  final bool isLoading;
  const _HeaderSection({required this.userName, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D47A1), // A deep, dark blue
            Color(0xFF1565C0),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 100), // Increased top padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hello',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              // Dynamic Name Display
              isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
          // Notification Bell
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.white, size: 24),
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const NotifPage(),
                //   ),
                // );
              },
            ),
            
          ),
        ],
      ),
    );
  }
}

// --- 2. Points Card Widget ---
class _PointsCard extends StatelessWidget {
  final String userPoints;
  final bool isLoading;
  const _PointsCard({required this.userPoints, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    // Determine the space needed above the card
    return Container(
      margin: const EdgeInsets.only(top: 150, left: 16, right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5), // Added vertical offset for better depth
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Points',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          // Dynamic Points Display
          isLoading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  userPoints,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
          const SizedBox(height: 8),
          const Text(
            'Keep up the great work!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          // Redeem/History Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Points Redeem Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PointsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    )
                  ),
                  child: const Text('Points Redeem',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  ),
                  
                ),
              ),
              const SizedBox(width: 10),
              // History Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const HistoryPage(),
                    //   ),
                    // );
                  },
                  
                  
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF0D47A1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    )
                  ),
                  child: const Text('History', 
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// --- 3. Educational Tips Header Widget ---
class _TipsHeader extends StatelessWidget {
  const _TipsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Educational Tips',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {
            // Navigator.push(
            //           context,
            //           MaterialPageRoute(
            //             builder: (context) => const TipsPage(),
            //           ),
            //         );
          },
          child: const Text(
            'See All',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

// --- Custom Bottom Navigation Bar Widget ---
class _CustomBottomNavBar extends StatelessWidget {
  const _CustomBottomNavBar();

  @override
  Widget build(BuildContext context) {
    // Note: Since this is a home screen, the Home icon is always active (true).
    // In a full application, you would manage the 'activeIndex' through state 
    // in a parent widget (like a main scaffold).
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home (Active)
          _buildNavItem(
            context,
            icon: Icons.home,
            label: 'Home',
            isActive: true,
            onTap: () {},
          ),
          // Leaderboard
          _buildNavItem(
            context,
            icon: Icons.leaderboard_outlined,
            label: 'Leaderboard',
            isActive: false,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardPage()));
            },
          ),
          // Central Scan Button
          _buildNavItem(
            context,
            icon: Icons.qr_code,
            label: 'Scan', // Changed label to Scan for QR Page
            isActive: false,
            onTap: () {
              Navigator.push(context, 
                MaterialPageRoute(
                  builder: (context) => const QrCodePage()));
            },
          ),
          // Rewards
          _buildNavItem(
            context,
            icon: Icons.card_giftcard,
            label: 'Rewards',
            isActive: false,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RewardsPage()));
            },
          ),
          // Profile
          _buildNavItem(
            context,
            icon: Icons.person_outline,
            label: 'Profile',
            isActive: false,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            },
          ),
        ],
      ),
    );
  }

  // Helper for standard navigation items
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? const Color(0xFF0D47A1) : Colors.grey[600]!;
    // Note: The original code had a confusing logic: 
    // final iconData = isActive ? Icons.home : icon; 
    // which caused all active items to show 'Icons.home'. 
    // We stick to the passed 'icon' unless you explicitly want to change it.
    final iconData = icon;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}