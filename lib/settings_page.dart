import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C0E8),
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          // User section
          ListTile(
            leading: const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
            title: const Text(
              "Foulen Ben Foulen",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.settings),
          ),

          const SizedBox(height: 20),

          // Settings options
          _tile(Icons.person_outline, "User Profile"),
          _tile(Icons.lock_outline, "Change Password"),
          _tile(Icons.help_outline, "FAQs"),

          SwitchListTile(
            title: const Text("Push Notification"),
            value: true,
            onChanged: (v) {},
            secondary: const Icon(Icons.notifications_none),
          ),

          const Divider(),

          _tile(Icons.logout, "Logout"),
        ],
      ),
    );
  }

  ListTile _tile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {},
    );
  }
}
