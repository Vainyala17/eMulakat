import 'package:flutter/material.dart';
import '../../utils/color_scheme.dart';
import '../auth/login_screen.dart';
import 'ProfileScreen.dart';

class DrawerMenu extends StatefulWidget {
  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  int _selectedIndex = 0;

  void _handleItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {

    final List<Map<String, dynamic>> drawerItems = [
      {'icon': Icons.dashboard, 'label': 'Dashboard'},
      {'icon': Icons.lock, 'label': 'Prison Citizen Services'},
      {'icon': Icons.info_outline, 'label': 'About Us'},
      {'icon': Icons.gavel, 'label': 'Legal Aid'},
      {'icon': Icons.map, 'label': 'Prison Map'},
      {'icon': Icons.store, 'label': 'Kara Bazaar'},
      {'icon': Icons.public, 'label': 'India Portal'},
      {'icon': Icons.phone, 'label': 'Contact Us'},
      {'icon': Icons.share, 'label': 'Share Us'},
      {'icon': Icons.star_rate, 'label': 'Rate Us'},
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/user.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to Profile Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileScreen()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'abc123@gmail.com',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Drawer items
          for (int i = 0; i < drawerItems.length; i++)
            Container(
              color: _selectedIndex == i ? Color(0xFFFFFFFF) : Colors.transparent,
              child: ListTile(
                leading: Icon(
                  drawerItems[i]['icon'],
                  color: _selectedIndex == i ? Color(0xFF3A6895) : Colors.black,
                ),
                title: Text(
                  drawerItems[i]['label'],
                  style: TextStyle(
                    color: _selectedIndex == i ? Color(0xFF3A6895) : Colors.black,
                  ),
                ),
                onTap: () => _handleItemTap(i),
              ),
            ),

          Divider(),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings & account'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text('Confirm Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
