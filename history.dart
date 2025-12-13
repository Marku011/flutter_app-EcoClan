import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
// Import the new details page

// Imports for other pages (mocked or real)
import 'home.dart';
import 'leaderboard.dart';
import 'qr.dart';
import 'reward.dart';
import 'profile.dart';


// --- Supabase Data Model ---

class Transaction {
  final String description;
  final String type; // 'deposit' or 'redemption'
  final int amount; // Points
  final DateTime dateTime; // Actual DateTime object from the database
  final String? wasteType; // Available only for 'deposit'
  final double? weight; // Available only for 'deposit', in grams
  final String? userName; // User name (optional, if fetched)

  Transaction({
    required this.description,
    required this.type,
    required this.amount,
    required this.dateTime,
    this.wasteType,
    this.weight,
    this.userName,
  });

  // Factory for Waste Deposit (from 'waste_records' table)
  factory Transaction.fromWasteRecord(Map<String, dynamic> data) {
    // Note: Assuming 'points_earned' and 'created_at' exist in waste_records
    return Transaction(
      description: 'Waste Deposit',
      type: 'deposit',
      amount: data['points_awarded'] as int,
      dateTime: DateTime.parse(data['created_at'] as String),
      wasteType: data['waste_type'] as String?, 
      weight: data['weight'] as double?, 
      // Assuming user data is nested if joined, otherwise ignore/pass null
      userName: data['name'] as String?, 
    );
  }

  // Factory for Redemption (from 'redemptions' table)
  factory Transaction.fromRedemption(Map<String, dynamic> data) {
    // Note: Assuming 'points_deducted' and 'redeemed_at' exist in redemptions
    return Transaction(
      description: data['reward_description'] as String,
      type: 'redemption',
      amount: data['points_deducted'] as int,
      dateTime: DateTime.parse(data['redeemed_at'] as String),
      wasteType: null,
      weight: null,
      userName: data['name'] as String?, 
    );
  }
}

// --- History Page (Stateful Widget) ---

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Color primaryColor = const Color(0xFF0D47A1); // Dark Blue

  // State variables for fetched data
  bool _isLoading = true;
  String? _error;
  
  // Stores grouped data: Map<DateString, List<Transaction>>
  Map<String, List<Transaction>> _groupedHistory = {}; 

  @override
  void initState() {
    super.initState();
    _fetchAndGroupHistory();
  }

  // Helper to format date string for grouping (and handle "Today")
  String _formatDateForGrouping(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) {
      return 'Today';
    } else {
      return DateFormat('EEEE, MMMM d, y').format(date);
    }
  }

  // --- Supabase Fetching and Grouping Logic ---
  Future<void> _fetchAndGroupHistory() async {
    // In a real app, you would filter by the currently logged-in user's ID.
    // Assuming RLS or a query filter handles user authentication here.
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      List<Transaction> allTransactions = [];

      // --- 1. Fetch Waste Records ---
      // SELECT created_at, points_earned, waste_type, weight, users(name) FROM waste_records
      final List<Map<String, dynamic>> wasteResponse = await supabase
          .from('waste_records')
          .select('created_at, points_awarded, waste_type, weight, users!inner(name)')
          .order('created_at', ascending: false);
          
      final List<Transaction> wasteTransactions = wasteResponse
          .map((data) => Transaction.fromWasteRecord(data))
          .toList();
      allTransactions.addAll(wasteTransactions);


      // --- 2. Fetch Redemption Records ---
      // SELECT redeemed_at, points_deducted, reward_description, users(name) FROM redemptions
      final List<Map<String, dynamic>> redemptionResponse = await supabase
          .from('redeemptions')
          .select('redeemed_at, points_deducted, reward_description, users!inner(name)')
          .order('redeemed_at', ascending: false);
          
      final List<Transaction> redemptionTransactions = redemptionResponse
          .map((data) => Transaction.fromRedemption(data))
          .toList();
      allTransactions.addAll(redemptionTransactions);
      
      // --- 3. Sort the combined list by date (most recent first) ---
      allTransactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));


      // --- 4. Group the combined list ---
      final Map<String, List<Transaction>> grouped = {};
      for (var transaction in allTransactions) {
        final dateKey = _formatDateForGrouping(transaction.dateTime);
        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(transaction);
      }

      setState(() {
        _groupedHistory = grouped;
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Database error: ${e.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'An unexpected error occurred: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // --- Widget Builders ---

  // Builds a single transaction row
  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final bool isDeposit = transaction.type == 'deposit';
    final Color amountColor = isDeposit ? Colors.blue.shade700 : Colors.red.shade700;
    final String sign = isDeposit ? '+' : '-';
    final String amountText = '$sign ${transaction.amount} pts';

    return InkWell( 
      onTap: () {
        // Navigate to the details page, passing the Transaction object
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     // Ensure HistoryDetailsPage accepts a 'Transaction' object
        //     builder: (context) => HistoryDetailsPage(transaction: transaction),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                transaction.description,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Text(
              amountText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a list section grouped by date
  Widget _buildHistorySection(BuildContext context, String date, List<Transaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
          child: Text(
            date,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...transactions.map((t) => _buildTransactionItem(context, t)).toList(),
        const Divider(height: 1, color: Colors.black12),
      ],
    );
  }

  // Builds the content for a single tab (All, Waste, or Reward)
  Widget _buildTabContent(BuildContext context, String filterType) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }
    
    // Filter the grouped history based on the selected tab
    final filteredHistoryEntries = _groupedHistory.entries.map((entry) {
      final String date = entry.key;
      final List<Transaction> transactions = entry.value;

      if (filterType == 'All') {
        return MapEntry(date, transactions);
      }
      
      final filteredTransactions = transactions
          .where((t) =>
              (filterType == 'Waste' && t.type == 'deposit') ||
              (filterType == 'Reward' && t.type == 'redemption'))
          .toList();
          
      return MapEntry(date, filteredTransactions);
    }).where((entry) => entry.value.isNotEmpty).toList();


    if (filteredHistoryEntries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0),
          child: Text(
            'No transactions found for this filter.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }


    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...filteredHistoryEntries.map((entry) => _buildHistorySection(context, entry.key, entry.value)).toList(),
          const SizedBox(height: 100), // Space for the bottom nav bar
        ],
      ),
    );
  }

  // --- Bottom Navigation Bar ---
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
          // NOTE: The History page itself should typically be the active tab, 
          // but based on your previous mock, I'll keep them all inactive for navigation consistency.
          _buildNavItem(icon: Icons.home, label: 'Home', isActive: false, onTap: () {
            // Replace with correct push/pop for your app structure
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          }),
          _buildNavItem(icon: Icons.leaderboard_outlined, label: 'Leaderboard', isActive: false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardPage()));
          }),
          _buildNavItem(icon: Icons.qr_code, label: 'QR Code', isActive: false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const QrCodePage()));
          }),
          _buildNavItem(icon: Icons.card_giftcard, label: 'Rewards', isActive: false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RewardsPage()));
          }), 
          _buildNavItem(icon: Icons.person, label: 'Profile', isActive: false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          }),
        ],
      ),
    );
  }




  // -------------------------------
  // UI for History Page
  // -------------------------------

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: primaryColor,
          elevation: 0,
          toolbarHeight: 120,
          title: const Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                  ),
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(fontSize: 14),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Waste'),
                    Tab(text: 'Reward'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(context, 'All'),
            _buildTabContent(context, 'Waste'),
            _buildTabContent(context, 'Reward'),
          ],
        ),
        bottomNavigationBar: _buildCustomBottomNavBar(context),
      ),
    );
  }
}
