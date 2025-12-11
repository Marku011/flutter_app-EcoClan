import 'package:flutter/material.dart';

import 'home.dart';

// --- Data Models ---
class TipEntry {
  final String title;
  final String content;

  TipEntry({required this.title, required this.content});
}

// --- Sample Data ---
final List<TipEntry> educationalTips = [
  TipEntry(title: 'Recycle Right', content: 'Always rinse containers before recycling them to avoid contaminating other materials.'),
  TipEntry(title: 'Compost Basics', content: 'Start a compost bin for food scraps and yard waste to enrich your soil naturally.'),
  TipEntry(title: 'Save Water at Home', content: 'Turn off the tap while brushing your teeth and take shorter showers.'),
  TipEntry(title: 'Choose Reusable Bags', content: 'Keep reusable shopping bags in your car or purse so you never need a plastic one.'),
  TipEntry(title: 'Energy Efficiency', content: 'Unplug electronics and appliances when they are not in use to reduce "phantom load".'),
];

// --- 2. Tip Card Widget (Mimicking the look from Tips.png) ---
class TipCard extends StatelessWidget {
  final TipEntry tip;

  const TipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        // Gradient matching the EcoClan theme (blue to lighter blue)
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tip.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tip.content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. Tips Page (The Screen) ---
class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1), // Dark blue background
        elevation: 0,
        toolbarHeight: 100, // Increased height for the full-width header
        title: const Text(
          'Educational Tips',
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
              color: const Color(0xFFFFFF).withOpacity(0.4), // Slight blue background
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                // Corrected navigation to pop (go back)
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Header: "Educational Tips" (from the screenshot)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
              child: Text(
                'Educational Tips',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ),
          ),
          
          // List of Tip Cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return TipCard(tip: educationalTips[index]);
              },
              childCount: educationalTips.length,
            ),
          ),
        ],
      ),
    );
  }
}