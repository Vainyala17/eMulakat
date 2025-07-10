import 'package:flutter/material.dart';
import '../../utils/color_scheme.dart';
import '../auth/login_screen.dart';

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
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            accountName: Text(
              'Vainyala Samal',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              'samal_123@gmail.com',
              style: TextStyle(color: Colors.black54),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/images/user.png'),
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
