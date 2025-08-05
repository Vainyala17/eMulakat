import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import '../../models/visitor_model.dart';
import '../../services/auth_service.dart';
import '../../utils/color_scheme.dart';
import 'horizontal_visit_card.dart';
import 'notifications_screen.dart';

mixin HomeScreenLogic<T extends StatefulWidget> on State<T> {
  // State variables
  int selectedIndex = 0;
  bool isTtsEnabled = false;
  bool isAuthChecking = true;
  bool isAuthenticated = false;

  FlutterTts flutterTts = FlutterTts();
  SpeechToText speechToText = SpeechToText();

  double fontSize = 16.0;
  Color selectedColor = AppColors.primary;
  final translator = GoogleTranslator();
  String translatedWelcome = '';
  String translatedInstructions = '';

  final Map<String, String> languages = {
    'English': 'en',
    'Hindi': 'hi',
    'Marathi': 'mr',
  };

  VisitorModel? selectedVisitor;
  bool showPastVisits = true;
  bool isExpandedView = false;

  // Sample data
  List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      title: 'Visit Approved',
      message: 'Your visit request for Arthur Road Jail has been approved for Monday, 15:00-17:30',
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
      type: 'visit',
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Visit Reminder',
      message: 'You have an upcoming visit tomorrow at Yerwada Jail. Please arrive 30 minutes early.',
      timestamp: DateTime.now().subtract(Duration(hours: 5)),
      type: 'visit',
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      title: 'Grievance Update',
      message: 'Your grievance #GR-2024-001 has been reviewed and a response has been provided.',
      timestamp: DateTime.now().subtract(Duration(days: 1)),
      type: 'grievance',
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      title: 'System Maintenance',
      message: 'The system will be under maintenance on Sunday from 2:00 AM to 4:00 AM.',
      timestamp: DateTime.now().subtract(Duration(days: 2)),
      type: 'system',
      isRead: false,
    ),
    NotificationModel(
      id: '5',
      title: 'Visit Cancelled',
      message: 'Unfortunately, your visit scheduled for today has been cancelled due to security reasons.',
      timestamp: DateTime.now().subtract(Duration(days: 3)),
      type: 'visit',
      isRead: true,
    ),
    NotificationModel(
      id: '6',
      title: 'Grievance Cancelled',
      message: 'Unfortunately, your Grievance scheduled for today has been cancelled due to some reasons.',
      timestamp: DateTime.now().subtract(Duration(days: 3)),
      type: 'grievance',
      isRead: true,
    ),
    NotificationModel(
      id: '7',
      title: 'System Maintenance',
      message: 'The system will be under maintenance on Sunday from 5:00 PM to 7:00 PM.',
      timestamp: DateTime.now().subtract(Duration(hours: 1)),
      type: 'system',
      isRead: false,
    ),
  ];

  List<VisitorModel> pastVisits = [
    VisitorModel(
      visitorName: 'Ravi Sharma',
      fatherName: 'Mahesh Sharma',
      address: '123 MG Road, Mumbai',
      gender: 'Male',
      age: 32,
      relation: 'Brother',
      idProof: 'Aadhar',
      idNumber: 'XXXX-XXXX-1234',
      isInternational: false,
      state: 'Maharashtra',
      jail: 'Arthur Road',
      visitDate: DateTime.now().subtract(Duration(days: 5)),
      additionalVisitors: 1,
      additionalVisitorNames: ['Sita Sharma'],
      prisonerName: 'Ramesh Sharma',
      prisonerFatherName: 'Naresh Sharma',
      prisonerAge: 40,
      prisonerGender: 'Male',
      mode: true,
      status: VisitStatus.rejected,
      startTime: '14:00',
      endTime: '16:30',
      dayOfWeek: 'Friday',
    ),
    VisitorModel(
      visitorName: 'Anand Gupta',
      fatherName: 'Mahesh Gupta',
      address: '123 MG Road, Mumbai',
      gender: 'Male',
      age: 32,
      relation: 'Brother',
      idProof: 'Aadhar',
      idNumber: 'XXXX-XXXX-1234',
      isInternational: false,
      state: 'Maharashtra',
      jail: 'Arthur Road',
      visitDate: DateTime.now().subtract(Duration(days: 5)),
      additionalVisitors: 1,
      additionalVisitorNames: ['Sita Sharma'],
      prisonerName: 'Ramesh Sharma',
      prisonerFatherName: 'Naresh Sharma',
      prisonerAge: 40,
      prisonerGender: 'Male',
      mode: true,
      status: VisitStatus.approved,
      startTime: '9:30',
      endTime: '11:00',
      dayOfWeek: 'Monday',
    ),
    VisitorModel(
      visitorName: 'Vishal Mali',
      fatherName: 'Mahesh Mali',
      address: '123 MG Road, Mumbai',
      gender: 'Male',
      age: 32,
      relation: 'Brother',
      idProof: 'Aadhar',
      idNumber: 'XXXX-XXXX-1234',
      isInternational: false,
      state: 'Maharashtra',
      jail: 'Arthur Road',
      visitDate: DateTime.now().subtract(Duration(days: 5)),
      additionalVisitors: 1,
      additionalVisitorNames: ['Sita Sharma'],
      prisonerName: 'Ramesh Sharma',
      prisonerFatherName: 'Naresh Sharma',
      prisonerAge: 40,
      prisonerGender: 'Male',
      mode: true,
      status: VisitStatus.rejected,
      startTime: '14:00',
      endTime: '16:30',
      dayOfWeek: 'Saturday',
    ),
    VisitorModel(
      visitorName: 'Ravi Sharma',
      fatherName: 'Mahesh Sharma',
      address: '123 MG Road, Mumbai',
      gender: 'Male',
      age: 32,
      relation: 'Brother',
      idProof: 'Aadhar',
      idNumber: 'XXXX-XXXX-1234',
      isInternational: false,
      state: 'Maharashtra',
      jail: 'Arthur Road',
      visitDate: DateTime.now().subtract(Duration(days: 5)),
      additionalVisitors: 1,
      additionalVisitorNames: ['Sita Sharma'],
      prisonerName: 'Ramesh Sharma',
      prisonerFatherName: 'Naresh Sharma',
      prisonerAge: 40,
      prisonerGender: 'Male',
      mode: true,
      status: VisitStatus.approved,
      startTime: '5:00',
      endTime: '7:30',
      dayOfWeek: 'Friday',
    ),
  ];

  List<VisitorModel> upcomingVisits = [
    VisitorModel(
      visitorName: 'Meena Gupta',
      fatherName: 'Raj Gupta',
      address: '5th Block, Pune',
      gender: 'Female',
      age: 29,
      relation: 'Wife',
      idProof: 'Voter ID',
      idNumber: 'VOT1234567',
      isInternational: false,
      state: 'Maharashtra',
      jail: 'Yerwada Jail',
      visitDate: DateTime.now().add(Duration(days: 3)),
      additionalVisitors: 0,
      additionalVisitorNames: [],
      prisonerName: 'Sunil Gupta',
      prisonerFatherName: 'Vinod Gupta',
      prisonerAge: 35,
      prisonerGender: 'Male',
      mode: false,
      status: VisitStatus.rejected,
      startTime: '4:00',
      endTime: '6:30',
      dayOfWeek: 'Friday',
    ),
    VisitorModel(
      visitorName: 'Shweta patel',
      fatherName: 'Ramraj Patel',
      address: '5th Block, Pune',
      gender: 'Female',
      age: 29,
      relation: 'Wife',
      idProof: 'Voter ID',
      idNumber: 'VOT1234567',
      isInternational: false,
      state: 'Maharashtra',
      jail: 'Yerwada Jail',
      visitDate: DateTime.now().add(Duration(days: 3)),
      additionalVisitors: 0,
      additionalVisitorNames: [],
      prisonerName: 'Sunil Gupta',
      prisonerFatherName: 'Vinod Gupta',
      prisonerAge: 35,
      prisonerGender: 'Male',
      mode: false,
      status: VisitStatus.pending,
      startTime: '1:00',
      endTime: '2:30',
      dayOfWeek: 'Wednesday',
    ),
    VisitorModel(
      visitorName: 'Meena Gupta',
      fatherName: 'Raj Gupta',
      address: '5th Block, Pune',
      gender: 'Female',
      age: 29,
      relation: 'Wife',
      idProof: 'Voter ID',
      idNumber: 'VOT1234567',
      isInternational: false,
      state: 'Maharashtra',
      jail: 'Yerwada Jail',
      visitDate: DateTime.now().add(Duration(days: 3)),
      additionalVisitors: 0,
      additionalVisitorNames: [],
      prisonerName: 'Sunil Gupta',
      prisonerFatherName: 'Vinod Gupta',
      prisonerAge: 35,
      prisonerGender: 'Male',
      mode: false,
      status: VisitStatus.rejected,
      startTime: '11:00',
      endTime: '13:30',
      dayOfWeek: 'Tuesday',
    ),
    VisitorModel(
      visitorName: 'Rani patil',
      fatherName: 'Raj Patil',
      address: '5th Block, Pune',
      gender: 'Female',
      age: 29,
      relation: 'Wife',
      idProof: 'Voter ID',
      idNumber: 'VOT1234567',
      isInternational: false,
      state: 'Maharashtra',
      jail: 'Yerwada Jail',
      visitDate: DateTime.now().add(Duration(days: 3)),
      additionalVisitors: 0,
      additionalVisitorNames: [],
      prisonerName: 'Sunil Gupta',
      prisonerFatherName: 'Vinod Gupta',
      prisonerAge: 35,
      prisonerGender: 'Male',
      mode: false,
      status: VisitStatus.approved,
      startTime: '15:00',
      endTime: '17:30',
      dayOfWeek: 'Monday',
    ),
    VisitorModel(
      visitorName: 'Shyam Roy',
      fatherName: 'Ram Roy',
      address: '5th Block, Pune',
      gender: 'Male',
      age: 29,
      relation: 'Wife',
      idProof: 'Voter ID',
      idNumber: 'VOT1234567',
      isInternational: false,
      state: 'Maharashtra',
      jail: 'Yerwada Jail',
      visitDate: DateTime.now().add(Duration(days: 3)),
      additionalVisitors: 0,
      additionalVisitorNames: [],
      prisonerName: 'Sunil Gupta',
      prisonerFatherName: 'Vinod Gupta',
      prisonerAge: 35,
      prisonerGender: 'Male',
      mode: false,
      status: VisitStatus.rejected,
      startTime: '14:00',
      endTime: '16:30',
      dayOfWeek: 'Friday',
    ),
  ];

  @override
  void initState() {
    super.initState();
    checkAuthentication();
    initializeTts();
    initializeStt();
  }

  // Authentication methods
  Future<void> checkAuthentication() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? specialUser = prefs.getString('special_user');

      if (specialUser == "7702000723") {
        setState(() {
          isAuthenticated = true;
          isAuthChecking = false;
        });
        return;
      }

      bool isValid = await AuthService.isTokenValid();

      if (mounted) {
        setState(() {
          isAuthenticated = isValid;
          isAuthChecking = false;
        });

        if (!isValid) {
          await AuthService.clearTokens();
          showSessionExpiredDialog();
        }
      }
    } catch (e) {
      print('Auth check error: $e');
      if (mounted) {
        setState(() {
          isAuthenticated = false;
          isAuthChecking = false;
        });
        showAuthErrorDialog();
      }
    }
  }

  void showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Session Expired'),
        content: Text('Your session has expired. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              redirectToLogin();
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  void showAuthErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Authentication Error'),
        content: Text('Unable to verify your session. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              redirectToLogin();
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  void redirectToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
          (route) => false,
    );
  }

  Future<void> handleLogout() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout Confirmation'),
        content: Text('Are you sure you want to logout?'),
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

    if (confirmLogout == true) {
      await AuthService.logout(context); // <-- this is important
    }
  }

  // TTS and Speech methods
  Future<void> initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> initializeStt() async {
    bool available = await speechToText.initialize();
    if (available) {
      setState(() {});
    }
  }

  void speak(String text) async {
    flutterTts.setCompletionHandler(() {
      setState(() {
        isTtsEnabled = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        isTtsEnabled = false;
      });
    });

    await flutterTts.speak(text);
  }

  // Translation methods
  Future<void> translateAll(String langCode) async {
    final translator = GoogleTranslator();

    if (langCode == 'hi') {
      translatedWelcome = 'ई-मुलाकात में आपका स्वागत है';
    } else {
      final translated1 = await translator.translate('Welcome to E-Mulakat', to: langCode);
      translatedWelcome = translated1.text;
    }

    final translated2 = await translator.translate('Prison Visitor Management System', to: langCode);
    translatedInstructions = translated2.text;
    setState(() {});
  }

  // Utility methods
  String getDayOfWeek(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String getFormattedDate(DateTime date) {
    return '${date.day}';
  }

  String getMonthName(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  Color statusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.approved:
        return Colors.green;
      case VisitStatus.rejected:
        return Colors.red;
      case VisitStatus.pending:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(VisitStatus status) {
    switch (status) {
      case VisitStatus.approved:
        return 'Approved';
      case VisitStatus.rejected:
        return 'Rejected';
      case VisitStatus.pending:
        return 'Pending';
    }
  }

  // Notification methods
  int get unreadNotificationCount {
    return notifications.where((notification) => !notification.isRead).length;
  }

  void markNotificationAsRead(String notificationId) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = NotificationModel(
          id: notifications[index].id,
          title: notifications[index].title,
          message: notifications[index].message,
          timestamp: notifications[index].timestamp,
          type: notifications[index].type,
          isRead: true,
          actionUrl: notifications[index].actionUrl,
        );
      }
    });
  }

  // UI Builder methods
  Widget buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
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

  Widget buildVisitTypeCard(String title, int count, bool selected, VoidCallback onTap, {Icon? leadingIcon}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selected ? AppColors.primary : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          elevation: 2,
          color: selected ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: leadingIcon,
                  ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF121010),
                  ),
                ),
                const SizedBox(height: 6),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildVisitCardList(List<VisitorModel> visits) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visitor = visits[index];
          return HorizontalVisitCard(
            visitor: visitor,
            isSelected: selectedVisitor == visitor,
            onTap: () {
              setState(() {
                selectedVisitor = visitor;
                isExpandedView = true;
              });
            },
          );
        },
      ),
    );
  }

  // Session management
  void startPeriodicSessionCheck() {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      bool isValid = await AuthService.isTokenValid();
      if (!isValid) {
        timer.cancel();
        await AuthService.clearTokens();
        if (mounted) {
          showSessionExpiredDialog();
        }
      }
    });
  }
}