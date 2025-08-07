//
// import 'dart:async';
//
// import 'package:eMulakat/screens/home/vertical_visit_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:speech_to_text/speech_to_text.dart';
// import '../../dashboard/evisitor_pass_screen.dart';
// import '../../dashboard/grievance/grievance_home.dart';
// import '../../dashboard/visit/visit_home.dart';
// import '../../models/visitor_model.dart';
// import '../../services/auth_service.dart';
// import 'chatbot_screen.dart';
// import 'drawer_menu.dart';
// import '../../utils/color_scheme.dart';
// import 'package:translator/translator.dart';
//
// import 'horizontal_visit_card.dart';
// import 'notifications_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;
//   bool _isTtsEnabled = false;
//   bool _isAuthChecking = true; // Add this flag
//   bool _isAuthenticated = false; // Add this flag
//
//   FlutterTts flutterTts = FlutterTts();
//   SpeechToText speechToText = SpeechToText();
//
//   double _fontSize = 16.0;
//   Color _selectedColor = AppColors.primary;
//   final translator = GoogleTranslator();
//   String translatedWelcome = '';
//   String translatedInstructions = '';
//   final Map<String, String> _languages = {
//     'English': 'en',
//     'Hindi': 'hi',
//     'Marathi': 'mr',
//   };
//
//   Future<void> _translateAll(String langCode) async {
//     final translator = GoogleTranslator();
//
//     // Handle "Welcome to E-Mulakat" manually for Hindi
//     if (langCode == 'hi') {
//       translatedWelcome = 'ई-मुलाकात में आपका स्वागत है';
//     } else {
//       final translated1 = await translator.translate('Welcome to E-Mulakat', to: langCode);
//       translatedWelcome = translated1.text;
//     }
//
//     // This will always use auto translation
//     final translated2 = await translator.translate('Prison Visitor Management System', to: langCode);
//     translatedInstructions = translated2.text;
//     setState(() {});
//   }
//
//   VisitorModel? selectedVisitor;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthentication(); // Check auth first
//     _initializeTts();
//     _initializeStt();
//   }
//
//   _initializeTts() async {
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setSpeechRate(0.5);
//     await flutterTts.setVolume(1.0);
//     await flutterTts.setPitch(1.0);
//   }
//
//   _initializeStt() async {
//     bool available = await speechToText.initialize();
//     if (available) {
//       setState(() {});
//     }
//   }
//
//   void _speak(String text) async {
//     // Set up completion handler before speaking
//     flutterTts.setCompletionHandler(() {
//       setState(() {
//         _isTtsEnabled = false; // Automatically disable TTS after speaking
//       });
//     });
//
//     // Set up error handler
//     flutterTts.setErrorHandler((msg) {
//       setState(() {
//         _isTtsEnabled = false; // Disable TTS on error
//       });
//     });
//
//     await flutterTts.speak(text);
//   }
//
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
//           });
//           onTap();
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 8),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: Colors.white,
//               ),
//               SizedBox(height: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Improved authentication check
//   Future<void> _checkAuthentication() async {
//     try {
//       // First check if it's the special user (sir's number)
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? specialUser = prefs.getString('special_user');
//
//       if (specialUser == "7702000723") {
//         // Special user - allow access
//         setState(() {
//           _isAuthenticated = true;
//           _isAuthChecking = false;
//         });
//         return;
//       }
//
//       // Regular JWT token validation
//       bool isValid = await AuthService.isTokenValid();
//
//       if (mounted) {
//         setState(() {
//           _isAuthenticated = isValid;
//           _isAuthChecking = false;
//         });
//
//         if (!isValid) {
//           await AuthService.clearTokens();
//           _showSessionExpiredDialog();
//         }
//       }
//     } catch (e) {
//       print('Auth check error: $e');
//       if (mounted) {
//         setState(() {
//           _isAuthenticated = false;
//           _isAuthChecking = false;
//         });
//         _showAuthErrorDialog();
//       }
//     }
//   }
//
//   void _showSessionExpiredDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text('Session Expired'),
//         content: Text('Your session has expired. Please login again.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _redirectToLogin();
//             },
//             child: Text('Login'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAuthErrorDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text('Authentication Error'),
//         content: Text('Unable to verify your session. Please login again.'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               _redirectToLogin();
//             },
//             child: Text('Login'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _redirectToLogin() {
//     Navigator.of(context).pushNamedAndRemoveUntil(
//       '/login', // Make sure this route exists in your main.dart
//           (route) => false,
//     );
//   }
//
//   // Add periodic session check
//   void _startPeriodicSessionCheck() {
//     Timer.periodic(Duration(minutes: 5), (timer) async {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//
//       bool isValid = await AuthService.isTokenValid();
//       if (!isValid) {
//         timer.cancel();
//         await AuthService.clearTokens();
//         if (mounted) {
//           _showSessionExpiredDialog();
//         }
//       }
//     });
//   }
//
//   // Add method to handle logout from anywhere in the app
//   Future<void> _handleLogout() async {
//     bool confirmLogout = await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Logout Confirmation'),
//         content: Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: Text('Logout'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmLogout == true) {
//       await AuthService.logout(context);
//     }
//   }
//
//   String getDayOfWeek(DateTime date) {
//     const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
//     return days[date.weekday - 1];
//   }
//
//   String getFormattedDate(DateTime date) {
//     return '${date.day}';
//   }
//
//   String getMonthName(DateTime date) {
//     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     return months[date.month - 1];
//   }
//
//   Color statusColor(VisitStatus status) {
//     switch (status) {
//       case VisitStatus.approved:
//         return Colors.green;
//       case VisitStatus.rejected:
//         return Colors.red;
//       case VisitStatus.pending:
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }
//
//   // Fixed: Create a method that takes status as parameter
//   String getStatusText(VisitStatus status) {
//     switch (status) {
//       case VisitStatus.approved:
//         return 'Approved';
//       case VisitStatus.rejected:
//         return 'Rejected';
//       case VisitStatus.pending:
//         return 'Pending';
//     }
//   }
//
//   List<NotificationModel> notifications = [
//     NotificationModel(
//       id: '1',
//       title: 'Visit Approved',
//       message: 'Your visit request for Arthur Road Jail has been approved for Monday, 15:00-17:30',
//       timestamp: DateTime.now().subtract(Duration(hours: 2)),
//       type: 'visit',
//       isRead: false,
//     ),
//     NotificationModel(
//       id: '2',
//       title: 'Visit Reminder',
//       message: 'You have an upcoming visit tomorrow at Yerwada Jail. Please arrive 30 minutes early.',
//       timestamp: DateTime.now().subtract(Duration(hours: 5)),
//       type: 'visit',
//       isRead: false,
//     ),
//     NotificationModel(
//       id: '3',
//       title: 'Grievance Update',
//       message: 'Your grievance #GR-2024-001 has been reviewed and a response has been provided.',
//       timestamp: DateTime.now().subtract(Duration(days: 1)),
//       type: 'grievance',
//       isRead: true,
//     ),
//     NotificationModel(
//       id: '4',
//       title: 'System Maintenance',
//       message: 'The system will be under maintenance on Sunday from 2:00 AM to 4:00 AM.',
//       timestamp: DateTime.now().subtract(Duration(days: 2)),
//       type: 'system',
//       isRead: false,
//     ),
//     NotificationModel(
//       id: '5',
//       title: 'Visit Cancelled',
//       message: 'Unfortunately, your visit scheduled for today has been cancelled due to security reasons.',
//       timestamp: DateTime.now().subtract(Duration(days: 3)),
//       type: 'visit',
//       isRead: true,
//     ),
//     NotificationModel(
//       id: '6',
//       title: 'Grievance Cancelled',
//       message: 'Unfortunately, your  Grievance scheduled for today has been cancelled due to some reasons.',
//       timestamp: DateTime.now().subtract(Duration(days: 3)),
//       type: 'grievance',
//       isRead: true,
//     ),
//     NotificationModel(
//       id: '7',
//       title: 'System Maintenance',
//       message: 'The system will be under maintenance on Sunday from 5:00 PM to 7:00 PM.',
//       timestamp: DateTime.now().subtract(Duration(hours: 1)),
//       type: 'system',
//       isRead: false,
//     ),
//   ];
//
//   int get unreadNotificationCount {
//     return notifications.where((notification) => !notification.isRead).length;
//   }
//
// // Method to mark notification as read
//   void markNotificationAsRead(String notificationId) {
//     setState(() {
//       final index = notifications.indexWhere((n) => n.id == notificationId);
//       if (index != -1) {
//         notifications[index] = NotificationModel(
//           id: notifications[index].id,
//           title: notifications[index].title,
//           message: notifications[index].message,
//           timestamp: notifications[index].timestamp,
//           type: notifications[index].type,
//           isRead: true,
//           actionUrl: notifications[index].actionUrl,
//         );
//       }
//     });
//   }
//   bool showPastVisits = true;
//   bool isExpandedView = false;
//
//   List<VisitorModel> pastVisits = [
//     VisitorModel(
//       visitorName: 'Ravi Sharma',
//       fatherName: 'Mahesh Sharma',
//       address: '123 MG Road, Mumbai',
//       gender: 'Male',
//       age: 32,
//       relation: 'Brother',
//       idProof: 'Aadhar',
//       idNumber: 'XXXX-XXXX-1234',
//       isInternational: false,
//       state: 'Maharashtra',
//       jail: 'Arthur Road',
//       visitDate: DateTime.now().subtract(Duration(days: 5)),
//       additionalVisitors: 1,
//       additionalVisitorNames: ['Sita Sharma'],
//       prisonerName: 'Ramesh Sharma',
//       prisonerFatherName: 'Naresh Sharma',
//       prisonerAge: 40,
//       prisonerGender: 'Male',
//       mode: true,
//       status: VisitStatus.rejected,
//       startTime: '14:00',
//       endTime: '16:30',
//       dayOfWeek: 'Friday',
//     ),
//     VisitorModel(
//       visitorName: 'Anand Gupta',
//       fatherName: 'Mahesh Gupta',
//       address: '123 MG Road, Mumbai',
//       gender: 'Male',
//       age: 32,
//       relation: 'Brother',
//       idProof: 'Aadhar',
//       idNumber: 'XXXX-XXXX-1234',
//       isInternational: false,
//       state: 'Maharashtra',
//       jail: 'Arthur Road',
//       visitDate: DateTime.now().subtract(Duration(days: 5)),
//       additionalVisitors: 1,
//       additionalVisitorNames: ['Sita Sharma'],
//       prisonerName: 'Ramesh Sharma',
//       prisonerFatherName: 'Naresh Sharma',
//       prisonerAge: 40,
//       prisonerGender: 'Male',
//       mode: true,
//       status: VisitStatus.approved,
//       startTime: '9:30',
//       endTime: '11:00',
//       dayOfWeek: 'Monday',
//     ),
//     VisitorModel(
//       visitorName: 'Vishal Mali',
//       fatherName: 'Mahesh Mali',
//       address: '123 MG Road, Mumbai',
//       gender: 'Male',
//       age: 32,
//       relation: 'Brother',
//       idProof: 'Aadhar',
//       idNumber: 'XXXX-XXXX-1234',
//       isInternational: false,
//       state: 'Maharashtra',
//       jail: 'Arthur Road',
//       visitDate: DateTime.now().subtract(Duration(days: 5)),
//       additionalVisitors: 1,
//       additionalVisitorNames: ['Sita Sharma'],
//       prisonerName: 'Ramesh Sharma',
//       prisonerFatherName: 'Naresh Sharma',
//       prisonerAge: 40,
//       prisonerGender: 'Male',
//       mode: true,
//       status: VisitStatus.rejected,
//       startTime: '14:00',
//       endTime: '16:30',
//       dayOfWeek: 'Saturday',
//     ),
//     VisitorModel(
//       visitorName: 'Ravi Sharma',
//       fatherName: 'Mahesh Sharma',
//       address: '123 MG Road, Mumbai',
//       gender: 'Male',
//       age: 32,
//       relation: 'Brother',
//       idProof: 'Aadhar',
//       idNumber: 'XXXX-XXXX-1234',
//       isInternational: false,
//       state: 'Maharashtra',
//       jail: 'Arthur Road',
//       visitDate: DateTime.now().subtract(Duration(days: 5)),
//       additionalVisitors: 1,
//       additionalVisitorNames: ['Sita Sharma'],
//       prisonerName: 'Ramesh Sharma',
//       prisonerFatherName: 'Naresh Sharma',
//       prisonerAge: 40,
//       prisonerGender: 'Male',
//       mode: true,
//       status: VisitStatus.approved,
//       startTime: '5:00',
//       endTime: '7:30',
//       dayOfWeek: 'Friday',
//     ),
//   ];
//
//   List<VisitorModel> upcomingVisits = [
//     VisitorModel(
//       visitorName: 'Meena Gupta',
//       fatherName: 'Raj Gupta',
//       address: '5th Block, Pune',
//       gender: 'Female',
//       age: 29,
//       relation: 'Wife',
//       idProof: 'Voter ID',
//       idNumber: 'VOT1234567',
//       isInternational: false,
//       state: 'Maharashtra',
//       jail: 'Yerwada Jail',
//       visitDate: DateTime.now().add(Duration(days: 3)),
//       additionalVisitors: 0,
//       additionalVisitorNames: [],
//       prisonerName: 'Sunil Gupta',
//       prisonerFatherName: 'Vinod Gupta',
//       prisonerAge: 35,
//       prisonerGender: 'Male',
//       mode: false,
//       status: VisitStatus.rejected,
//       startTime: '4:00',
//       endTime: '6:30',
//       dayOfWeek: 'Friday',
//     ),
//     VisitorModel(
//       visitorName: 'Shweta patel',
//       fatherName: 'Ramraj Patel',
//       address: '5th Block, Pune',
//       gender: 'Female',
//       age: 29,
//       relation: 'Wife',
//       idProof: 'Voter ID',
//       idNumber: 'VOT1234567',
//       isInternational: false,
//       state: 'Maharashtra',
//       jail: 'Yerwada Jail',
//       visitDate: DateTime.now().add(Duration(days: 3)),
//       additionalVisitors: 0,
//       additionalVisitorNames: [],
//       prisonerName: 'Sunil Gupta',
//       prisonerFatherName: 'Vinod Gupta',
//       prisonerAge: 35,
//       prisonerGender: 'Male',
//       mode: false,
//       status: VisitStatus.pending,
//       startTime: '1:00',
//       endTime: '2:30',
//       dayOfWeek: 'Wednesday',
//     ),
//     VisitorModel(
//       visitorName: 'Meena Gupta',
//       fatherName: 'Raj Gupta',
//       address: '5th Block, Pune',
//       gender: 'Female',
//       age: 29,
//       relation: 'Wife',
//       idProof: 'Voter ID',
//       idNumber: 'VOT1234567',
//       isInternational: false,
//       state: 'Maharashtra',
//       jail: 'Yerwada Jail',
//       visitDate: DateTime.now().add(Duration(days: 3)),
//       additionalVisitors: 0,
//       additionalVisitorNames: [],
//       prisonerName: 'Sunil Gupta',
//       prisonerFatherName: 'Vinod Gupta',
//       prisonerAge: 35,
//       prisonerGender: 'Male',
//       mode: false,
//       status: VisitStatus.rejected,
//       startTime: '11:00',
//       endTime: '13:30',
//       dayOfWeek: 'Tuesday',
//     ),
//     VisitorModel(
//       visitorName: 'Rani patil',
//       fatherName: 'Raj Patil',
//       address: '5th Block, Pune',
//       gender: 'Female',
//       age: 29,
//       relation: 'Wife',
//       idProof: 'Voter ID',
//       idNumber: 'VOT1234567',
//       isInternational: false,
//       state: 'Maharashtra',
//       jail: 'Yerwada Jail',
//       visitDate: DateTime.now().add(Duration(days: 3)),
//       additionalVisitors: 0,
//       additionalVisitorNames: [],
//       prisonerName: 'Sunil Gupta',
//       prisonerFatherName: 'Vinod Gupta',
//       prisonerAge: 35,
//       prisonerGender: 'Male',
//       mode: false,
//       status: VisitStatus.approved,
//       startTime: '15:00',
//       endTime: '17:30',
//       dayOfWeek: 'Monday',
//     ),
//     VisitorModel(
//       visitorName: 'Shyam Roy',
//       fatherName: 'Ram Roy',
//       address: '5th Block, Pune',
//       gender: 'Male',
//       age: 29,
//       relation: 'Wife',
//       idProof: 'Voter ID',
//       idNumber: 'VOT1234567',
//       isInternational: false,
//       state: 'Maharashtra',
//       jail: 'Yerwada Jail',
//       visitDate: DateTime.now().add(Duration(days: 3)),
//       additionalVisitors: 0,
//       additionalVisitorNames: [],
//       prisonerName: 'Sunil Gupta',
//       prisonerFatherName: 'Vinod Gupta',
//       prisonerAge: 35,
//       prisonerGender: 'Male',
//       mode: false,
//       status: VisitStatus.rejected,
//       startTime: '14:00',
//       endTime: '16:30',
//       dayOfWeek: 'Friday',
//     ),
//   ];
//
//   Widget _buildVisitTypeCard(String title, int count, bool selected, VoidCallback onTap, {Icon? leadingIcon}) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: BorderSide(
//               color: selected ? AppColors.primary : Colors.grey.shade300,
//               width: selected ? 2 : 1,
//             ),
//           ),
//           elevation: 2,
//           color: selected ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade200,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (leadingIcon != null)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 6.0),
//                     child: leadingIcon,
//                   ),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                       color: Color(0xFF121010),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 CircleAvatar(
//                   backgroundColor: Colors.white,
//                   radius: 15, // smaller circle
//                   child: Text(
//                     '$count',
//                     style: TextStyle(
//                       color: AppColors.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
// // Also modify your _buildHorizontalVisitCards method to handle the selection:
//   Widget _buildVisitCardList(List<VisitorModel> visits) {
//     return SizedBox(
//       height: 220,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: visits.length,
//         itemBuilder: (context, index) {
//           final visitor = visits[index];
//           return HorizontalVisitCard(
//             visitor: visitor,
//             isSelected: selectedVisitor == visitor,
//             onTap: () {
//               setState(() {
//                 selectedVisitor = visitor;
//                 isExpandedView = true;
//               });
//             },
//           );
//         },
//       ),
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     // Show loading screen while checking authentication
//     if (_isAuthChecking) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Checking authentication...',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     // Show error screen if not authenticated
//     if (!_isAuthenticated) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.lock_outline,
//                 size: 64,
//                 color: Colors.grey[400],
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Authentication Required',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Please login to access the dashboard',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _redirectToLogin,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                 ),
//                 child: Text(
//                   'Go to Login',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     return WillPopScope(
//       onWillPop: () async {
//         bool exitConfirmed = await showDialog(
//           context: context,
//           builder: (context) =>
//             AlertDialog(
//               title: Text('Exit Confirmation'),
//               content: Text('Please use Logout and close the App.'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(false),
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(true),
//                   child: Text('Logout'),
//                 ),
//               ],
//             ),
//         );
//         return exitConfirmed;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: _selectedColor,
//           actions: [
//             // Font Size Controls
//             PopupMenuButton<double>(
//               icon: Icon(Icons.font_download),
//               onSelected: (size) {
//                 setState(() {
//                   _fontSize = size;
//                 });
//               },
//               itemBuilder: (context) => [
//                 PopupMenuItem(value: 12.0, child: Text('A-')),
//                 PopupMenuItem(value: 16.0, child: Text('A')),
//                 PopupMenuItem(value: 20.0, child: Text('A+')),
//               ],
//             ),
//
//             // Language Selection
//             PopupMenuButton<String>(
//               icon: Icon(Icons.language),
//               onSelected: (language) {
//                 final targetLangCode = _languages[language] ?? 'en';
//                 Future.delayed(Duration.zero, () => _translateAll(targetLangCode));
//               },
//               itemBuilder: (context) => _languages.keys.map((language) {
//                 return PopupMenuItem<String>(
//                   value: language,
//                   child: Text(language),
//                 );
//               }).toList(),
//             ),
//
//             // Text to Speech
//             IconButton(
//               icon: Icon(
//                 _isTtsEnabled ? Icons.volume_up : Icons.volume_off,
//                 color: Colors.black,
//               ),
//               onPressed: () {
//                 if (!_isTtsEnabled) {
//                   setState(() {
//                     _isTtsEnabled = true;
//                   });
//                   _speak('Welcome to eMulakat, Prison Visitor Management System');
//                 } else {
//                   setState(() {
//                     _isTtsEnabled = false;
//                   });
//                   flutterTts.stop();
//                 }
//               },
//             ),
//
//             // Notification Icon
//             Stack(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.notifications),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => NotificationScreen(
//                           notifications: notifications,
//                           onNotificationRead: markNotificationAsRead,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 if (unreadNotificationCount > 0)
//                   Positioned(
//                     right: 8,
//                     top: 8,
//                     child: Container(
//                       padding: EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       constraints: BoxConstraints(
//                         minWidth: 16,
//                         minHeight: 16,
//                       ),
//                       child: Text(
//                         '$unreadNotificationCount',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//         drawer: DrawerMenu(),
//         body: Column(
//           children: [
//             // Top content (Welcome text and visit type cards) - only show if not in expanded view
//             if (!isExpandedView)
//               Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       translatedWelcome.isNotEmpty ? translatedWelcome : 'Welcome to E-Mulakat',
//                       style: TextStyle(
//                         fontSize: _fontSize + 8,
//                         fontWeight: FontWeight.bold,
//                         color: _selectedColor,
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                     Text(
//                       translatedInstructions.isNotEmpty ? translatedInstructions : 'Prison Visitor Management System',
//                       style: TextStyle(
//                         fontSize: _fontSize + 2,
//                         color: Colors.black,
//                       ),
//                     ),
//                     SizedBox(height: 30),
//                     Row(
//                       children: [
//                         _buildVisitTypeCard(
//                           'Past Visits',
//                           pastVisits.length,
//                           showPastVisits,
//                               () {
//                             setState(() {
//                               showPastVisits = true;
//                               isExpandedView = false;
//                               selectedVisitor = null;
//                             });
//                           },
//                           leadingIcon: const Icon(Icons.all_inclusive, size: 25), // 👈 Added icon
//                         ),
//                         SizedBox(width: 10),
//                         _buildVisitTypeCard('Upcoming Visits', upcomingVisits.length, !showPastVisits, () {
//                           setState(() {
//                             showPastVisits = false;
//                             isExpandedView = false;
//                             selectedVisitor = null;
//                           });
//                         },
//                           leadingIcon: const Icon(Icons.upcoming, size: 25),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//
//             // Main content area
//             Expanded(
//               child: isExpandedView && selectedVisitor != null
//                   ? VisitDetailView(
//                 selectedVisitor: selectedVisitor!,
//                 pastVisits: pastVisits,
//                 upcomingVisits: upcomingVisits,
//                 onVisitorSelected: (visitor) {
//                   setState(() {
//                     selectedVisitor = visitor;
//                   });
//                 },
//               )
//                   : _buildVisitCardList(showPastVisits ? pastVisits : upcomingVisits),
//             ),
//
//             SizedBox(height: 30),
//             // E-Pass Button - always at bottom
//             Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Center(
//                 child: SizedBox(
//                   width: 160,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (selectedVisitor != null) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => eVisitorPassScreen(visitor: selectedVisitor!),
//                           ),
//                         );
//                       } else {
//                         showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: Text('No Visit Selected'),
//                             content: Text('Please select a visit before proceeding.'),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 child: Text('OK'),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       'eVisitor Pass',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => ChatbotScreen()),
//             );
//           },
//           child: Icon(Icons.chat_outlined,color: Color(0xFFFFFFFF),fontWeight: FontWeight.bold,),
//         ),
//         bottomNavigationBar: Container(
//           decoration: BoxDecoration(
//             color: Color(0xFF5A8BBA),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 8,
//                 offset: Offset(0, -2),
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
//                     icon: Icons.directions_walk,
//                     label: 'Visit',
//                     onTap: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => VisitHomeScreen()),
//                       );
//                     },
//                   ),
//                   _buildNavItem(
//                     index: 1,
//                     icon: Icons.dashboard,
//                     label: 'Dashboard',
//                     onTap: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => HomeScreen()),
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
//                         MaterialPageRoute(builder: (context) => GrievanceHomeScreen()),
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


import 'dart:async';
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
  Widget build(BuildContext context) {
    // Show loading screen while checking authentication
    if (isAuthChecking) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              SizedBox(height: 16),
              Text(
                'Checking authentication...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error screen if not authenticated
    if (!isAuthenticated) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                'Authentication Required',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please login to access the dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: redirectToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  'Go to Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        bool exitConfirmed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
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
                      translatedWelcome.isNotEmpty ? translatedWelcome : 'Welcome to E-Mulakat',
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
                    Row(
                      children: [
                        buildVisitTypeCard(
                          'Past Visits',
                          pastVisits.length,
                          showPastVisits,
                              () {
                            setState(() {
                              showPastVisits = true;
                              isExpandedView = false;
                              selectedVisitor = null;
                            });
                          },
                          leadingIcon: const Icon(Icons.all_inclusive, size: 25),
                        ),
                        SizedBox(width: 10),
                        buildVisitTypeCard(
                          'Upcoming Visits',
                          upcomingVisits.length,
                          !showPastVisits,
                              () {
                            setState(() {
                              showPastVisits = false;
                              isExpandedView = false;
                              selectedVisitor = null;
                            });
                          },
                          leadingIcon: const Icon(Icons.upcoming, size: 25),
                        ),
                      ],
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
          child: Icon(Icons.chat_outlined, color: Color(0xFFFFFFFF)),
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
                    icon: Icons.directions_walk,
                    label: 'Visit',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => VisitHomeScreen()),
                      );
                    },
                  ),
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