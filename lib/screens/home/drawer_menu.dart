import 'package:eMulakat/policies/kara_bazaar.dart';
import 'package:eMulakat/policies/legal_aid.dart';
import 'package:eMulakat/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../policies/about_us_screen.dart';
import '../../policies/contact_us_popup.dart';
import '../../policies/india_portal.dart';
import '../../policies/prison_citizen_services.dart';
import '../../policies/prison_map.dart';
import '../../policies/setting_account_screen.dart';
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
      {'icon': Icons.dashboard, 'label': 'Dashboard', 'page': HomeScreen()},
      {'icon': Icons.lock, 'label': 'Prison Citizen Services', 'page': PrisonCitizenServicesScreen()},
      {'icon': Icons.info_outline, 'label': 'About Us', 'page': AboutUsScreen()},
      {'icon': Icons.gavel, 'label': 'Legal Aid', 'page': LegalAidScreen()},
      {'icon': Icons.map, 'label': 'Prison Map', 'page': PrisonMapScreen()},
      {'icon': Icons.store, 'label': 'Kara Bazaar', 'page': KaraBazaarScreen() },
      {'icon': Icons.public, 'label': 'India Portal','page': IndiaPortalScreen()  },
      {'icon': Icons.phone, 'label': 'Contact Us', 'page':  ContactUsPopup()},
      {
        'icon': Icons.share,
        'label': 'Share Us',
        'isShare': true,
        'message': 'Hey! Check out this awesome app: https://play.google.com/store/apps/details?id=com.example.emulakat'
      },
      {'icon': Icons.star_rate, 'label': 'Rate Us', 'isRate': true},
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
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
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
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Suresh Gupta',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'suresh@nutantek.com ',
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
                  onTap: () async {
                    final item = drawerItems[i];

                    if (item['isRate'] == true) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          double selectedRating = 0;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text('Rate Us'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        return IconButton(
                                          icon: Icon(
                                            index < selectedRating
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 32,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectedRating = index + 1.0;
                                            });
                                          },
                                        );
                                      }),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      selectedRating == 0
                                          ? 'Tap stars to rate'
                                          : 'You rated $selectedRating stars',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Thanks for rating $selectedRating stars!')),
                                      );
                                    },
                                    child: Text('Submit'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    }// Close the drawer
                    else if (item['isShare'] == true) {
                      Share.share(item['message'] ?? 'Check out this app!');

                    } else if (item['page'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => item['page']),
                      );
                    }
                  }
              ),
            ),

          Divider(),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings & account'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountSettingsScreen()),
              );
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
