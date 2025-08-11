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
    initializeVisitData();
    _selectedIndex = (widget as HomeScreen).selectedIndex;
  }

  void initializeVisitData() {
    // Sample Meeting data
    visitData['Meeting'] = [
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
        visitDate: DateTime.now().add(Duration(days: 5)),
        additionalVisitors: 1,
        additionalVisitorNames: ['Sita Sharma'],
        prisonerName: 'Ramesh Sharma',
        prisonerFatherName: 'Naresh Sharma',
        prisonerAge: 40,
        prisonerGender: 'Male',
        mode: true,
        status: VisitStatus.pending,
        startTime: '14:00',
        endTime: '16:30',
        dayOfWeek: 'Friday',
      ),
      VisitorModel(
        visitorName: 'Anand Gupta',
        fatherName: 'Mahesh Gupta',
        address: '456 FC Road, Pune',
        gender: 'Male',
        age: 28,
        relation: 'Son',
        idProof: 'Aadhar',
        idNumber: 'XXXX-XXXX-5678',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Yerwada Jail',
        visitDate: DateTime.now().add(Duration(days: 2)),
        additionalVisitors: 0,
        additionalVisitorNames: [],
        prisonerName: 'Suresh Gupta',
        prisonerFatherName: 'Ramesh Gupta',
        prisonerAge: 55,
        prisonerGender: 'Male',
        mode: false,
        status: VisitStatus.completed,
        startTime: '10:00',
        endTime: '12:00',
        dayOfWeek: 'Wednesday',
      ),
      VisitorModel(
        visitorName: 'Meena Patel',
        fatherName: 'Raj Patel',
        address: '789 SB Road, Pune',
        gender: 'Female',
        age: 45,
        relation: 'Mother',
        idProof: 'Voter ID',
        idNumber: 'VOT9876543',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Pune Central Jail',
        visitDate: DateTime.now().add(Duration(days: 1)),
        additionalVisitors: 1,
        additionalVisitorNames: ['Kiran Patel'],
        prisonerName: 'Amit Patel',
        prisonerFatherName: 'Raj Patel',
        prisonerAge: 25,
        prisonerGender: 'Male',
        mode: true,
        status: VisitStatus.upcoming,
        startTime: '09:00',
        endTime: '17:00',
        dayOfWeek: 'Monday',
      ),
      VisitorModel(
        visitorName: 'Sunita Roy',
        fatherName: 'Bimal Roy',
        address: '321 MG Road, Nagpur',
        gender: 'Female',
        age: 38,
        relation: 'Wife',
        idProof: 'Passport',
        idNumber: 'P1234567',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Nagpur Central Jail',
        visitDate: DateTime.now().subtract(Duration(days: 3)),
        additionalVisitors: 0,
        additionalVisitorNames: [],
        prisonerName: 'Rajesh Roy',
        prisonerFatherName: 'Mohan Roy',
        prisonerAge: 42,
        prisonerGender: 'Male',
        mode: false,
        status: VisitStatus.expired,
        startTime: '11:00',
        endTime: '13:00',
        dayOfWeek: 'Thursday',
      ),
    ];

    // Sample Parole data
    visitData['Parole'] = [
      VisitorModel(
        visitorName: 'Meena Patel',
        fatherName: 'Raj Patel',
        address: '789 SB Road, Pune',
        gender: 'Female',
        age: 45,
        relation: 'Mother',
        idProof: 'Voter ID',
        idNumber: 'VOT9876543',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Pune Central Jail',
        visitDate: DateTime.now().add(Duration(days: 7)),
        additionalVisitors: 1,
        additionalVisitorNames: ['Kiran Patel'],
        prisonerName: 'Amit Patel',
        prisonerFatherName: 'Raj Patel',
        prisonerAge: 25,
        prisonerGender: 'Male',
        mode: true,
        status: VisitStatus.pending,
        startTime: '09:00',
        endTime: '17:00',
        dayOfWeek: 'Monday',
      ),
      VisitorModel(
        visitorName: 'Krishna Kumar',
        fatherName: 'Ram Kumar',
        address: '456 MG Road, Mumbai',
        gender: 'Male',
        age: 35,
        relation: 'Brother',
        idProof: 'Aadhar',
        idNumber: 'XXXX-XXXX-9876',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Arthur Road',
        visitDate: DateTime.now().subtract(Duration(days: 1)),
        additionalVisitors: 0,
        additionalVisitorNames: [],
        prisonerName: 'Vishnu Kumar',
        prisonerFatherName: 'Shyam Kumar',
        prisonerAge: 30,
        prisonerGender: 'Male',
        mode: false,
        status: VisitStatus.completed,
        startTime: '14:00',
        endTime: '16:00',
        dayOfWeek: 'Sunday',
      ),
      VisitorModel(
        visitorName: 'Krishna Kumar',
        fatherName: 'Ram Kumar',
        address: '456 MG Road, Mumbai',
        gender: 'Male',
        age: 35,
        relation: 'Brother',
        idProof: 'Aadhar',
        idNumber: 'XXXX-XXXX-9876',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Arthur Road',
        visitDate: DateTime.now().subtract(Duration(days: 1)),
        additionalVisitors: 0,
        additionalVisitorNames: [],
        prisonerName: 'Vishnu Kumar',
        prisonerFatherName: 'Shyam Kumar',
        prisonerAge: 30,
        prisonerGender: 'Male',
        mode: false,
        status: VisitStatus.expired,
        startTime: '14:00',
        endTime: '16:00',
        dayOfWeek: 'Sunday',
      ),
    ];

    // Sample Grievance data
    visitData['Grievance'] = [
      VisitorModel(
        visitorName: 'Sunita Roy',
        fatherName: 'Bimal Roy',
        address: '321 MG Road, Nagpur',
        gender: 'Female',
        age: 38,
        relation: 'Wife',
        idProof: 'Passport',
        idNumber: 'P1234567',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Nagpur Central Jail',
        visitDate: DateTime.now().subtract(Duration(days: 3)),
        additionalVisitors: 0,
        additionalVisitorNames: [],
        prisonerName: 'Rajesh Roy',
        prisonerFatherName: 'Mohan Roy',
        prisonerAge: 42,
        prisonerGender: 'Male',
        mode: false,
        status: VisitStatus.expired,
        startTime: '11:00',
        endTime: '13:00',
        dayOfWeek: 'Thursday',
      ),
      VisitorModel(
        visitorName: 'Priya Singh',
        fatherName: 'Raj Singh',
        address: '567 Park Street, Mumbai',
        gender: 'Female',
        age: 29,
        relation: 'Sister',
        idProof: 'Driving License',
        idNumber: 'DL1234567890',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Arthur Road',
        visitDate: DateTime.now().add(Duration(days: 3)),
        additionalVisitors: 1,
        additionalVisitorNames: ['Rahul Singh'],
        prisonerName: 'Vikram Singh',
        prisonerFatherName: 'Mohan Singh',
        prisonerAge: 32,
        prisonerGender: 'Male',
        mode: true,
        status: VisitStatus.pending,
        startTime: '15:00',
        endTime: '17:00',
        dayOfWeek: 'Thursday',
      ),
      VisitorModel(
        visitorName: 'Kavita Desai',
        fatherName: 'Suresh Desai',
        address: '890 Link Road, Thane',
        gender: 'Female',
        age: 42,
        relation: 'Mother',
        idProof: 'Voter ID',
        idNumber: 'VOT7890123',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Thane Jail',
        visitDate: DateTime.now().add(Duration(days: 1)),
        additionalVisitors: 0,
        additionalVisitorNames: [],
        prisonerName: 'Rohit Desai',
        prisonerFatherName: 'Suresh Desai',
        prisonerAge: 22,
        prisonerGender: 'Male',
        mode: false,
        status: VisitStatus.upcoming,
        startTime: '10:00',
        endTime: '12:00',
        dayOfWeek: 'Tuesday',
      ),
      VisitorModel(
        visitorName: 'Deepak Joshi',
        fatherName: 'Ramesh Joshi',
        address: '234 Hill Road, Bandra',
        gender: 'Male',
        age: 55,
        relation: 'Father',
        idProof: 'Passport',
        idNumber: 'P9876543',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Byculla Jail',
        visitDate: DateTime.now().subtract(Duration(days: 5)),
        additionalVisitors: 1,
        additionalVisitorNames: ['Sunita Joshi'],
        prisonerName: 'Arun Joshi',
        prisonerFatherName: 'Ramesh Joshi',
        prisonerAge: 28,
        prisonerGender: 'Male',
        mode: true,
        status: VisitStatus.completed,
        startTime: '13:00',
        endTime: '15:00',
        dayOfWeek: 'Wednesday',
      ),
    ];
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

  // UI Builder methods
  Widget buildNavItem({
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
          padding: EdgeInsets.symmetric(vertical: 3),
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
          onTap: () {
            print('Selected visit: ${visitor.visitorName}');
          },
        );
      }).toList(),
    );
  }
}