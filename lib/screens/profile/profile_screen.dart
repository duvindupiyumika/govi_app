import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/profile/domain/local_profile.dart';
import '../../l10n/app_localizations_context.dart';
import 'help_center_screen.dart';
import 'manage_profile_screen.dart';
import 'notification_screen.dart';
import 'theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final profile = themeProvider.profile;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.profileTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, profile),
            const SizedBox(height: 25),
            Text(
              l10n.profileAccount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildSectionBox(context, [
              _buildMenuItem(
                Icons.person_outline,
                l10n.profileManage,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageProfileScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.notifications_none,
                l10n.profileNotifications,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                Icons.language,
                l10n.profileLanguage,
                trailingText: themeProvider.languageName,
                onTap: () => _showLanguageDialog(context),
              ),
            ]),
            const SizedBox(height: 20),
            Text(
              l10n.profilePreferences,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildSectionBox(context, [
              _buildMenuItem(Icons.info_outline, l10n.profileAbout),
              _buildDivider(),
              _buildMenuItem(
                Icons.palette_outlined,
                l10n.profileDarkMode,
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  activeThumbColor: Colors.green,
                  onChanged: themeProvider.toggleTheme,
                ),
              ),
            ]),
            const SizedBox(height: 20),
            Text(
              l10n.profileSupport,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildSectionBox(context, [
              _buildMenuItem(
                Icons.help_outline,
                l10n.profileHelp,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen(),
                    ),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, LocalProfile profile) {
    final imageProvider = _profileImageProvider(profile.profileImagePath);
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.green[100],
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(Icons.person, size: 40, color: Colors.green)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email?.isNotEmpty == true
                      ? profile.email!
                      : l10n.profileEmailEmpty,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.location?.isNotEmpty == true
                      ? profile.location!
                      : l10n.profileLocationEmpty,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _profileImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    final file = File(path);
    if (!file.existsSync()) return null;
    return FileImage(file);
  }

  void _showLanguageDialog(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                onTap: () {
                  themeProvider.setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('සිංහල'),
                onTap: () {
                  themeProvider.setLanguage('si');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('தமிழ்'),
                onTap: () {
                  themeProvider.setLanguage('ta');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionBox(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => Divider(
    height: 1,
    indent: 50,
    endIndent: 10,
    color: Colors.grey.withValues(alpha: 0.1),
  );

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    String? trailingText,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing:
          trailing ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Text(
                  trailingText,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
      onTap: onTap,
    );
  }
}
