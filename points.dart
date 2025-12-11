import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home.dart';
import 'notif.dart';
import 'reward.dart'; // Corrected import to 'rewards.dart'

// Initialize Supabase client
final supabase = Supabase.instance.client;

// Data model for transaction history
class Transaction {
  final String title;
  final String date;
  final int pointsChange; // Positive for addition (Blue), Negative for deduction (Red)

  Transaction({required this.title, required this.date, required this.pointsChange});
}

class PointsPage extends StatefulWidget {
  const PointsPage({super.key});

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  int _totalPoints = 0;
  List<Transaction> _transactionHistory = [];
  bool _isLoading = true;

  final Color primaryColor = const Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _fetchPointsData();
  }

  // --- Supabase Data Fetching ---
  Future<void> _fetchPointsData() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final String userId = user.id;
    List<Transaction> historyList = [];

    try {
      // 1. Fetch Total Points from the 'users' table
      final pointsResponse = await supabase
          .from('users')
          .select('points') // Assuming 'points' is the column name
          .eq('id', userId)
          .single();
      
      // 2. Fetch REDEMPTION History (Deductions -> NEGATIVE points)
      final redemptionResponse = await supabase
          .from('redeemptions') 
          .select('points_deducted, created_at')
          .eq('user_id', userId);

      for (var item in redemptionResponse) {
        final String? dateString = item['created_at'] as String?;
        final int deductedPoints = (item['points_deducted'] as int?) ?? 0;
        
        // FIX: Use tryParse for robust date handling
        DateTime? date = dateString != null ? DateTime.tryParse(dateString) : null;
        
        if (date != null && deductedPoints > 0) {
          final String formattedDate = '${_getDayOfWeek(date.weekday)}, ${_getMonthName(date.month)} ${date.day}, ${date.year}';
          
          historyList.add(Transaction(
            title: 'Redeem Rewards', 
            date: formattedDate,
            pointsChange: -deductedPoints, // NEGATE FOR RED COLOR (DEDUCTION)
          ));
        }
      }
      
      // 3. Fetch AWARD History (Additions -> POSITIVE points)
      final awardResponse = await supabase
          .from('waste_records') 
          .select('points_awarded, created_at')
          .eq('user_id', userId);

      // FIX: Iterate over the correct response (awardResponse) and use correct column names (points_awarded)
      for (var item in awardResponse) {
        final String? dateString = item['created_at'] as String?;
        final int awardedPoints = (item['points_awarded'] as int?) ?? 0;

        // FIX: Use tryParse for robust date handling
        DateTime? date = dateString != null ? DateTime.tryParse(dateString) : null;
        
        if (date != null && awardedPoints > 0) {
          final String formattedDate = '${_getDayOfWeek(date.weekday)}, ${_getMonthName(date.month)} ${date.day}, ${date.year}';
          
          historyList.add(Transaction(
            title: 'Deposited Waste', 
            date: formattedDate,
            pointsChange: awardedPoints, // POSITIVE FOR BLUE COLOR (AWARD)
          ));
        }
      }
      // END OF FIX

      // Sort all transactions by date, showing the 5 most recent
      // NOTE: Using tryParse on the original string inside the comparator for accurate sorting
      historyList.sort((a, b) {
        final dateA = DateTime.tryParse(a.date.split(', ')[1].trim()) ?? DateTime(1900);
        final dateB = DateTime.tryParse(b.date.split(', ')[1].trim()) ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
      final recentHistory = historyList.take(5).toList();


      setState(() {
        _totalPoints = pointsResponse['points'] as int? ?? 0;
        _transactionHistory = recentHistory;
        _isLoading = false;
      });
      
    } on PostgrestException catch (e) {
      debugPrint('Supabase Error: ${e.message}');
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred while loading history.')),
        );
      }
    }
  }
  
  // --- Date Formatting Helpers (Unchanged) ---
  String _getDayOfWeek(int day) {
    switch(day) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  String _getMonthName(int month) {
    switch(month) {
      case 1: return 'January';
      case 2: return 'February';
      case 3: return 'March';
      case 4: return 'April';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'August';
      case 9: return 'September';
      case 10: return 'October';
      case 11: return 'November';
      case 12: return 'December';
      default: return '';
    }
  }
  // ------------------------------------------


  // Helper widget to build individual history items (DYNAMIC)
  Widget _buildHistoryItem({
    required String title,
    required String date,
    required int pointsChange,
  }) {
    // Determine color and sign based on pointsChange value (Positive vs Negative)
    final bool isPositive = pointsChange >= 0;
    final String pointsText = isPositive 
        ? '+ ${pointsChange.abs()}' 
        : '- ${pointsChange.abs()}';

    final Color pointsColor = isPositive 
        ? const Color(0xFF0D47A1) // Blue for positive/award
        : Colors.red.shade700;   // Red for negative/redemption

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Text(
            pointsText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: pointsColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget for the elevated "Your Points" card (DYNAMIC - Unchanged)
  Widget _buildPointsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Your Points" Label
          const Text(
            'Your Points',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),

          // Total Points (DYNAMIC)
          Text(
            _totalPoints.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Dashed Divider
          LayoutBuilder(
            builder: (context, constraints) {
              final double dashWidth = 5.0;
              final double dashSpace = 5.0;
              final int dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
              return Flex(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                direction: Axis.horizontal,
                children: List.generate(dashCount, (_) {
                  return SizedBox(
                    width: dashWidth,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.grey.shade400),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 20),

          // Redeem Rewards Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RewardsPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Redeem Rewards',
                style: TextStyle(fontSize: 16),
              ),
            ),
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
          'Points',
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
              color: Colors.white.withOpacity(0.2), // Use white opacity
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                // Navigate back to HomeScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background filler
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(color: primaryColor),
          ),

          // Loading Indicator
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          // Content Scroll View
          if (!_isLoading)
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 250, left: 24, right: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Transactions', 
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // --- Redemption History List (DYNAMIC) ---
                  ..._transactionHistory.map((item) => _buildHistoryItem(
                        title: item.title,
                        date: item.date,
                        pointsChange: item.pointsChange,
                      )).toList(),

                  const Divider(height: 1, color: Colors.grey),
                  const SizedBox(height: 24),

                  // --- See All Button ---
                  Center(
                    child: OutlinedButton(
                      onPressed: () {
                        // Placeholder navigation for "See All"
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const NotifPage(),
                        //   ),
                        // );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                        minimumSize: const Size(150, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('See All', style: TextStyle(fontSize: 16)),
                          Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

          // --- Floating Points Card (Elevated via Stack) ---
          Positioned(
            top: 20,
            left: 24,
            right: 24,
            child: _buildPointsCard(context),
          ),
        ],
      ),
    );
  }
}