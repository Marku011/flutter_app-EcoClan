import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile.dart'; // Assuming this is the ProfilePage for navigation
import 'edit.dart'; // Assuming this is EditProfilePage for navigation

// Initialize Supabase client
final supabase = Supabase.instance.client;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State variables for user data
  String? userName;
  String? userEmail;
  String? userPhone;
  // REMOVED: String? userDOB;
  String? userAddress;
  String? userId;
  bool _isLoading = true;

  final Color primaryColor = const Color(0xFF0D47A1); // Dark blue

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // --- Supabase Data Fetching ---
  Future<void> _fetchProfileData() async {
    final user = supabase.auth.currentUser;

    if (user != null) {
      try {
        final response = await supabase
            .from('users')
            // MODIFIED: Removed 'dob' from the select query
            .select('name, phone, address') 
            .eq('id', user.id)
            .single();

        setState(() {
          userName = response['name'] as String?;
          userEmail = user.email; // Email comes from the auth object
          userPhone = response['phone'] as String?;
          // REMOVED: userDOB = response['dob'] as String?;
          userAddress = response['address'] as String?;
          userId = user.id;
          _isLoading = false;
        });
      } on PostgrestException catch (e) {
        debugPrint('Supabase Profile Fetch Error: ${e.message}');
        setState(() {
          userEmail = user.email;
          userId = user.id;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading profile: ${e.message}')),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- Supabase Delete Account Function ---
  Future<void> _deleteAccount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Step 1: Delete the profile data from the public 'users' table
      await supabase.from('users').delete().eq('id', user.id);

      // Step 2: Sign out
      await supabase.auth.signOut();

      if (mounted) {
        // Navigate to the Profile Page or Login Page after deletion/sign out
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const ProfilePage()), 
          (Route<dynamic> route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account successfully deleted.')),
        );
      }
    } on PostgrestException catch (e) {
      debugPrint('Delete Error: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deletion failed: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('Unexpected Delete Error: $e');
    }
  }


  // --- Helper widget to build individual personal info rows ---
  Widget _buildPersonalInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            alignment: Alignment.centerLeft,
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- DELETE ACCOUNT Confirmation Modal ---
  void _showDeleteConfirmationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you absolutely sure you want to delete your account? This action is irreversible.',
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
            // Delete Button (Confirms action)
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
                _deleteAccount(); // <-- CALL SUPABASE DELETE
              },
              child: Text('Delete', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- Widget to build the floating user info card (DYNAMIC) ---
  Widget _buildProfileCard(BuildContext context) {
    // Determine the first letter for the avatar
    final String initial = (userName != null && userName!.isNotEmpty) 
        ? userName![0].toUpperCase() 
        : '?'; 

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- Profile Image (First Letter Avatar) ---
          CircleAvatar(
            radius: 50,
            backgroundColor: primaryColor, // Blue background
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 12),

          // --- User Info Text ---
          Text(
            userName ?? 'Name Not Set',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail ?? 'No Email',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: Colors.blue.shade700,
            ),
          ),
          Text(
            'User ID: ${userId ?? 'N/A'}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),

          // --- Personal Info Section Title ---
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Personal Info',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 24, thickness: 1, color: Colors.grey),

          // --- Personal Info Details (DYNAMIC) ---
          _buildPersonalInfoRow(
            icon: Icons.phone_outlined,
            title: 'Phone No.',
            value: userPhone ?? 'Not available',
          ),
          // REMOVED: Date of Birth Row
          
          _buildPersonalInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Address',
            value: userAddress ?? 'Not available',
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
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 100,
        title: const Text(
          'Profile Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2), // Use opacity for a slight effect
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
              child: Column(
                children: [
                  _buildProfileCard(context),
                  const SizedBox(height: 30),

                  // --- Edit Profile Button ---
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      ).then((_) {
                        // Refresh data when returning from EditProfilePage
                        _fetchProfileData(); 
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A), 
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- DELETE Account Button ---
                  ElevatedButton(
                    onPressed: () {
                      _showDeleteConfirmationModal(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700, // Red background
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}