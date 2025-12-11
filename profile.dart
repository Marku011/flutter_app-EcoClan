import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

import 'home.dart';
import 'package:EcoClan/screen/setting.dart';
import 'notif.dart';
import 'edit.dart';
import 'reward.dart';
import 'leaderboard.dart';
import 'qr.dart';
import 'package:EcoClan/pages/login.dart';

// Initialize Supabase client once
final supabase = Supabase.instance.client;

// Changed to StatefulWidget to manage user data fetching
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Store fetched user data
  String? userName;
  String? userEmail;
  String? userId;
  bool _isLoading = true;
  final Color primaryColor = const Color(0xFF0D47A1); // Define primary color here

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- Supabase Data Fetching ---
  Future<void> _fetchUserData() async {
    // 1. Get the current user session from Supabase Auth
    final user = supabase.auth.currentUser;

    if (user != null) {
      // 2. Fetch additional profile data from the public 'users' table
      try {
        final response = await supabase
            .from('users')
            // Fetch the 'name' column based on the Supabase Auth ID
            .select('name') 
            .eq('id', user.id)
            .single(); // Use single() since each auth user maps to one public user

        setState(() {
          // Update state with data from Supabase Auth and public table
          userName = response['name'] as String?;
          userEmail = user.email;
          userId = user.id;
          _isLoading = false;
        });
      } on PostgrestException catch (e) {
        debugPrint('Supabase Profile Fetch Error: ${e.message}');
        // Fallback for user data
        setState(() {
          userEmail = user.email;
          userId = user.id;
          _isLoading = false;
        });
      }
    } else {
      // Handle case where user is not logged in
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Supabase Logout Function ---
  Future<void> _signOut() async {
    try {
      // Call Supabase sign out method
      await supabase.auth.signOut();
      
      // Navigate to the Login Page and remove all previous routes
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } on AuthException catch (e) {
      debugPrint('Supabase Sign Out Error: ${e.message}');
      // Optional: Show error dialog to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.message}')),
      );
    }
  }

  // --- Updated Modal Function ---
  void _showLogoutConfirmationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text(
            'Are you sure you want to log out of your account?',
            style: TextStyle(color: Colors.black87),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: <Widget>[
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF0D47A1))),
            ),
            // Logout Button (Confirms action)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
                _signOut(); // <-- CALL SUPABASE LOGOUT
              },
              child: Text('Logout', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Helper widget for the action list tiles (Same as original)
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon with custom color
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              // Title text
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              // Trailing arrow icon
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build a standard navigation tab (Same as original)
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap, 
  }) {
    final color = isActive ? primaryColor : Colors.grey[600]!;
    final iconData = isActive ? Icons.person : icon;

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

  // Helper widget for the custom bottom navigation bar (Same as original)
  Widget _buildCustomBottomNavBar(BuildContext context) {
    // ... (Navigation logic remains the same)
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
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.leaderboard_outlined,
            label: 'Leaderboard',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardPage()),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.qr_code,
            label: 'QR Code',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrCodePage()),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.card_giftcard,
            label: 'Rewards',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RewardsPage()),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            isActive: true,
            onTap: () {
              // Stay on Profile
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 100,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 150, left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 50),
                      const Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // --- Action Tiles (Logout calls the modal) ---
                      _buildActionTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        iconColor: Colors.black,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                      _buildActionTile(
                        icon: Icons.notifications_none,
                        title: 'Notification',
                        iconColor: Colors.black,
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const NotifPage(),
                          //   ),
                          // );
                        },
                      ),
                      _buildActionTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        iconColor: Colors.red.shade700,
                        onTap: () {
                          _showLogoutConfirmationModal(context); 
                        },
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),

                // --- Floating Profile Card ---
                Positioned(
                  top: 70,
                  left: 24,
                  right: 24,
                  child: _buildProfileHeaderCard(context),
                ),
              ],
            ),
      bottomNavigationBar: _buildCustomBottomNavBar(context),
    );
  }

  // Widget to build the floating user info card (MODIFIED)
  Widget _buildProfileHeaderCard(BuildContext context) {
    // Determine the first letter for the avatar
    final String initial = (userName != null && userName!.isNotEmpty) 
        ? userName![0].toUpperCase() 
        : '?'; // Fallback initial if name is null or empty

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Letter Avatar (FIXED)
          CircleAvatar(
            radius: 35, // Adjusted size to match the original container size (70/2)
            backgroundColor: primaryColor, // Blue background
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Info (NOW USES FETCHED DATA)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName ?? 'Loading Name...', // Use fetched name, or placeholder
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail ?? 'Not Logged In', // Use fetched email
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'User ID: ${userId ?? 'Unknown'}', // Use fetched ID
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          // Settings Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade700,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 24),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}