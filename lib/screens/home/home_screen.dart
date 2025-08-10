

import 'dart:async';
import 'package:eMulakat/screens/home/parole_screen.dart';
import 'package:eMulakat/screens/home/vertical_visit_card.dart';
import 'package:flutter/material.dart';
import '../../dashboard/evisitor_pass_screen.dart';
import '../../dashboard/grievance/grievance_home.dart';
import '../../dashboard/visit/visit_home.dart';
import 'chatbot_screen.dart';
import 'drawer_menu.dart';
import '../../utils/color_scheme.dart';
import 'notifications_screen.dart';
import 'home_screen_logic.dart'; // Import the logic file

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with HomeScreenLogic {
  @override

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmed = await showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text('Exit Confirmation'),
                content: Text('Please use Logout and close the App.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Logout'),
                  ),
                ],
              ),
        );
        return exitConfirmed;
      },
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
              itemBuilder: (context) => [
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
                Future.delayed(Duration.zero, () => translateAll(targetLangCode));
              },
              itemBuilder: (context) => languages.keys.map((language) {
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
                  speak('Welcome to eMulakat, Prison Visitor Management System');
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
                        builder: (context) => NotificationScreen(
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
        ),
        drawer: DrawerMenu(),
        body: Column(
          children: [
            // Top content (Welcome text and visit type cards) - only show if not in expanded view
            if (!isExpandedView)
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translatedWelcome.isNotEmpty ? translatedWelcome : 'Welcome to eMulakat',
                      style: TextStyle(
                        fontSize: fontSize + 8,
                        fontWeight: FontWeight.bold,
                        color: selectedColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      translatedInstructions.isNotEmpty ? translatedInstructions : 'Prison Visitor Management System',
                      style: TextStyle(
                        fontSize: fontSize + 2,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 30),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child:Row(
                        children: [
                          buildVisitTypeCard('Meeting', pastVisits.length, showPastVisits, () {
                            setState(() {
                              showPastVisits = true;
                              isExpandedView = false;
                              selectedVisitor = null;
                            });
                          },
                            leadingIcon: Image.asset(
                              'assets/images/meeting.png',
                              width: 40,
                              height: 40,
                            ),
                            // 👈 Added icon
                          ),
                          SizedBox(width: 10),
                          buildVisitTypeCard('Parole', upcomingVisits.length, !showPastVisits, () {
                            setState(() {
                              showPastVisits = false;
                              isExpandedView = false;
                              selectedVisitor = null;
                            });
                          },
                            leadingIcon: Image.asset(
                              'assets/images/parole.png',
                              width: 40,
                              height: 40,
                            ),

                          ),
                          SizedBox(width: 10),
                          buildVisitTypeCard('Grievance', upcomingVisits.length, !showPastVisits, () {
                            setState(() {
                              showPastVisits = false;
                              isExpandedView = false;
                              selectedVisitor = null;
                            });
                          },
                            leadingIcon: Image.asset(
                              'assets/images/grievance.png',
                              width: 40,
                              height:40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),

            // Main content area
            Expanded(
              child: isExpandedView && selectedVisitor != null
                  ? VisitDetailView(
                selectedVisitor: selectedVisitor!,
                pastVisits: pastVisits,
                upcomingVisits: upcomingVisits,
                onVisitorSelected: (visitor) {
                  setState(() {
                    selectedVisitor = visitor;
                  });
                },
              )
                  : buildVisitCardList(showPastVisits ? pastVisits : upcomingVisits),
            ),

            SizedBox(height: 30),
            // E-Pass Button - always at bottom
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedVisitor != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => eVisitorPassScreen(visitor: selectedVisitor!),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('No Visit Selected'),
                            content: Text('Please select a visit before proceeding.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'eVisitor Pass',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatbotScreen()),
            );
          },
          child: Icon(Icons.chat_outlined,color: Color(0xFFFFFFFF),fontWeight: FontWeight.bold,),
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
                    index: 1,
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  buildNavItem(
                    index: 0,
                    icon: Icons.directions_walk,
                    label: 'Meeting',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => VisitHomeScreen()),
                      );
                    },
                  ),
                  buildNavItem(
                    index: 1,
                    icon: Icons.gavel,
                    label: 'Parole',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => ParoleScreen()),
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
                        MaterialPageRoute(builder: (context) => GrievanceHomeScreen()),
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