import 'package:flutter/material.dart';

import '../../dashboard/grievance/grievance_home.dart';
import '../../dashboard/parole/parole_home.dart';
import '../../dashboard/visit/visit_home.dart';
import '../../dashboard/visit/whom_to_meet_screen.dart';
import 'home_screen.dart';

class BottomNavBarScreen extends StatefulWidget {
  final int selectedIndex;

  const BottomNavBarScreen({
    Key? key,
    this.selectedIndex = 1, // default to Meeting tab
  }) : super(key: key);

  @override
  _BottomNavBarScreenState createState() => _BottomNavBarScreenState();
}

class _BottomNavBarScreenState extends State<BottomNavBarScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  final List<Widget> _pages = [
    VisitHomeScreen(),             // Visit
    HomeScreen(),             // Dashboard
    GrievanceHomeScreen(),    // Grievance
  ];

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical:3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.grey[300] : Colors.transparent,
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                      : [],
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Color(0xFF5A8BBA) : Colors.white,
                ),
              ),
              SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
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
    return Scaffold(
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
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 0)),
                    );
                  },
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.directions_walk,
                  label: 'Meeting',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => VisitHomeScreen(selectedIndex: 1)),
                    );
                  },
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.gavel,
                  label: 'Parole',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ParoleHomeScreen(selectedIndex: 2),
                      ),
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
                      MaterialPageRoute(builder: (context) => GrievanceHomeScreen(selectedIndex: 3)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
