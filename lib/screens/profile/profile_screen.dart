import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'manage_profile_screen.dart';
import 'notification_screen.dart';
import 'theme_provider.dart';
import 'help_center_screen.dart'; // 🔥 Help Center එක Import කළා

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
      'theme': 'Dark Mode',
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
      'theme': 'අඳුරු මාදිලිය',
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
      'theme': 'இருண்ட මාදිலிய',
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(t['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- User Info Section (Live from Firebase) ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('farmers').limit(1).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No farmer data found."));
                }

                var farmerData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.green[100],
                        backgroundImage: (farmerData['profile_pic'] != null && farmerData['profile_pic'] != "")
                            ? NetworkImage(farmerData['profile_pic'])
                            : null,
                        child: (farmerData['profile_pic'] == null || farmerData['profile_pic'] == "")
                            ? const Icon(Icons.person, size: 40, color: Colors.green)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              farmerData['full_name'] ?? "Farmer Name",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface
                              )
                          ),
                          Text(
                              farmerData['email'] ?? "Email Address",
                              style: const TextStyle(color: Colors.grey)
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // --- Account Section ---
            Text(t['account']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildSectionBox([
              _buildMenuItem(
                Icons.person_outline,
                t['manage']!,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageProfileScreen()));
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.notifications_none,
                t['notif']!,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                },
              ),
              _buildDivider(),
              _buildMenuItem(Icons.language, t['lang']!, trailingText: t['lang_name']!, onTap: () {
                _showLanguageDialog();
              }),
            ]),

            const SizedBox(height: 20),
            Text(t['pref']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildSectionBox([
              _buildMenuItem(Icons.info_outline, t['about']!),
              _buildDivider(),
              _buildMenuItem(
                Icons.palette_outlined,
                t['theme']!,
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
              ),
            ]),

            const SizedBox(height: 20),
            Text(t['support']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            _buildSectionBox([
              // 🔥 Help Center එකට Navigate වෙන කොටස
              _buildMenuItem(
                Icons.help_outline,
                t['help']!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpCenterScreen()),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => Divider(height: 1, indent: 50, endIndent: 10, color: Colors.grey.withOpacity(0.1));

  Widget _buildMenuItem(IconData icon, String title, {String? trailingText, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: trailing ?? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) Text(trailingText, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 5),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}