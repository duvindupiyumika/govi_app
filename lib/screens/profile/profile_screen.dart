import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('පැතිකඩ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green, 
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Info Section 
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.green[100],
                    child: const Icon(Icons.person, size: 40, color: Colors.green),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("කමල් පෙරේරා", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("kamal@gmail.com", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 2. Account Section
            const Text("ගිණුම ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildSectionBox([
              _buildMenuItem(Icons.person_outline, "පැතිකඩ කළමනාකරණය"),
              _buildDivider(),
              _buildMenuItem(Icons.notifications_none, "දැනුම්දීම්"),
              _buildDivider(),
              _buildMenuItem(Icons.language, "භාෂාව", trailingText: "සිංහල"),
            ]),

            const SizedBox(height: 20),

            // 3. Preferences Section
            const Text("මනාප ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildSectionBox([
              _buildMenuItem(Icons.info_outline, "අපි ගැන"),
              _buildDivider(),
              _buildMenuItem(Icons.palette_outlined, "තේමාව", trailingText: "ආලෝකය"),
            ]),

            const SizedBox(height: 20),

            // 4. Support Section
            const Text("සහාය ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildSectionBox([
              _buildMenuItem(Icons.help_outline, "උදවු මධ්‍යස්ථානය"),
            ]),
          ],
        ),
      ),
    );
  }

  
  Widget _buildSectionBox(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(children: children),
    );
  }

  
  Widget _buildDivider() {
    return Divider(height: 1, indent: 50, endIndent: 10, color: Colors.grey[200]);
  }

  
  Widget _buildMenuItem(IconData icon, String title, {String? trailingText}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green), 
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      onTap: () {},
    );
  }
}