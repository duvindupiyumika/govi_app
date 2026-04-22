import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selectedLang = "si"; 

  final Map<String, Map<String, String>> localizedText = {
    'en': {
      'title': 'Profile',
      'account': 'Account',
      'manage': 'Manage Profile',
      'notif': 'Notifications',
      'lang': 'Language',
      'lang_name': 'English',
      'pref': 'Preferences',
      'about': 'About Us',
      'theme': 'Theme',
      'theme_mode': 'Light',
      'support': 'Support',
      'help': 'Help Center',
    },
    'si': {
      'title': 'පැතිකඩ',
      'account': 'ගිණුම',
      'manage': 'පැතිකඩ කළමනාකරණය',
      'notif': 'දැනුම්දීම්',
      'lang': 'භාෂාව',
      'lang_name': 'සිංහල',
      'pref': 'මනාප',
      'about': 'අපි ගැන',
      'theme': 'තේමාව',
      'theme_mode': 'ආලෝකය', 
      'support': 'සහාය',
      'help': 'උදවු මධ්‍යස්ථානය',
    },
    'ta': {
      'title': 'சுயவிவரம்',
      'account': 'கணக்கு',
      'manage': 'சுயவிவரத்தை நிர்வகி',
      'notif': 'அறிவிப்புகள்',
      'lang': 'மொழி',
      'lang_name': 'தமிழ்',
      'pref': 'விருப்பத்தேர்வுகள்',
      'about': 'எங்களைப் பற்றி',
      'theme': 'தீம்',
      'theme_mode': 'ஒளி', 
      'support': 'ஆதரவு',
      'help': 'உதவி மையம்',
    },
  };

  void changeLanguage(String langCode) {
    setState(() {
      selectedLang = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    var t = localizedText[selectedLang]!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(t['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
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

            // Account Section
            Text(t['account']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildSectionBox([
              _buildMenuItem(Icons.person_outline, t['manage']!),
              _buildDivider(),
              _buildMenuItem(Icons.notifications_none, t['notif']!),
              _buildDivider(),
              _buildMenuItem(Icons.language, t['lang']!, trailingText: t['lang_name']!, onTap: () {
                _showLanguageDialog();
              }),
            ]),

            const SizedBox(height: 20),
            Text(t['pref']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildSectionBox([
              _buildMenuItem(Icons.info_outline, t['about']!),
              _buildDivider(),
              _buildMenuItem( Icons.palette_outlined, t['theme']!, trailingText: t['theme_mode']!),
            ]),

            const SizedBox(height: 20),
            Text(t['support']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            _buildSectionBox([
              _buildMenuItem(Icons.help_outline, t['help']!),
            ]),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text("English"), onTap: () { changeLanguage("en"); Navigator.pop(context); }),
            ListTile(title: const Text("සිංහල"), onTap: () { changeLanguage("si"); Navigator.pop(context); }),
            ListTile(title: const Text("தமிழ்"), onTap: () { changeLanguage("ta"); Navigator.pop(context); }),
          ],
        );
      },
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

  Widget _buildDivider() => Divider(height: 1, indent: 50, endIndent: 10, color: Colors.grey[200]);

  Widget _buildMenuItem(IconData icon, String title, {String? trailingText, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}