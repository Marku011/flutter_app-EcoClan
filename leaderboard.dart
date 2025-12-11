import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home.dart';
import 'qr.dart';
import 'reward.dart';
import 'profile.dart';

final supabase = Supabase.instance.client;

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final Color primaryColor = const Color(0xFF0D47A1);
  final Color secondaryColor = const Color(0xFF42A5F5);

  List<Map<String, dynamic>> leaderboardData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('users')
          .select('id, name, points')
          .order('points', ascending: false);

      // Convert response to List<Map<String, dynamic>>
      leaderboardData = List<Map<String, dynamic>>.from(response);

      // Add rank and progress
      final maxPoints = leaderboardData.isNotEmpty
          ? leaderboardData.first['points'] ?? 0
          : 0;

      for (int i = 0; i < leaderboardData.length; i++) {
        leaderboardData[i]['rank'] = i + 1;
        final points = leaderboardData[i]['points'] ?? 0;
        leaderboardData[i]['progress'] =
            maxPoints > 0 ? points / maxPoints : 0.0;
      }
        } on PostgrestException catch (e) {
      debugPrint('Supabase Error: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
    }

    setState(() => isLoading = false);
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFC107); // Gold
    if (rank == 2) return Colors.grey.shade400; // Silver
    if (rank == 3) return const Color(0xFFA1887F); // Bronze
    return Colors.grey.shade400;
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user) {
    final rank = user['rank'] as int;
    final rankColor = _getRankColor(rank);
    final isTopThree = rank <= 3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank Circle
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isTopThree ? rankColor : Colors.grey.shade200,
                  ),
                  child: Center(
                    child: Text(
                      rank.toString(),
                      style: TextStyle(
                        color: isTopThree ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Username and Points
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user['points'] ?? 0} pts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            // Points Progress Bar
            LinearProgressIndicator(
              value: user['progress'] ?? 0.0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }

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
            Text(label, style: TextStyle(color: color, fontSize: 12)),
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
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
          _buildNavItem(
              icon: Icons.leaderboard_outlined,
              label: 'Leaderboard',
              isActive: true,
              onTap: () {}),
          _buildNavItem(
            icon: Icons.qr_code,
            label: 'QR Code',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrCodePage()),
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
                MaterialPageRoute(builder: (_) => const RewardsPage()),
              );
            },
          ),
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 0,
        toolbarHeight: 100,
        title: const Text(
          'Leaderboard',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : leaderboardData.isEmpty
              ? const Center(child: Text('No users found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: leaderboardData
                        .map((user) => _buildLeaderboardItem(user))
                        .toList(),
                  ),
                ),
      bottomNavigationBar: _buildCustomBottomNavBar(context),
    );
  }
}
