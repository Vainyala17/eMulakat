import 'package:flutter/material.dart';

import '../pdf_viewer_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Setting & Account'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(
                    assetPath: 'assets/pdfs/about_us.pdf',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // User Info Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('your.email@example.com', style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),

          Divider(),

          // Account Options
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('My Profile'),
            onTap: () {
              // Navigate to Profile screen
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('My Address'),
            onTap: () {
              // Navigate to Address screen
            },
          ),

          Divider(),

          // Settings Options
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            onTap: () {
              // Change language
            },
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Dark Mode'),
            onTap: () {
              // Toggle dark mode
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {
              // Navigate to Notification settings
            },
          ),

          Divider(),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Logout logic
            },
          ),
        ],
      ),
    );
  }
}
