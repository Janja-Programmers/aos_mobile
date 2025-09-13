import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About Africa Online Stores")),
      body: ListView(
        children: [
          _aboutTile(
            title: "Contact us",
            subtitle: "support@africaonlinestores.com",
            onTap: () {},
          ),
          _aboutTile(title: "Terms and Conditions", onTap: () {}),
          _aboutTile(title: "Privacy Policy", onTap: () {}),
          _aboutTile(title: "Safety tips", onTap: () {}),
          _aboutTile(title: "Restore app", onTap: () {}),
          const ListTile(title: Text("App version"), subtitle: Text("5.1.0.1")),
        ],
      ),
    );
  }

  Widget _aboutTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
