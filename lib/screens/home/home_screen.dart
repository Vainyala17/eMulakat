import 'dart:async';
import 'package:eMulakat/screens/home/registered_inmates.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../dashboard/grievance/grievance_details_screen.dart';
import '../../dashboard/parole/parole_screen.dart';
import '../../dashboard/visit/whom_to_meet_screen.dart';
import '../../utils/dialog_utils.dart';
import '../registration/visitor_register_screen.dart';
import 'chatbot_screen.dart';
import 'drawer_menu.dart';
import '../../utils/color_scheme.dart';
import 'notifications_screen.dart';
import 'home_screen_logic.dart';

class HomeScreen extends StatefulWidget {
  final int selectedIndex;

  // Changed default value from 0 to 1 to show "My Registered Inmates" tab first
  const HomeScreen({Key? key, this.selectedIndex = 1}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with HomeScreenLogic, SingleTickerProviderStateMixin {
  bool _showingVisitCards = false;
  late TabController _tabController;
  bool _isProfileCompleted = false;
  int _currentBottomNavIndex = 0; // Add this to track bottom navigation state

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.selectedIndex,
    );

    // Set the correct bottom navigation index based on selected tab
    _currentBottomNavIndex = widget.selectedIndex == 1 ? 0 : 0; // 0 for Dashboard
    _checkProfileStatus();
    initializeTts();
    initializeStt();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Updated buildNavItem to show active state correctly
  Widget buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    bool isSelected = _currentBottomNavIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentBottomNavIndex = index;
          });
          onTap();
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkProfileStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool profileCompleted = prefs.getBool('profile_completed') ?? false;

    setState(() {
      _isProfileCompleted = profileCompleted;
    });

    // Show profile update alert if not completed
    if (!profileCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfileUpdateAlert();
      });
    }
  }

  void _showProfileUpdateAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Alert!\nIncomplete Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Please complete your Profile by adding your photo and ID proof to allow to raise Meeting, Parole, Grievance requests for your Registered Inmates.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VisitorFormScreen(
                          onProfileCompleted: () {
                            _markProfileAsCompleted();
                          },
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markProfileAsCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profile_completed', true);
    setState(() {
      _isProfileCompleted = true;
    });
  }

  // Home Tab Content
  Widget _buildHomeTabContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 80),
      child: Column(
        children: [
          SizedBox(height: 20),

          // Visit Type Cards Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildVisitTypeCard(
                    'Meeting',
                    statusCounts['Meeting']?['Total'] ?? 0,
                    selectedVisitType == 'Meeting',
                        () {
                      setState(() {
                        selectedVisitType = 'Meeting';
                        selectedStatus = 'All';
                      });
                    },
                    leadingIcon: Image.asset(
                      'assets/images/meeting.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  SizedBox(width: 10),
                  buildVisitTypeCard(
                    'Parole',
                    statusCounts['Parole']?['Total'] ?? 0,
                    selectedVisitType == 'Parole',
                        () {
                      setState(() {
                        selectedVisitType = 'Parole';
                        selectedStatus = 'All';
                      });
                    },
                    leadingIcon: Image.asset(
                      'assets/images/parole.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  SizedBox(width: 10),
                  buildVisitTypeCard(
                    'Grievance',
                    statusCounts['Grievance']?['Total'] ?? 0,
                    selectedVisitType == 'Grievance',
                        () {
                      setState(() {
                        selectedVisitType = 'Grievance';
                        selectedStatus = 'All';
                      });
                    },
                    leadingIcon: Image.asset(
                      'assets/images/grievance.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 30),

          // Status List Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.10),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // First row - Pending and Upcoming
                  Row(
                    children: [
                      buildStatusCard(
                        'Pending',
                        statusCounts[selectedVisitType]?['Pending'] ?? 0,
                        'pending',
                        selectedStatus == 'Pending',
                            () {
                          setState(() {
                            selectedStatus =
                            selectedStatus == 'Pending' ? 'All' : 'Pending';
                          });
                        },
                      ),
                      buildStatusCard(
                        'Upcoming',
                        statusCounts[selectedVisitType]?['Upcoming'] ?? 0,
                        'upcoming',
                        selectedStatus == 'Upcoming',
                            () {
                          setState(() {
                            selectedStatus =
                            selectedStatus == 'Upcoming' ? 'All' : 'Upcoming';
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Second row - Completed and Expired
                  Row(
                    children: [
                      buildStatusCard(
                        'Completed',
                        statusCounts[selectedVisitType]?['Completed'] ?? 0,
                        'completed',
                        selectedStatus == 'Completed',
                            () {
                          setState(() {
                            selectedStatus =
                            selectedStatus == 'Completed' ? 'All' : 'Completed';
                          });
                        },
                      ),
                      buildStatusCard(
                        'Expired',
                        statusCounts[selectedVisitType]?['Expired'] ?? 0,
                        'expired',
                        selectedStatus == 'Expired',
                            () {
                          setState(() {
                            selectedStatus =
                            selectedStatus == 'Expired' ? 'All' : 'Expired';
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  // Third row - Total
                  Row(
                    children: [
                      Expanded(child: SizedBox()),
                      buildStatusCard(
                        'Total',
                        statusCounts[selectedVisitType]?['Total'] ?? 0,
                        'total',
                        selectedStatus == 'All',
                            () {
                          setState(() {
                            selectedStatus = 'All';
                          });
                        },
                      ),
                      Expanded(child: SizedBox()),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 30),

          // Visit List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: buildVerticalVisitsList(),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => DialogUtils.onWillPop(context, showingCards: _showingVisitCards),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: selectedColor,
          actions: [
            // Font Size Controls
            PopupMenuButton<double>(
              icon: Icon(Icons.font_download),
              onSelected: (size) {
                setState(() {
                  fontSize = size;
                });
              },
              itemBuilder: (context) =>
              [
                PopupMenuItem(value: 12.0, child: Text('A-')),
                PopupMenuItem(value: 16.0, child: Text('A')),
                PopupMenuItem(value: 20.0, child: Text('A+')),
              ],
            ),

            // Language Selection
            PopupMenuButton<String>(
              icon: Icon(Icons.language),
              onSelected: (language) {
                final targetLangCode = languages[language] ?? 'en';
                Future.delayed(
                    Duration.zero, () => translateAll(targetLangCode));
              },
              itemBuilder: (context) =>
                  languages.keys.map((language) {
                    return PopupMenuItem<String>(
                      value: language,
                      child: Text(language),
                    );
                  }).toList(),
            ),

            // Text to Speech
            IconButton(
              icon: Icon(
                isTtsEnabled ? Icons.volume_up : Icons.volume_off,
                color: Colors.black,
              ),
              onPressed: () {
                if (!isTtsEnabled) {
                  setState(() {
                    isTtsEnabled = true;
                  });
                  speak(
                      'Welcome to eMulakat, Prison Visitor Management System');
                } else {
                  setState(() {
                    isTtsEnabled = false;
                  });
                  flutterTts.stop();
                }
              },
            ),

            // Notification Icon
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NotificationScreen(
                              notifications: notifications,
                              onNotificationRead: markNotificationAsRead,
                            ),
                      ),
                    );
                  },
                ),
                if (unreadNotificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$unreadNotificationCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.white,
              indicatorWeight: 5,

              // Selected tab style with shadow
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                shadows: [
                  Shadow(
                    offset: Offset(1.5, 1.5), // horizontal, vertical offset
                    blurRadius: 3, // softness of shadow
                    color: Colors.grey, // shadow color
                  ),
                ],
              ),

              // Unselected tab style (still bold, no shadow)
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),

              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'My Registered Inmates'),
              ],
            )
        ),
        drawer: DrawerMenu(),
        body: Stack(
          children: [
            // Main tab content
            TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTabContent(),
                MyRegisteredInmatesScreen(),
              ],
            ),

            // Fixed Floating Action Button
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatbotScreen()),
                  );
                },
                backgroundColor: AppColors.primary,
                child: Icon(Icons.chat_outlined, color: Colors.white),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Color(0xFF5A8BBA),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  buildNavItem(
                    index: 0,
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    onTap: () {
                      // Stay on current screen, just switch to dashboard tab
                      _tabController.animateTo(0);
                    },
                  ),
                  buildNavItem(
                    index: 1,
                    icon: Icons.directions_walk,
                    label: 'Meeting',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MeetFormScreen(selectedIndex: 1,showVisitCards: true,)),
                      );
                    },
                  ),
                  buildNavItem(
                    index: 2,
                    icon: Icons.gavel,
                    label: 'Parole',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParoleScreen(selectedIndex: 2),
                        ),
                      );
                    },
                  ),
                  buildNavItem(
                    index: 3,
                    icon: Icons.report_problem,
                    label: 'Grievance',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => GrievanceDetailsScreen(selectedIndex: 3)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}