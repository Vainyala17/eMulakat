
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../dashboard/evisitor_pass_screen.dart';
import '../../dashboard/grievance/grievance_home.dart';
import '../../dashboard/visit/visit_preview_screen.dart';
import '../../dashboard/visit/whom_to_meet_screen.dart';
import '../../dashboard/visit/visit_home.dart';
import '../../models/visitor_model.dart';
import 'chatbot_screen.dart';
import 'drawer_menu.dart';
import '../../utils/color_scheme.dart';
import 'package:translator/translator.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  FlutterTts flutterTts = FlutterTts();
  SpeechToText speechToText = SpeechToText();

  double _fontSize = 16.0;
  Color _selectedColor = AppColors.primary;
  final translator = GoogleTranslator();
  String translatedWelcome = '';
  String translatedInstructions = '';
  final Map<String, String> _languages = {
    'English': 'en',
    'Hindi': 'hi',
    'Marathi': 'mr',
  };

  Future<void> _translateAll(String langCode) async {
    final translator = GoogleTranslator();

    // Handle "Welcome to E-Mulakat" manually for Hindi
    if (langCode == 'hi') {
      translatedWelcome = 'ई-मुलाकात में आपका स्वागत है';
    } else {
      final translated1 = await translator.translate('Welcome to E-Mulakat', to: langCode);
      translatedWelcome = translated1.text;
    }

    // This will always use auto translation
    final translated2 = await translator.translate('Prison Visitor Management System', to: langCode);
    translatedInstructions = translated2.text;
    setState(() {});
  }

  VisitorModel? selectedVisitor;

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

  Widget _buildHorizontalVisitCards(List<VisitorModel> visits) {
    return Container(
      height: 100,
      color: Colors.white, // ✅ Set background color to white
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visitor = visits[index];
          bool isSelected = selectedVisitor == visitor;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedVisitor = visitor;
                isExpandedView = true;
              });
            },
            child: Card(
              color: const Color(0xFFC6DAED), // 🔵 Set dark blue background
              margin: const EdgeInsets.only(right: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? Colors.white : AppColors.primary,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Container(
                width: 100,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor(visitor.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        getStatusText(visitor.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Day of week
                    Text(
                      getDayOfWeek(visitor.visitDate),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Date (big)
                    Text(
                      visitor.visitDate.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),

                    // Month
                    Text(
                      getMonthName(visitor.visitDate),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black,
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


  Widget _buildVerticalVisitCards(List<VisitorModel> visits) {
    return ListView.builder(
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visitor = visits[index];
        bool isSelected = selectedVisitor == visitor;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedVisitor = visitor; // ✅ Set selected visitor
            });
          },
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.primary,
                  width: isSelected ? 2 : 1.2,
                ),
              ),
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Left vertical date block
                  Container(
                    width: 70,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          getDayOfWeek(visitor.visitDate),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          visitor.visitDate.day.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          getMonthName(visitor.visitDate),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right content block
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status label
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor(visitor.status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              getStatusText(visitor.status),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Time
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              '${visitor.startTime} - ${visitor.endTime}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Visitor name
                        Row(
                          children: [
                            const Icon(Icons.person, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                visitor.visitorName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Prison/Jail name
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                visitor.jail,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Additional participants
                        Row(
                          children: [
                            const Icon(Icons.group, size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                visitor.additionalVisitors > 0
                                    ? '${visitor.additionalVisitors} additional Visitors'
                                    : 'No additional Visitors',
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow icon
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 25, color: AppColors.primary,fontWeight: FontWeight.bold,),
                      onPressed: () {
                        setState(() {
                          selectedVisitor = visitor; // ✅ Set selected visitor
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VisitPreviewScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
              final targetLangCode = _languages[language] ?? 'en';
              Future.delayed(Duration.zero, () => _translateAll(targetLangCode));
            },
            itemBuilder: (context) => _languages.keys.map((language) {
              return PopupMenuItem<String>(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translatedWelcome.isNotEmpty ? translatedWelcome : 'Welcome to E-Mulakat',
                style: TextStyle(
                  fontSize: _fontSize + 8,
                  fontWeight: FontWeight.bold,
                  color: _selectedColor,
                ),
              ),
              SizedBox(height: 15),
              Text(
                translatedInstructions.isNotEmpty ? translatedInstructions : 'Prison Visitor Management System',
                style: TextStyle(
                  fontSize: _fontSize + 2,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
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
              // Replace the Expanded with a fixed-height container:
              SizedBox(
                height: isExpandedView ? 200 : 150, // Adjust as needed
                child: isExpandedView
                    ? _buildVerticalVisitCards(showPastVisits ? pastVisits : upcomingVisits)
                    : _buildHorizontalVisitCards(showPastVisits ? pastVisits : upcomingVisits),
              ),

              SizedBox(height: 10),
              // E-Pass Button
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
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
                          // Show alert if no visitor is selected
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatbotScreen()),
          );
        },
        backgroundColor: Color(0xFF5A8BBA),
        child: Icon(Icons.chat_outlined), // 🤖 chatbot icon
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
    );
  }
}