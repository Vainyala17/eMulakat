import 'package:e_mulakat/dashboard/grievance/grievance_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../dashboard/visit/visit_home.dart';
import 'bottom_nav_bar.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('e-Mulakat'),
        centerTitle: true,
        backgroundColor: _selectedColor,
        actions: [
          // Notification Icon
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications
            },
          ),

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
            onPressed: () => _speak('Welcome to e-Mulakat'),
          ),

          // Color Picker
          PopupMenuButton<Color>(
            icon: Icon(Icons.color_lens),
            onSelected: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            itemBuilder: (context) => _colorOptions.map((colorHex) {
              Color color = Color(int.parse('0xff$colorHex'));
              return PopupMenuItem(
                value: color,
                child: Container(
                  width: 40,
                  height: 20,
                  color: color,
                ),
              );
            }).toList(),
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
              'Welcome to e-Mulakat',
              style: TextStyle(
                fontSize: _fontSize + 8,
                fontWeight: FontWeight.bold,
                color: _selectedColor,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Prison Visitor Management System',
              style: TextStyle(
                fontSize: _fontSize + 2,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),
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
                      MaterialPageRoute(builder: (context) => VisitScreen()),
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