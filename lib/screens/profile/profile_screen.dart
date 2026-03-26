import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('පැතිකඩ'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green[200],
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'කමල් පෙරේරා',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'kamal@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Account Section
            const _SectionHeader(title: 'ගිණුම'),
            _buildMenuItem(
              icon: Icons.person,
              title: 'පැතිකඩ කළමනාකරණය',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.notifications,
              title: 'දැනුම්දීම්',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.language,
              title: 'භාෂාව',
              trailing: const Text('සිංහල'),
              onTap: () {},
            ),

            const Divider(),

            // Preferences Section
            const _SectionHeader(title: 'මනාප'),
            _buildMenuItem(
              icon: Icons.color_lens,
              title: 'තේමාව',
              trailing: const Text('ආලෝකය'),
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.info,
              title: 'අපි ගැන',
              onTap: () {},
            ),

            const Divider(),

            // Support
            const _SectionHeader(title: 'සහාය'),
            _buildMenuItem(
              icon: Icons.help,
              title: 'උදවු මධ්‍යස්ථානය',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}