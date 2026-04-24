import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // 🔥 මුළු පිටුවේම පසුබිම theme එක අනුව මාරු වේ
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Help Center", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Header & Search Section ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                // 🔥 Gemini Surface Color එක මෙතනට වැටෙනවා
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "How can we help you?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface, // 🔥 Adaptive Text
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      // 🔥 Search bar එක පේන්න පොඩි වෙනසක් කළා
                      color: isDark ? Colors.black38 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Search for help...",
                        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.green),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Contact Options Grid ---
                  Text(
                      "Contact Us",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface
                      )
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildContactCard(context, Icons.chat_outlined, "WhatsApp", Colors.green),
                      const SizedBox(width: 15),
                      _buildContactCard(context, Icons.call_outlined, "Call Now", Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildContactCard(context, Icons.email_outlined, "Email Us", Colors.orange),
                      const SizedBox(width: 15),
                      _buildContactCard(context, Icons.language, "Website", Colors.teal),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- FAQ Section ---
                  Text(
                      "Frequently Asked Questions",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface
                      )
                  ),
                  const SizedBox(height: 15),
                  _buildFAQItem(context, "How to scan a crop disease?", "Go to AI Hub and click on 'Scan Disease' button to take a photo of your crop."),
                  _buildFAQItem(context, "How to check market prices?", "You can find the latest market prices in the 'Market' tab in the bottom navigation."),
                  _buildFAQItem(context, "Can I use the app offline?", "Basic information is available offline, but AI analysis requires an internet connection."),
                  _buildFAQItem(context, "How to update my profile?", "Go to Profile tab and click on 'Manage Profile' to change your details."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, IconData icon, String title, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, // 🔥 Adaptive Card
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
          question,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface
          )
      ),
      iconColor: Colors.green,
      collapsedIconColor: Colors.grey,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
              answer,
              style: const TextStyle(color: Colors.grey, height: 1.5)
          ),
        ),
      ],
    );
  }
}