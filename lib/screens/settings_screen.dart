import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Profile Settings'),
            leading: const Icon(Icons.person),
            onTap: () {
              // Navigate to profile settings
            },
          ),
          ListTile(
            title: const Text('Notification Settings'),
            leading: const Icon(Icons.notifications),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          ListTile(
            title: const Text('Business Information'),
            leading: const Icon(Icons.business),
            onTap: () {
              // Navigate to business settings
            },
          ),
          ListTile(
            title: const Text('Backup Data'),
            leading: const Icon(Icons.backup),
            onTap: () {
              // Handle backup
            },
          ),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info),
            onTap: () {
              // Show about dialog
            },
          ),
        ],
      ),
    );
  }
}
