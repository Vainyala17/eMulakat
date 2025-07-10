import 'package:flutter/material.dart';

import '../../dashboard/grievance/grievance_home.dart';
import 'home_screen.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 1; // Dashboard in center

  final List<Widget> _pages = [
    HomeScreen(),             // Visit
    HomeScreen(),             // Dashboard
    GrievanceHomeScreen(),    // Grievance
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTabSelected(1), // Dashboard center
        backgroundColor: Color(0xFF00E5FF),
        child: Icon(Icons.dashboard, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        color: Color(0xFF5A8BBA),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTabItem(icon: Icons.directions_walk, label: 'Visit', index: 0),
              _buildTabItem(icon: Icons.report_problem, label: 'Grievance', index: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required IconData icon, required String label, required int index}) {
    return InkWell(
      onTap: () => _onTabSelected(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
