import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Assuming these pages exist in your project
import 'home.dart';
import 'leaderboard.dart';
import 'qr.dart';
import 'profile.dart';

// --- SUPABASE INITIALIZATION (Using provided keys) ---
const String supabaseUrl = 'https://klwaqemvildisaisafpb.supabase.co';
const String supabaseAnonKey = 'sb_publishable_h08bBUGjoap1SQDzgAQ4TA_g4bi24L7';

// Placeholder: In a real app, this should be initialized in main.dart
Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
}
// --------------------------------------------------------------------------

// NEW CLASS: To return both success status and the username
class RedemptionResult {
  final bool isSuccess;
  final String? username;

  RedemptionResult(this.isSuccess, this.username);
}


class RewardsPage extends StatefulWidget { // 💡 FIX: Converted to StatefulWidget for double-tap protection
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  
  final Color primaryColor = const Color(0xFF0D47A1); // Dark blue
  final Color secondaryColor = const Color(0xFF42A5F5); // Light/Accent blue
  
  // 💡 FIX: State variable to prevent double-tapping the Redeem button
  bool _isProcessingRedemption = false; 

  // --- Supabase Transaction Function (FIXED TO USE TRIGGER) ---
  Future<RedemptionResult> _deductPoints(BuildContext context, int pointsToDeduct) async {
    final supabase = Supabase.instance.client;
    final User? user = supabase.auth.currentUser;

    if (user == null) {
      _showErrorSnackbar(context, 'Authentication required. Please log in to redeem rewards.');
      return RedemptionResult(false, null);
    }

    final String currentUserId = user.id;
    String? fetchedUsername;

    try {
      // 1. Fetch ONLY the username for the success message (No point checking/updating!)
      // This fetch is needed to personalize the success message later.
      final userResponse = await supabase
          .from('users')
          .select('name')
          .eq('id', currentUserId)
          .single();

      fetchedUsername = userResponse['name'] as String?;

      // 2. INITIATE REDEMPTION: Insert the record into 'redemptions' table.
      // The PostgreSQL TRIGGER will automatically:
      // a) Check the balance of the user.
      // b) If sufficient, deduct the points from the 'users' table.
      // c) If insufficient, raise an exception and abort this INSERT.
      await supabase.from('redeemptions').insert({
        'user_id': currentUserId,
        'name': fetchedUsername,
        'points_deducted': pointsToDeduct,
        'reward_description': 'Redeemed reward for $pointsToDeduct pts',
        'redeemed_at': DateTime.now().toIso8601String(),
      });

      return RedemptionResult(true, fetchedUsername); // Success with username
      
    } on PostgrestException catch (e) {
      // The database trigger will raise a PostgrestException if points are insufficient!
      debugPrint('Supabase Error: ${e.message}');
      
      String errorMessage = 'Failed to process redemption.';

      if (e.message.contains('Insufficient points')) {
        errorMessage = 'You do not have enough points for this reward.';
      } else {
        errorMessage = 'Database Error: ${e.message}';
      }

      _showErrorSnackbar(context, errorMessage);
      return RedemptionResult(false, null);
      
    } catch (e) {
      debugPrint('Redemption Error: $e');
      _showErrorSnackbar(context, 'An unexpected error occurred. Please try again.');
      return RedemptionResult(false, null);
    }
  }
  // ----------------------------------------------------------------------

  // --- Snackbar for Error Messages ---
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- NEW: Success Pop-up Dialog ---
  void _showSuccessDialog(BuildContext context, int redeemedPoints, String? username) {
    final welcomeText = username != null && username.isNotEmpty ? '$username,' : 'You';
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          icon: Icon(Icons.check_circle, color: primaryColor, size: 48),
          title: Text('Redemption Successful, $welcomeText!'),
          content: Text(
            'You successfully redeemed a reward for $redeemedPoints points. Your new reward is now available!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Great!'),
            ),
          ],
        );
      },
    );
  }

  // --- MODIFIED Modal Helper Function (Includes double-tap protection logic) ---
  void _showProcessingModal(BuildContext context, int points) {
    // 💡 FIX: Prevent double redemption clicks
    if (_isProcessingRedemption) {
      return; 
    }
    
    setState(() {
      _isProcessingRedemption = true;
    });

    // 1. Show the dialog with a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 20),
              Text(
                'Processing Redemption...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we process your $points pts reward.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );

    // 2. Call the Supabase function
    _deductPoints(context, points).then((result) {
      // 3. Close the loading modal dialog
      Navigator.pop(context);
      
      // 4. Reset the processing flag
      setState(() {
        _isProcessingRedemption = false;
      });

      // 5. Show the success dialog if the transaction worked
      if (result.isSuccess) {
        _showSuccessDialog(context, points, result.username); 
      }
    });
  }

  // --- Reward Item Widget (MODIFIED TO USE THE _isProcessingRedemption STATE) ---
  Widget _buildRewardItem({
    required BuildContext context,
    required int points,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder for the Reward Image/Icon
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Icon(Icons.star, size: 50, color: Colors.amber.shade700),
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Points and Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Points Cost
                Text(
                  '${points} pts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),

                // Redeem Now Button
                ElevatedButton(
                  // 💡 FIX: Disable button while processing
                  onPressed: _isProcessingRedemption ? null : () {
                    _showProcessingModal(context, points);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessingRedemption
                      ? const SizedBox(
                          width: 16, 
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, 
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
                          )
                        )
                      : const Text(
                          'Redeem Now',
                          style: TextStyle(fontSize: 14),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Bottom Navigation Bar Helpers (Rest of the code remains the same) ---
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = isActive ? primaryColor : Colors.grey.shade600;

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

  Widget _buildCustomBottomNavBar(BuildContext context) {
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
          _buildNavItem(icon: Icons.home, label: 'Home', isActive: false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          }),
          _buildNavItem(icon: Icons.leaderboard_outlined, label: 'Leaderboard', isActive: false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardPage()));
          }),
          _buildNavItem(icon: Icons.qr_code, label: 'QR Code', isActive: false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const QrCodePage()));
          }),
          _buildNavItem(icon: Icons.card_giftcard, label: 'Rewards', isActive: true, onTap: () { /* Stay on Rewards */ }),
          _buildNavItem(icon: Icons.person, label: 'Profile', isActive: false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for rewards list
    final List<Map<String, dynamic>> rewards = [
      {
        'points': 50,
        'description': 'The system utilizes its physical location as the primary learning resource by studying local environment and com...',
      },
      {
        'points': 100,
        'description': 'Redeem a voucher for a sustainable shopping experience at our partner stores, supporting local eco-friendly businesses.',
      },
      {
        'points': 250,
        'description': 'Claim a free membership to the EcoClan premium tier, unlocking advanced tracking and exclusive events.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 100,
        title: const Text(
          'Rewards Redemption',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select for redeemed rewards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Map the dummy data to the custom reward item widget
            ...rewards.map((reward) => _buildRewardItem(
              context: context, // Pass context to enable modal
              points: reward['points'] as int,
              description: reward['description'] as String,
            )).toList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(context),
    );
  }
}