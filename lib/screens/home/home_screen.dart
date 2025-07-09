import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'drawer_menu.dart';
import '../../utils/color_scheme.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      appBar: AppBar(
        title: Text('E-Mulakat'),
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
            onPressed: () => _speak('Welcome to E-Mulakat'),
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
              'Welcome to E-Mulakat',
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
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),

            // Dashboard Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    'New Registration',
                    Icons.person_add,
                        () {
                      // Navigate to registration
                    },
                  ),
                  _buildDashboardCard(
                    'My Visits',
                    Icons.event,
                        () {
                      // Navigate to visits
                    },
                  ),
                  _buildDashboardCard(
                    'Visit History',
                    Icons.history,
                        () {
                      // Navigate to history
                    },
                  ),
                  _buildDashboardCard(
                    'Help',
                    Icons.help,
                        () {
                      // Navigate to help
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: _selectedColor,
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}