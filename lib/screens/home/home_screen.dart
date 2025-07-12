import 'package:e_mulakat/dashboard/grievance/grievance_home.dart';
import 'package:e_mulakat/models/visitor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../dashboard/visit/meet_form_screen.dart';
import '../../dashboard/visit/visit_home.dart';
import 'drawer_menu.dart';
import '../../utils/color_scheme.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  FlutterTts flutterTts = FlutterTts();
  SpeechToText speechToText = SpeechToText();

  String _selectedLanguage = 'English';
  double _fontSize = 16.0;
  Color _selectedColor = AppColors.primary;
  // Remove the problematic late field
  // late final VisitStatus status;

  final List<String> _languages = ['English', 'Hindi', 'Marathi'];
  final List<String> _colorOptions = [
    "edeeee", "5a8bba", "1e2226", "93a6aa", "817777",
    "39434d", "1f5278", "dd4b48", "545051", "526a5d"
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeStt();
  }

  _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  _initializeStt() async {
    bool available = await speechToText.initialize();
    if (available) {
      setState(() {});
    }
  }

  void _speak(String text) async {
    await flutterTts.speak(text);
  }

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

  void _listen() async {
    if (!speechToText.isListening) {
      bool available = await speechToText.initialize();
      if (available) {
        speechToText.listen(
          onResult: (result) {
            setState(() {
              // Handle speech result
            });
          },
        );
      }
    } else {
      speechToText.stop();
    }
  }

  bool showPastVisits = true;
  bool isExpandedView = false;

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
      isPhysicalVisit: true,
      status: VisitStatus.rejected,
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
      isPhysicalVisit: true,
      status: VisitStatus.approved,
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
      isPhysicalVisit: true,
      status: VisitStatus.rejected,
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
      isPhysicalVisit: true,
      status: VisitStatus.approved,
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
      isPhysicalVisit: false,
      status: VisitStatus.rejected,
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
      isPhysicalVisit: false,
      status: VisitStatus.pending,
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
      isPhysicalVisit: false,
      status: VisitStatus.rejected,
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
      isPhysicalVisit: false,
      status: VisitStatus.approved,
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
      isPhysicalVisit: false,
      status: VisitStatus.rejected,
    ),
  ];

  Widget _buildVisitTypeCard(String title, int count, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: selected ? AppColors.primary : Colors.grey[300],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : Colors.black)),
                SizedBox(height: 8),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text('$count',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitCard(VisitorModel visitor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visitor: ${visitor.visitorName}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Prisoner: ${visitor.prisonerName}'),
            Text('Date: ${visitor.visitDate.toLocal().toString().split(' ')[0]}'),
            Text('Jail: ${visitor.jail}'),
            Text('Mode: ${visitor.isPhysicalVisit ? "Physical" : "Virtual"}'),
          ],
        ),
      ),
    );
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

  // Fixed: Create a method that takes status as parameter
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

  // Updated horizontal visit cards with smaller height
  Widget _buildHorizontalVisitCards(List<VisitorModel> visits) {
    return SizedBox(
      height: 30, // Reduced from 130 to 100
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visitor = visits[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                isExpandedView = true;
              });
            },
            child: Card(
              color: AppColors.primary,
              margin: EdgeInsets.only(right: 12),
              child: Container(
                width: 140, // Reduced from 160 to 140
                padding: EdgeInsets.all(6), // Reduced from 12 to 8
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor(visitor.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        getStatusText(visitor.status), // Fixed: Use the method with parameter
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      visitor.visitorName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // Reduced font size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      visitor.prisonerName,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11, // Reduced font size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${visitor.visitDate.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10, // Reduced font size
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Updated vertical visit cards with status
  Widget _buildVerticalVisitCards(List<VisitorModel> visits) {
    return ListView.builder(
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visitor = visits[index];
        return Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge at the top
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor(visitor.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        getStatusText(visitor.status), // Fixed: Use the method with parameter
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      visitor.isPhysicalVisit ? 'Physical' : 'Virtual',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('${visitor.visitDate.toLocal().toString().split(' ')[0]}'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 16),
                    SizedBox(width: 8),
                    Text('Visitor: ${visitor.visitorName}'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.lock, size: 16),
                    SizedBox(width: 8),
                    Text('Prisoner: ${visitor.prisonerName}'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.location_city, size: 16),
                    SizedBox(width: 8),
                    Text('Jail: ${visitor.jail}'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.group, size: 16),
                    SizedBox(width: 8),
                    Text(visitor.additionalVisitors > 0
                        ? 'With ${visitor.additionalVisitors} more'
                        : 'No additional participants'),
                  ],
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VisitHomeScreen()),
                      );
                    },
                    child: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _selectedColor,
        actions: [
          // Font Size Controls
          PopupMenuButton<double>(
            icon: Icon(Icons.font_download),
            onSelected: (size) {
              setState(() {
                _fontSize = size;
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
              setState(() {
                _selectedLanguage = language;
              });
            },
            itemBuilder: (context) => _languages.map((language) {
              return PopupMenuItem(
                value: language,
                child: Text(language),
              );
            }).toList(),
          ),

          // Speech to Text
          IconButton(
            icon: Icon(speechToText.isListening ? Icons.mic : Icons.mic_none),
            onPressed: _listen,
          ),

          // Text to Speech
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: () => _speak('Welcome to eMulakat , Prison Visitor Management System'),
          ),

          // Notification Icon
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to eMulakat',
              style: TextStyle(
                fontSize: _fontSize + 8,
                fontWeight: FontWeight.bold,
                color: _selectedColor,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Prison Visitor Management System',
              style: TextStyle(
                fontSize: _fontSize + 2,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                _buildVisitTypeCard('Past Visits', pastVisits.length, showPastVisits, () {
                  setState(() {
                    showPastVisits = true;
                    isExpandedView = false;
                  });
                }),
                SizedBox(width: 10),
                _buildVisitTypeCard('Upcoming Visits', upcomingVisits.length, !showPastVisits, () {
                  setState(() {
                    showPastVisits = false;
                    isExpandedView = false;
                  });
                }),
              ],
            ),
            SizedBox(height: 20),

            // Dynamic View
            Expanded(
              child: isExpandedView
                  ? _buildVerticalVisitCards(showPastVisits ? pastVisits : upcomingVisits)
                  : _buildHorizontalVisitCards(showPastVisits ? pastVisits : upcomingVisits),
            ),

            SizedBox(width: 30),
            // E-Pass Button
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0), // Adds space top and bottom
              child: Center(
                child: SizedBox(
                  width: 140, // Controls button width
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Add navigation or action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'E-Pass',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
          child: Container(
            height: 60,
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.directions_walk,
                  label: 'Visit',
                  onTap: () {
                    Navigator.push(
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
                    Navigator.push(
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
                    Navigator.push(
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
    );
  }
}