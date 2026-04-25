import 'package:flutter/material.dart';
import 'disease_scan_screen.dart';
import 'crop_recommendation_screen.dart';
import 'fertilizor_advisor_screen.dart';
import 'ai_chat_screen.dart';

class AiSuggestionsScreen extends StatelessWidget {
  const AiSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text("AI කෘෂි උපදේශක", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                ),
                child: const Center(child: Opacity(opacity: 0.2, child: Icon(Icons.psychology, size: 100, color: Colors.white))),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ප්‍රධාන සේවාවන්", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildServiceCard(context, "ලෙඩ රෝග හඳුනා ගැනීම (Scan)", "පින්තූරයකින් රෝගය හඳුනා ගන්න", Icons.document_scanner_outlined, Colors.orange, const DiseaseScanScreen()),
                  _buildServiceCard(context, "සුදුසු බෝග නිර්දේශය", "ඔබේ ප්‍රදේශයට ගැලපෙන බෝග", Icons.grass_outlined, Colors.blue, const CropRecommendationScreen()),
                  _buildServiceCard(context, "පොහොර උපදේශක", "හොඳම පොහොර ප්‍රමාණය දැනගන්න", Icons.science_outlined, Colors.purple, const FertilizerAdvisorScreen()),
                  _buildServiceCard(context, "AI සහායක සමඟ චැට් කරන්න", "ඕනෑම ගැටලුවක් විමසන්න", Icons.chat_bubble_outline, Colors.teal, const AiChatScreen()),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget nextScreen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => nextScreen)),
      ),
    );
  }
}