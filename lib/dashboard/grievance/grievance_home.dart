import 'package:flutter/material.dart';

import '../../pdf_viewer_screen.dart';
import '../../screens/home/home_screen.dart';
import '../visit/visit_home.dart';
import 'complaint_screen.dart';
import 'grievance_preview_screen.dart';

class GrievanceHomeScreen extends StatefulWidget {
  @override
  _GrievanceHomeScreenState createState() => _GrievanceHomeScreenState();
}

class _GrievanceHomeScreenState extends State<GrievanceHomeScreen> {
  int _selectedIndex = 0;


  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Please use Logout and close the App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Stay in app
            child: const Text('OK'),
          ),
        ],
      ),
    ) ??
        false;
  }


  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final _ = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child:Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Grievance'),
            centerTitle: true,
            backgroundColor: Color(0xFF5A8BBA),
            foregroundColor: Colors.black,
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
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Container(
                color: Colors.white, // ✅ Background color
                child: const TabBar(
                  indicatorColor:  Colors.black,
                  labelStyle: TextStyle(               // ✅ Font style for selected tab
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: TextStyle(     // ✅ Font style for unselected tabs
                    fontSize: 18,
                  ),
                  labelColor: Color(0xFF5A8BBA),
                  unselectedLabelColor: Colors.black,
                  tabs: [
                    Tab(text: 'Register Grievance'),
                    Tab(text: 'Preview Grievance'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              ComplaintScreen(),
              GrievancePreviewScreen(),
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
                    _buildNavItem(
                      index: 0,
                      icon: Icons.directions_walk,
                      label: 'Visit',
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => VisitHomeScreen()),
                        );
                      },
                    ),
                    _buildNavItem(
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
                    _buildNavItem(
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
      ),
    );
  }
}


