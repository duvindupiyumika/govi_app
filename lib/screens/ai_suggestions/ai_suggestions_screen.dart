import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../logic/gemini_service.dart';

class AiSuggestionsScreen extends StatefulWidget {
  const AiSuggestionsScreen({super.key});

  @override
  State<AiSuggestionsScreen> createState() => _AiSuggestionsScreenState();
}

class _AiSuggestionsScreenState extends State<AiSuggestionsScreen> {
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;

  // 🔥 Result පෙන්වන BottomSheet එකත් Dark mode වලට හැදුවා
  void _showResult(String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, // 🔥 Adaptive Color
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
            const Divider(),
            Expanded(
                child: SingleChildScrollView(
                    child: Text(
                        content,
                        style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Theme.of(context).colorScheme.onSurface // 🔥 Text Color
                        )
                    )
                )
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("වැසීමට", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanDisease() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _isLoading = true);
      final bytes = await image.readAsBytes();
      final response = await _geminiService.identifyDisease(bytes);
      setState(() => _isLoading = false);
      _showResult("රෝග විනිශ්චය", response);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // 🔥 Adaptive BG
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
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                  if (_isLoading) const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(color: Colors.green))),
                  Text(
                      "ප්‍රධාන සේවාවන්",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface // 🔥 Adaptive
                      )
                  ),
                  const SizedBox(height: 15),
                  _buildServiceCard(context, "ලෙඩ රෝග හඳුනා ගැනීම (Scan)", "පින්තූරයකින් රෝගය හඳුනා ගන්න", Icons.document_scanner_outlined, Colors.orange, _scanDisease),
                  _buildServiceCard(context, "සුදුසු බෝග නිර්දේශය", "ඔබේ ප්‍රදේශයට ගැලපෙන බෝග", Icons.grass_outlined, Colors.blue, () async {
                    setState(() => _isLoading = true);
                    final res = await _geminiService.getCropRecommendation("අනුරාධපුරය", "6.5", "30°C");
                    setState(() => _isLoading = false);
                    _showResult("නිර්දේශිත බෝග", res);
                  }),
                  _buildServiceCard(context, "පොහොර උපදේශක", "හොඳම පොහොර ප්‍රමාණය දැනගන්න", Icons.science_outlined, Colors.purple, () async {
                    setState(() => _isLoading = true);
                    final res = await _geminiService.getFertilizerAdvice("වී වගාව", "5");
                    setState(() => _isLoading = false);
                    _showResult("පොහොර උපදෙස්", res);
                  }),
                  _buildServiceCard(context, "AI සහායක සමඟ චැට් කරන්න", "ඕනෑම ගැටලුවක් විමසන්න", Icons.chat_bubble_outline, Colors.teal, () {}),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      color: Theme.of(context).colorScheme.surface, // 🔥 Card Background
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface
            )
        ),
        subtitle: Text(subtitle, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}