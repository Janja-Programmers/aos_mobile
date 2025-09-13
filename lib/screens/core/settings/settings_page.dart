import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          _settingsTile(
            icon: Icons.email,
            title: "Change email",
            subtitle: "911cybersolutions@gmail.com",
            onTap: () {
              // Navigate with GoRouter
            },
          ),
          _settingsTile(
            icon: Icons.feedback,
            title: "Disable feedback",
            subtitle: "Enabled",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.notifications,
            title: "Manage notifications",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.info,
            title: "About Africa Online Stores",
            onTap: () {
              // Navigate to About Jiji
            },
          ),
          _settingsTile(
            icon: Icons.wifi,
            title: "Check connection",
            onTap: () {},
          ),
          _settingsTile(icon: Icons.star, title: "Rate Us", onTap: () {}),
          _settingsTile(
            icon: Icons.dark_mode,
            title: "Dark mode",
            subtitle: "System (default)",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.lock,
            title: "Change password",
            onTap: () {},
          ),
          _settingsTile(
            icon: Icons.delete,
            title: "Delete my account permanently",
            onTap: () {},
          ),
          _settingsTile(icon: Icons.logout, title: "Log out", onTap: () {}),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
