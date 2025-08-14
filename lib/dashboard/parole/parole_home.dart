//
// import 'package:eMulakat/dashboard/grievance/complaint_screen.dart';
// import 'package:eMulakat/dashboard/parole/parole_screen.dart';
// import 'package:eMulakat/dashboard/visit/visit_home.dart';
// import 'package:flutter/material.dart';
//
// import '../../pdf_viewer_screen.dart';
// import '../../screens/home/home_screen.dart';
// import '../grievance/grievance_details_screen.dart';
// import '../grievance/grievance_home.dart';
// import '../visit/whom_to_meet_screen.dart';
//
// class ParoleHomeScreen extends StatefulWidget {
//   final bool fromChatbot;
//   final int selectedIndex;
//
//   const ParoleHomeScreen({Key? key, this.fromChatbot = false, this.selectedIndex =0}) : super(key: key);
//
//   @override
//   _ParoleHomeScreenState createState() => _ParoleHomeScreenState();
// }
//
// class _ParoleHomeScreenState extends State<ParoleHomeScreen> {
//   late int _selectedIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.selectedIndex;
//   }
//
//   Future<bool> _onWillPop() async {
//     // If came from chatbot, allow normal back navigation
//     if (widget.fromChatbot) {
//       return true; // Allow back navigation to chatbot
//     }
//
//     // Otherwise show alert (normal app flow)
//     return await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Exit App'),
//         content: const Text('Please use Logout and close the App'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false), // Stay in app
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }
//
//   void _handleAppBarBack() {
//     if (widget.fromChatbot) {
//       // If came from chatbot, go back to chatbot (preserves chat history)
//       Navigator.pop(context);
//     } else {
//       // Normal app flow - show alert
//       _onWillPop();
//     }
//   }
//
//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     final isSelected = _selectedIndex == index;
//
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _selectedIndex = index;
//             ;
//           });
//           onTap();
//         },
//         child: Container(
//           height: 60,
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 color: isSelected ? Colors.white : Colors.white70,
//                 size: 24,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : Colors.white70,
//                   fontSize: 12,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           title: const Text('Parole'),
//           centerTitle: true,
//           backgroundColor: const Color(0xFF5A8BBA),
//           foregroundColor: Colors.black,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: _handleAppBarBack,
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.help_outline),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => PDFViewerScreen(
//                       assetPath: 'assets/pdfs/about_us.pdf',
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//
//         // ✅ Only show your meet form screen here
//         body: ParoleScreen(),
//
//         bottomNavigationBar: Container(
//           decoration: BoxDecoration(
//             color: const Color(0xFF5A8BBA),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 8,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: SafeArea(
//             child: SizedBox(
//               height: 60,
//               child: Row(
//                 children: [
//                   _buildNavItem(
//                     index: 0,
//                     icon: Icons.dashboard,
//                     label: 'Dashboard',
//                     onTap: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => HomeScreen(selectedIndex: 0),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildNavItem(
//                     index: 1,
//                     icon: Icons.directions_walk,
//                     label: 'Meeting',
//                     onTap: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => MeetFormScreen(selectedIndex: 1,showVisitCards: true,)),
//                       );
//                     },
//                   ),
//                   _buildNavItem(
//                     index: 2,
//                     icon: Icons.gavel,
//                     label: 'Parole',
//                     onTap: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ParoleHomeScreen(selectedIndex: 2),
//                         ),
//                       );
//                     },
//                   ),
//                   _buildNavItem(
//                     index: 3,
//                     icon: Icons.report_problem,
//                     label: 'Grievance',
//                     onTap: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => GrievanceDetailsScreen(selectedIndex: 3),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
