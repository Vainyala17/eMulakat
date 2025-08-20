import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import '../../models/visitor_model.dart';
import '../../utils/color_scheme.dart';
import '../../services/api_service.dart';
import 'home_screen.dart';
import 'vertical_visit_card.dart';

mixin HomeScreenLogic<T extends StatefulWidget> on State<T> {
  // State variables
  late int _selectedIndex;
  VisitorModel? selectedVisitor;
  bool isTtsEnabled = false;
  bool isAuthChecking = true;
  bool isAuthenticated = false;
  bool isLoading = true;
  String? errorMessage;

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

  String selectedVisitType = 'Meeting';
  String selectedStatus = 'All';

  Map<String, List<VisitorModel>> visitData = {
    'Meeting': [],
    'Parole': [],
    'Grievance': [],
  };

  // ✅ Fixed: Use lowercase keys to match API response
  Map<String, Map<String, int>> statusCounts = {
    'Meeting': {
      'pending': 0,
      'completed': 0,
      'upcoming': 0,
      'expired': 0,
      'total': 0,
    },
    'Parole': {
      'pending': 0,
      'completed': 0,
      'upcoming': 0,
      'expired': 0,
      'total': 0,
    },
    'Grievance': {
      'pending': 0,
      'completed': 0,
      'upcoming': 0,
      'expired': 0,
      'total': 0,
    },
  };

  String visitorMobileNumber = "7702000725";
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    initializeTts();
    initializeStt();
    _selectedIndex = (widget as HomeScreen).selectedIndex;
    _loadDashboardData();
  }

  // ✅ Improved error handling and loading logic
  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('📊 Starting to load dashboard data...');

      // Load dashboard summary first
      await _loadDashboardSummary();
      print('✅ Dashboard summary loaded');

      // Load detailed data for all visit types
      await _loadAllVisitTypes();
      print('✅ All visit types loaded');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        print('🎉 Dashboard data loading completed successfully!');
      }
    } catch (e) {
      print('❌ Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load data: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _loadDashboardSummary() async {
    try {
      final ApiService apiService = ApiService();
      final response = await apiService.getDashboardSummary(visitorMobileNumber);

      print('📡 Dashboard Summary Response: $response');

      if (response == null) {
        print('❌ Response is null');
        return;
      }

      // ✅ Parse Meeting data (inside dashboard object)
      if (response['dashboard']?.containsKey('meeting') == true) {
        final meetingData = response['dashboard']['meeting'];
        statusCounts['Meeting'] = {
          'pending': _parseCount(meetingData['pending']),
          'completed': _parseCount(meetingData['completed']), // Capital C from API
          'upcoming': _parseCount(meetingData['upcoming']),
          'expired': _parseCount(meetingData['expired']),
          'total': _parseCount(meetingData['total']),
        };
        print('✅ Meeting counts updated: ${statusCounts['Meeting']}');
      }

      // ✅ Parse Parole data (inside dashboard object)
      if (response['dashboard']?.containsKey('parole') == true) {
        final paroleData = response['dashboard']['parole'];
        statusCounts['Parole'] = {
          'pending': _parseCount(paroleData['pending']),
          'completed': _parseCount(paroleData['completed']), // Capital C from API
          'upcoming': _parseCount(paroleData['upcoming']),
          'expired': _parseCount(paroleData['expired']),
          'total': _parseCount(paroleData['total']),
        };
        print('✅ Parole counts updated: ${statusCounts['Parole']}');
      }

      // ✅ Parse Grievance data (at root level, not inside dashboard)
      if (response.containsKey('grievance')) {
        final grievanceData = response['grievance'];
        statusCounts['Grievance'] = {
          'pending': _parseCount(grievanceData['pending']),
          'completed': _parseCount(grievanceData['completed']), // Capital C from API
          'upcoming': _parseCount(grievanceData['upcoming']),
          'expired': _parseCount(grievanceData['expired']),
          'total': _parseCount(grievanceData['total']),
        };
        print('✅ Grievance counts updated: ${statusCounts['Grievance']}');
      }

      print('📊 Final Status Counts: $statusCounts');

    } catch (e) {
      print('❌ Error loading dashboard summary: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // ✅ Helper method to safely parse counts
  int _parseCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ✅ Improved parallel loading with better error handling
  Future<void> _loadAllVisitTypes() async {
    try {
      final results = await Future.wait([
        _loadVisitTypeData('Meeting').catchError((e) {
          print('❌ Error loading Meeting data: $e');
          return null;
        }),
        _loadVisitTypeData('Parole').catchError((e) {
          print('❌ Error loading Parole data: $e');
          return null;
        }),
        _loadVisitTypeData('Grievance').catchError((e) {
          print('❌ Error loading Grievance data: $e');
          return null;
        }),
      ]);

      print('✅ All visit type data loaded successfully');
    } catch (e) {
      print('❌ Error in _loadAllVisitTypes: $e');
      // Continue anyway with partial data
    }
  }

  // ✅ Better error handling for individual visit types
  Future<void> _loadVisitTypeData(String visitType) async {
    try {
      print('📡 Loading $visitType data...');

      final ApiService apiService = ApiService();
      final response = await apiService.getDashboardDetailedData(visitType);

      print('📡 $visitType Response: $response');

      if (response != null && response['header'] != null && response['header']['data'] != null) {
        final List<dynamic> dataList = response['header']['data'];
        print('📊 Found ${dataList.length} $visitType records');

        List<VisitorModel> visitors = dataList.map((item) {
          try {
            return _createVisitorModelFromApi(item, visitType);
          } catch (e) {
            print('❌ Error parsing $visitType item: $e');
            print('📄 Item data: $item');
            return null;
          }
        }).where((visitor) => visitor != null).cast<VisitorModel>().toList();

        visitData[visitType] = visitors;
        print('✅ $visitType data loaded: ${visitors.length} records');
      } else {
        print('⚠️ No data found for $visitType');
        visitData[visitType] = [];
      }
    } catch (e) {
      print('❌ Error loading $visitType data: $e');
      visitData[visitType] = []; // Set empty list on error
      rethrow;
    }
  }

  // ✅ Improved data parsing with better error handling
  VisitorModel _createVisitorModelFromApi(Map<String, dynamic> apiData, String visitType) {
    try {
      // Convert request_status to VisitStatus enum
      VisitStatus status = _parseVisitStatus(apiData['request_status']?.toString() ?? 'pending');

      // Parse dates based on visit type
      DateTime visitDate;
      if (visitType == 'Parole') {
        visitDate = _parseDate(apiData['leave_from_date'] ?? '');
      } else {
        visitDate = _parseDate(apiData['req_visit_date'] ?? '');
      }

      return VisitorModel(
        id: apiData['regn_no']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        visitorName: 'Visitor', // This should come from user session
        prisonerName: apiData['prisoner_name']?.toString() ?? 'Unknown Prisoner',
        prisonerFatherName: apiData['father_name']?.toString() ?? '',
        relation: 'Family', // Default or from API if available
        visitDate: visitDate,
        startTime: '10:00',
        endTime: '12:00',
        jail: 'Central Jail',
        address: apiData['spent_address']?.toString() ?? '',
        mode: (apiData['meeting_mode']?.toString().toLowerCase() == 'physical'),
        status: status,
        // Additional fields for different visit types
        leaveFromDate: apiData['leave_from_date']?.toString(),
        leaveToDate: apiData['leave_to_date']?.toString(),
        reason: apiData['reason']?.toString(),
        grievanceCategory: apiData['grievance_category']?.toString(),
        grievance: apiData['grievance']?.toString(),
        meetingMode: apiData['meeting_mode']?.toString(),
        reqVisitDate: apiData['req_visit_date']?.toString(),
        apprVisitDate: apiData['appr_visit_date']?.toString(),
        remarks: apiData['remarks']?.toString(),
        // Required fields with defaults
        fatherName: '',
        gender: '',
        age: 0,
        idProof: '',
        idNumber: '',
        isInternational: false,
        state: '',
        additionalVisitors: 0,
        additionalVisitorNames: [],
        prisonerAge: 0,
        prisonerGender: '',
        dayOfWeek: '',
        prison: '',
      );
    } catch (e) {
      print('❌ Error creating VisitorModel from API data: $e');
      print('📄 API Data: $apiData');
      rethrow;
    }
  }

  VisitStatus _parseVisitStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return VisitStatus.pending;
      case 'completed':
        return VisitStatus.completed;
      case 'upcoming':
        return VisitStatus.upcoming;
      case 'expired':
        return VisitStatus.expired;
      default:
        return VisitStatus.pending;
    }
  }

  DateTime _parseDate(String dateString) {
    if (dateString.isEmpty) return DateTime.now();

    try {
      // Handle DD/MM/YYYY format from your API
      List<String> parts = dateString.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }

      // Fallback: Try ISO format
      return DateTime.parse(dateString);
    } catch (e) {
      print('❌ Error parsing date: $dateString - $e');
      return DateTime.now();
    }
  }

  // ✅ Improved refresh with loading state
  Future<void> refreshData() async {
    print('🔄 Refreshing dashboard data...');
    await _loadDashboardData();
  }

  // TTS and Speech methods (unchanged)
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

  // Translation methods (unchanged)
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

  // Utility methods (unchanged)
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

  // Notification methods (unchanged)
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

  // ✅ Fixed: Use proper key names for status counts
  Widget buildVisitTypeCard(String title, int count, bool selected, VoidCallback onTap, {Image? leadingIcon}) {
    int apiCount = statusCounts[title]?['total'] ?? 0;

    return SizedBox(
      width: 150,
      height: 150,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedVisitType = title;
            selectedStatus = 'All';
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
                    apiCount.toString(),
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

  // ✅ Fixed: Use proper key names for status counts
  Widget buildStatusCard(String title, int count, String iconType, bool selected, VoidCallback onTap) {
    Color iconColor;
    String imagePath;

    // Get count from API data based on current visit type
    int apiCount = 0;
    String statusKey = title.toLowerCase();
    if (statusKey == 'all') {
      apiCount = statusCounts[selectedVisitType]?['total'] ?? 0;
    } else {
      // Map the status correctly
      if (statusKey == 'completed') {
        apiCount = statusCounts[selectedVisitType]?['completed'] ?? 0;
      } else {
        apiCount = statusCounts[selectedVisitType]?[statusKey] ?? 0;
      }
    }

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
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
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
                apiCount.toString(),
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

  Widget buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading data...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            errorMessage ?? 'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget buildVerticalVisitsList() {
    if (isLoading) {
      return buildLoadingWidget();
    }

    if (errorMessage != null) {
      return buildErrorWidget();
    }

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
          sourceType: selectedVisitType,
          onTap: () {
            print('Selected ${selectedVisitType}: ${visitor.visitorName}');
          },
        );
      }).toList(),
    );
  }
}