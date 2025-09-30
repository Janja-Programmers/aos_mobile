import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '/core/constants/colors.dart';
import '/shared/widgets/app_bars.dart';

import '../auth/auth_provider.dart';
import '../../shared/utils/confirm_account_delete.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text("About Africa Online Stores"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  dense: true,
                  leading: Icon(Icons.verified, color: Colors.blue),
                  title: Text("App Version"),
                  subtitle: Text("1.0.0"),
                ),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.update, color: Colors.orange),
                  title: Text("Last Update"),
                  subtitle: Text("September 2025"),
                ),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.copyright, color: Colors.grey),
                  title: Text("Copyright"),
                  subtitle: Text(
                    "© 2025 Africa Online Stores. All rights reserved.",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TopAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? "Guest",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? "Email Address",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Options Section
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("About Africa Online Stores"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("Terms & Conditions"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/terms');
                  },
                ),

                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.lock_outline,
                    color: Colors.blueAccent,
                  ),
                  title: const Text("Privacy Policy"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/privacy');
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Danger Zone
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    "Delete Account",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () => ConfirmDeleteAccountDialog.show(context),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
