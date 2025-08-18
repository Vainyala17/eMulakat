import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import '../../models/visitor_model.dart';
import '../../utils/color_scheme.dart';
import 'home_screen.dart';
import 'vertical_visit_card.dart';

mixin HomeScreenLogic<T extends StatefulWidget> on State<T> {
  // State variables
  late int _selectedIndex;
  VisitorModel? selectedVisitor;
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

  // Visit type selection
  String selectedVisitType = 'Meeting'; // Default selection
  String selectedStatus = 'All'; // Default status filter

  // Sample data for different visit types
  Map<String, List<VisitorModel>> visitData = {
    'Meeting': [],
    'Parole': [],
    'Grievance': [],
  };

  Map<String, Map<String, int>> statusCounts = {
    'Meeting': {
      'Pending': 2,
      'Upcoming': 3,
      'Completed': 5,
      'Expired': 1,
      'Total': 11,
    },
    'Parole': {
      'Pending': 1,
      'Upcoming': 0,
      'Completed': 2,
      'Expired': 0,
      'Total': 3,
    },
    'Grievance': {
      'Pending': 3,
      'Upcoming': 1,
      'Completed': 4,
      'Expired': 2,
      'Total': 10,
    },
  };

  // Sample notifications data
  List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      title: 'Visit completed',
      message: 'Your visit request for Arthur Road Jail has been completed for Monday, 15:00-17:30',
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
  ];

  @override
  void initState() {
    super.initState();
    initializeTts();
    initializeStt();
    _selectedIndex = (widget as HomeScreen).selectedIndex;
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
      case VisitStatus.completed:
        return Colors.green;
      case VisitStatus.expired:
        return Colors.red;
      case VisitStatus.pending:
        return Colors.orange;
      case VisitStatus.upcoming:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(VisitStatus status) {
    switch (status) {
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.expired:
        return 'Expired';
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.upcoming:
        return 'Upcoming';
      default:
        return 'null';
    }
  }

  // Get filtered visits based on selected status
  List<VisitorModel> getFilteredVisits() {
    List<VisitorModel> currentVisits = visitData[selectedVisitType] ?? [];

    if (selectedStatus == 'All') {
      return currentVisits;
    }

    VisitStatus statusFilter;
    switch (selectedStatus) {
      case 'Pending':
        statusFilter = VisitStatus.pending;
        break;
      case 'Upcoming':
        statusFilter = VisitStatus.upcoming;
        break;
      case 'Completed':
        statusFilter = VisitStatus.completed;
        break;
      case 'Expired':
        statusFilter = VisitStatus.expired;
        break;
      default:
        return currentVisits;
    }
    return currentVisits.where((visit) => visit.status == statusFilter).toList();
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

  Widget buildVisitTypeCard(String title, int count, bool selected, VoidCallback onTap, {Image? leadingIcon}) {
    return SizedBox(
      width: 150,
      height: 150,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedVisitType = title;
            selectedStatus = 'All'; // Reset status filter when changing visit type
          });
          onTap();
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selectedVisitType == title ? AppColors.primary : Colors.grey.shade300,
              width: selectedVisitType == title ? 2 : 1,
            ),
          ),
          elevation: 2,
          color: selectedVisitType == title ? AppColors.primary.withOpacity(0.2) : Colors.grey.shade200,
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
                    '${statusCounts[title]?['Total'] ?? 0}',
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

  Widget buildStatusCard(String title, int count, String iconType, bool selected, VoidCallback onTap) {
    Color iconColor;
    String imagePath;

    switch (iconType) {
      case 'pending':
        iconColor = Colors.orange;
        imagePath = 'assets/images/pending.png';
        break;
      case 'upcoming':
        iconColor = Colors.blue;
        imagePath = 'assets/images/upcoming.png';
        break;
      case 'completed':
        iconColor = Colors.green;
        imagePath = 'assets/images/completed.png';
        break;
      case 'expired':
        iconColor = Colors.red;
        imagePath = 'assets/images/expired.png';
        break;
      default:
        iconColor = Colors.black;
        imagePath = 'assets/images/total.png';
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? iconColor.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: selected ? iconColor : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // ✅ Black shadow
                blurRadius: 6, // Softness of shadow
                offset: const Offset(0, 3), // Position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Image.asset(
                imagePath,
                width: 24,
                height: 24,
                color: iconColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Update this method in your home_screen_logic.dart file
  Widget buildVerticalVisitsList() {
    List<VisitorModel> filteredVisits = getFilteredVisits();

    if (filteredVisits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No ${selectedStatus.toLowerCase()} ${selectedVisitType.toLowerCase()} found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredVisits.map((visitor) {
        return VerticalVisitCard(
          visitor: visitor,
          sourceType: selectedVisitType, // This will pass 'Meeting', 'Parole', or 'Grievance'
          onTap: () {
            print('Selected ${selectedVisitType}: ${visitor.visitorName}');
          },
        );
      }).toList(),
    );
  }
}