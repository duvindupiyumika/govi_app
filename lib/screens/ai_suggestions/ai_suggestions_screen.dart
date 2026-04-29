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
      backgroundColor: const Color(0xFFF8F9FA), 
      body: CustomScrollView(
        slivers: [
          
          SliverAppBar(
            expandedHeight: 70.0, 
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                "AI කෘෂි උපදේශක",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF00897B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.psychology_outlined,
                    size: 60,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "ප්‍රධාන සේවාවන්",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  
                  _buildServiceCard(
                    context, 
                    "ලෙඩ රෝග හඳුනා ගැනීම (Scan)", 
                    "පින්තූරයකින් රෝගය හඳුනා ගන්න", 
                    Icons.camera_alt_rounded, 
                    Colors.orange, 
                    const DiseaseScanScreen()
                  ),
                  _buildServiceCard(
                    context, 
                    "සුදුසු බෝග නිර්දේශය", 
                    "ඔබේ ප්‍රදේශයට ගැලපෙන බෝග", 
                    Icons.grass_rounded, 
                    Colors.blue, 
                    const CropRecommendationScreen()
                  ),
                  _buildServiceCard(
                    context, 
                    "පොහොර උපදේශක", 
                    "හොඳම පොහොර ප්‍රමාණය දැනගන්න", 
                    Icons.science_rounded, 
                    Colors.purple, 
                    const FertilizerAdvisorScreen()
                  ),
                  _buildServiceCard(
                    context, 
                    "AI සහායක සමඟ චැට් කරන්න", 
                    "ඕනෑම ගැටලුවක් විමසන්න", 
                    Icons.forum_rounded, 
                    Colors.teal, 
                    const AiChatScreen()
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  
  Widget _buildServiceCard(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget nextScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => nextScreen)),
      ),
    );
  }
}