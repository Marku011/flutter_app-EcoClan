import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; 
// import 'transaction_model.dart'; // <-- Use this if Transaction is separate

// --- PLACEHOLDER Transaction MODEL (Must match your working model in history.dart) ---
// If you have 'history.dart' imported, remove this placeholder.
class Transaction {
  final String description;
  final String type; // 'deposit' or 'redemption'
  final int amount; // Points
  final DateTime dateTime; 
  final String? wasteType; 
  final double? weight;
  final String? userName; 

  Transaction({required this.description, required this.type, required this.amount, required this.dateTime, this.wasteType, this.weight, this.userName,});

  factory Transaction.fromWasteRecord(Map<String, dynamic> data) {
    final num pointsAwarded = data['points_awarded'] as num; 
    final num? weightNum = data['weight'] as num?; 
    return Transaction(
      description: 'Waste Deposit',
      type: 'deposit',
      amount: pointsAwarded.toInt(), 
      dateTime: DateTime.parse(data['created_at'] as String),
      wasteType: data['waste_type'] as String?, 
      weight: weightNum?.toDouble(), 
      userName: data['name'] as String?, 
    );
  }
  factory Transaction.fromRedemption(Map<String, dynamic> data) {
    final num pointsDeducted = data['points_deducted'] as num; 
    return Transaction(
      description: data['reward_description'] as String,
      type: 'redemption',
      amount: pointsDeducted.toInt(),
      dateTime: DateTime.parse(data['redeemed_at'] as String),
      wasteType: null,
      weight: null,
      userName: data['name'] as String?, 
    );
  }
}
// --- END PLACEHOLDER ---

// --- Data Models ---
enum NotificationStatus { read, unread }

class NotificationEntry {
  final String id;
  final String title;
  final String subtitle;
  final NotificationStatus status;
  final bool isLarge; // For the taller/white notification card (like "Points successfully redeemed")
  final DateTime date;

  NotificationEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isLarge,
    required this.date,
  });

  // 1. FACTORY: For notifications coming from the 'notifications' table
  factory NotificationEntry.fromSupabase(Map<String, dynamic> data) {
    return NotificationEntry(
      id: data['id'] as String,
      title: data['title'] as String,
      subtitle: data['subtitle'] as String? ?? 'No details available',
      status: (data['status'] == 'read') ? NotificationStatus.read : NotificationStatus.unread,
      isLarge: data['is_large'] as bool,
      date: DateTime.parse(data['created_at'] as String).toLocal(),
    );
  }

  // 2. FACTORY: For notifications generated from a Transaction
  factory NotificationEntry.fromTransaction(Transaction transaction) {
    final bool isDeposit = transaction.type == 'deposit';
    
    String title;
    String subtitle;
    bool isLarge;

    if (isDeposit) {
      title = 'Deposit Successful';
      subtitle = 'You earned ${transaction.amount} pts for depositing recyclable waste.';
      isLarge = true; // Use large card for success (like the white card in your image)
    } else { // Redemption
      title = 'Points Redeemed';
      subtitle = 'You spent ${transaction.amount} pts on "${transaction.description}".';
      isLarge = false; // Use standard card for redemptions (like the gray card in your image)
    }

    return NotificationEntry(
      id: 'TXN-${transaction.dateTime.millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      status: NotificationStatus.read, // Default history items to read
      isLarge: isLarge,
      date: transaction.dateTime,
    );
  }
}


// --- 1. Notification Card Widget ---
class NotificationCard extends StatelessWidget {
  final NotificationEntry entry; 
  final VoidCallback onTap; 
  
  const NotificationCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine card color based on isLarge property to match your image style
    final Color cardColor = entry.isLarge ? Colors.white : Colors.grey.shade200;
    // Determine the unread indicator color
    final Color indicatorColor = entry.status == NotificationStatus.unread ? Colors.green : Colors.transparent;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: cardColor == Colors.white 
            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, h:mm a').format(entry.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
            // Unread indicator
            if (entry.status == NotificationStatus.unread)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- 2. Notification Page (The screen that hosts the list) ---
class NotifPage extends StatefulWidget {
  const NotifPage({super.key});

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  final supabase = Supabase.instance.client;
  List<NotificationEntry> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }
  
  // Helper to format date string for grouping (Today, Yesterday, etc.)
  String _formatDateForGrouping(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dateOnly.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }

  // --- Fetching Logic: Combines Notifications and Transactions ---
  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<NotificationEntry> allNotifications = [];

      // A. Fetch Waste Records
      final List<Map<String, dynamic>> wasteResponse = await supabase
          .from('waste_records')
          .select('created_at, points_awarded, waste_type, weight, users!inner(name)');
          
      final List<Transaction> wasteTransactions = wasteResponse
          .map((data) => Transaction.fromWasteRecord(data)) 
          .toList();

      // B. Fetch Redemption Records
      final List<Map<String, dynamic>> redemptionResponse = await supabase
          .from('redeemptions')
          .select('redeemed_at, points_deducted, reward_description, users!inner(name)');
          
      final List<Transaction> redemptionTransactions = redemptionResponse
          .map((data) => Transaction.fromRedemption(data))
          .toList();
          
      // Combine and convert all transactions into NotificationEntry objects
      final List<NotificationEntry> transactionNotifications = [
          ...wasteTransactions,
          ...redemptionTransactions,
      ].map((t) => NotificationEntry.fromTransaction(t)).toList();

      allNotifications.addAll(transactionNotifications);


      // PART 3: Final Sort and Update
      allNotifications.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _notifications = allNotifications;
          _isLoading = false;
        });
      }
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
  
  // Placeholder for marking notification as read
  void _handleNotificationTap(NotificationEntry entry) {
    // 1. Mark as read in the database (Only for explicit 'notifications' table entries)
    // 2. Navigate to the relevant screen (e.g., Rewards page if it's a redemption alert)
    print('Notification tapped: ${entry.title}');
    // Example: if (entry.id.startsWith('TXN-')) { navigate to HistoryDetailsPage }
  }


  // -------------------------------
  // UI for Home Screen
  // -------------------------------


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications'), backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1))),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications'), backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white),
        body: Center(child: Text(_error!)),
      );
    }
    
    // Group fetched notifications
    final Map<String, List<NotificationEntry>> groupedNotifications = {};
    for (var n in _notifications) {
      final dateKey = _formatDateForGrouping(n.date);
      groupedNotifications.putIfAbsent(dateKey, () => []).add(n);
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D47A1), // Dark blue background
        elevation: 0,
        toolbarHeight: 100,
        title: const Text(
          'Notifications',
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
              color: Colors.white.withOpacity(0.4),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              groupedNotifications.entries.expand<Widget>((entry) { 
                if (entry.value.isEmpty) return [];

                final header = Padding(
                  padding: const EdgeInsets.only(left: 30.0, top: 20.0, bottom: 5.0),
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
                
                // Map NotificationEntry objects to NotificationCard Widgets
                final items = entry.value.map((n) => NotificationCard(
                  entry: n,
                  onTap: () => _handleNotificationTap(n),
                )).toList();

                return [header, ...items];
              }).toList(),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 50),
          ),
        ],
      ),
    );
  }
}
