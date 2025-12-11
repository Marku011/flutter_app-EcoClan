import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert'; // Required for base64 decoding

// Assuming these pages exist
import 'home.dart'; 
import 'profile.dart';
import 'reward.dart';
import 'leaderboard.dart';

// --- Supabase Client Initialization (Should be done once, e.g., in main.dart) ---
final supabase = Supabase.instance.client;
// ---------------------------------------------------------------------------------

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  String? _qrCodeBase64;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQrCodeData();
  }

  // Function to fetch QR code data from Supabase
  Future<void> _fetchQrCodeData() async {
    final users = supabase.auth.currentUser;

    if (users == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Please log in to view your QR Code.";
      });
      return;
    }

    try {
      // 1. Fetch the QR code record linked to the users_id
      final response = await supabase
          .from('qr_codes') // Use your table name
          .select('qr_code_base64')
          .eq('user_id', users.id)
          .maybeSingle();

      if (response != null && response['qr_code_base64'] != null) {
    setState(() {
        _qrCodeBase64 = response['qr_code_base64'] as String;
        _isLoading = false;
    });
} else {
    // Handles 0 rows
    setState(() {
        _isLoading = false;
        _errorMessage = "QR Code not found for this users.";
    });
}
    } on PostgrestException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Database Error: ${e.message}";
      });
      print('Supabase Error: ${e.message}');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An unexpected error occurred.";
      });
      print('General Error: $e');
    }
  }

  // Function to build a standard navigation tab (no changes)
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap, 
  }) {
    // ... (Your original _buildNavItem implementation)
    final color = isActive ? const Color(0xFF0D47A1) : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
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

  // Helper widget for the custom bottom navigation bar (no changes)
  Widget _buildCustomBottomNavBar(BuildContext context) {
    // ... (Your original _buildCustomBottomNavBar implementation)
    return Container(
      height: 80, // Height to accommodate the size and padding
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
          // Home
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
          // Leaderboard
          _buildNavItem(
            icon: Icons.leaderboard_outlined,
            label: 'Leaderboard',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardPage(),
                ),
              );
            },
          ),
          // Central Scan Button (Active)
          _buildNavItem(
            icon: Icons.qr_code,
            label: 'QR Code',
            isActive: true,
            onTap: () {
              print('Currently on QR Code Page');
            },
          ),
          // Rewards
          _buildNavItem(
            icon: Icons.card_giftcard,
            label: 'Rewards',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RewardsPage(),
                ),
              );
            },
          ),
          // Profile
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget to display the actual QR Code image or a loading state
  Widget _buildQrCodeDisplay() {
    Widget content;
    
    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      content = Center(
        child: Text(
          _errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (_qrCodeBase64 != null) {
      // Decode the Base64 string into a byte array
      try {
        // Remove the data URI header if present (e.g., "data:image/png;base64,")
        final base64String = _qrCodeBase64!.split(',').last;
        final imageBytes = base64Decode(base64String);
        content = Image.memory(
          imageBytes,
          fit: BoxFit.contain,
          // Constrain the size to the placeholder size
          width: 250, 
          height: 250,
        );
      } catch (e) {
        content = const Center(child: Text('Error decoding QR Code image.', style: TextStyle(color: Colors.red)));
        print('Base64 Decoding Error: $e');
      }
    } else {
      content = const Center(child: Text('No QR Code available.'));
    }

    // Wrap the content in the styled container
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine users details based on the authenticated Supabase users
    final users = supabase.auth.currentUser;
    final usersEmail = users?.email ?? 'Not Available';
    final usersUid = users?.id ?? '***************';
    
    // Simple masking for the users ID and Phone No.
    final maskedMobileNo = '0919 334 ****'; 
    final maskedusersId = '${usersUid.substring(0, 8)}************${usersUid.substring(usersUid.length - 4)}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        toolbarHeight: 100,
        title: const Text(
          'QR Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
        child: Center(
          child: Column(
            children: <Widget>[
              // --- QR Code Card (Now handles loading/display) ---
              _buildQrCodeDisplay(),

              const SizedBox(height: 40),

              // --- users Name (Placeholder, typically fetched from a 'profiles' table) ---
              Text(
                // Use email or a fetched name. Using email as a proxy for now.
                usersEmail, 
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // --- Mobile No. (Masked) ---
              Text(
                'Mobile No.: $maskedMobileNo',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              // --- users ID (Masked, using actual UID if available) ---
              Text(
                'Users ID: $maskedusersId',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
      // --- Bottom Navigation Bar ---
      bottomNavigationBar: _buildCustomBottomNavBar(context),
    );
  }
}