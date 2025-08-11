import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';
import '../visit/visit_home.dart';
import '../visit/whom_to_meet_screen.dart';
import 'grievance_home.dart';
import 'grievance_preview_screen.dart';

class GrievanceDetailsScreen extends StatefulWidget {
  @override
  _GrievanceDetailsScreenState createState() => _GrievanceDetailsScreenState();
}

class _GrievanceDetailsScreenState extends State<GrievanceDetailsScreen> {
  int _selectedIndex = 0;
  late WebViewController controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _prisonerNameController = TextEditingController();
  final TextEditingController _prisonerAgeController = TextEditingController();
  final TextEditingController _additionalVisitorsController = TextEditingController();
  final TextEditingController _messageController = TextEditingController(); // Added separate controller for message

  String? _selectedState;
  String? _selectedJail;
  String? _selectedPrisonerGender;
  String? _selectedCategory;
  int _additionalVisitors = 0;
  List<TextEditingController> _additionalVisitorControllers = [];

  final List<String> _genders = ['Male', 'Female', 'Transgender'];
  final List<String> _category = [
    'SELECT',
    'III Treated by the prison authorities',
    'Basic Facilities not provided inside prison',
    'Manhandling by co prisoners',
    'Others'
  ];

  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];

  final Map<String, List<String>> _jailsByState = {
    'Maharashtra': [
      'Yerawada Central Prison',
      'Arthur Road Jail',
      'Nagpur Central Prison',
      'Thane Central Jail',
      'Pune Yerwada Open Jail',
    ],
    'Delhi': [
      'Tihar Jail',
      'Rohini Jail',
      'Mandoli Jail',
    ],
    'Uttar Pradesh': [
      'Naini Central Jail (Prayagraj)',
      'Dasna Jail (Ghaziabad)',
      'Lucknow District Jail',
      'Fatehgarh Central Jail',
    ],
    'Tamil Nadu': [
      'Puzhal Central Prison',
      'Coimbatore Central Jail',
      'Madurai Central Prison',
      'Trichy Central Prison',
    ],
    'Karnataka': [
      'Parappana Agrahara Central Jail (Bengaluru)',
      'Ballari Central Jail',
      'Mysore District Jail',
    ],
    'West Bengal': [
      'Presidency Correctional Home (Kolkata)',
      'Dumdum Central Jail',
      'Alipore Women\'s Correctional Home',
    ],
    'Rajasthan': [
      'Jaipur Central Jail',
      'Ajmer Central Jail',
      'Jodhpur Central Jail',
    ],
    'Bihar': [
      'Beur Central Jail (Patna)',
      'Bhagalpur Central Jail',
      'Buxar Central Jail',
    ],
    'Punjab': [
      'Patiala Central Jail',
      'Ludhiana Central Jail',
      'Amritsar Jail',
    ],
    'Haryana': [
      'Ambala Central Jail',
      'Hisar Central Jail',
      'Gurugram District Jail',
    ],
    'Gujarat': [
      'Sabarmati Central Jail (Ahmedabad)',
      'Vadodara Central Jail',
      'Rajkot Central Jail',
    ],
    'Madhya Pradesh': [
      'Indore Central Jail',
      'Bhopal Central Jail',
      'Jabalpur Central Jail',
    ],
    'Jharkhand': [
      'Ranchi Central Jail',
      'Dumka Central Jail',
      'Hazaribagh District Jail',
    ],
    'Odisha': [
      'Bhubaneswar Special Jail',
      'Choudwar Circle Jail',
      'Berhampur Circle Jail',
    ],
    'Kerala': [
      'Poojappura Central Prison',
      'Viyyur Central Jail',
      'Kannur Central Prison',
    ],
    'Andhra Pradesh': [
      'Rajahmundry Central Jail',
      'Kadapa Central Prison',
      'Visakhapatnam Jail',
    ],
    'Telangana': [
      'Chanchalguda Central Jail',
      'Cherlapally Central Jail',
      'Warangal Central Jail',
    ],
    'Assam': [
      'Guwahati Central Jail',
      'Jorhat District Jail',
      'Silchar Jail',
    ],
    'Chhattisgarh': [
      'Raipur Central Jail',
      'Bilaspur Jail',
      'Jagdalpur Central Jail',
    ],
    'Uttarakhand': [
      'Dehradun District Jail',
      'Haldwani Jail',
      'Haridwar Jail',
    ],
    'Himachal Pradesh': [
      'Kanda Central Jail',
      'Nahan Jail',
      'Dharamshala Jail',
    ],
    'Goa': [
      'Colvale Central Jail',
      'Sada Sub Jail',
    ],
    'Tripura': [
      'Agartala Central Jail',
      'Dharmanagar Jail',
    ],
    'Meghalaya': [
      'Shillong Jail',
      'Tura Jail',
    ],
    'Manipur': [
      'Sajiwa Central Jail',
      'Imphal Jail',
    ],
    'Nagaland': [
      'Dimapur Central Jail',
      'Kohima Jail',
    ],
    'Mizoram': [
      'Aizawl Central Jail',
      'Lunglei Jail',
    ],
    'Arunachal Pradesh': [
      'Jully Jail (Itanagar)',
    ],
    'Sikkim': [
      'Rangpo District Jail',
    ],
    'Chandigarh': [
      'Model Jail, Chandigarh',
    ],
    'Jammu and Kashmir': [
      'Kot Bhalwal Jail',
      'Srinagar Central Jail',
    ],
    'Ladakh': [
      'Leh Jail',
    ],
    'Andaman and Nicobar Islands': [
      'Port Blair District Jail',
      'Cellular Jail (Historical Monument)',
    ],
    'Puducherry': [
      'Kalapet Central Prison',
    ],
    'Dadra and Nagar Haveli and Daman and Diu': [
      'Silvassa Jail',
      'Daman Jail',
    ],
  };

  @override
  void initState() {
    super.initState();
    _additionalVisitorsController.addListener(() {
      final count = int.tryParse(_additionalVisitorsController.text) ?? 0;
      setState(() {
        _additionalVisitors = count;
        _updateAdditionalVisitorControllers();
      });
    });
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 16),
              Text(
                "Success",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Your data has been successfully saved!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black, // ✅ Correct way
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateAdditionalVisitorControllers() {
    if (_additionalVisitors > _additionalVisitorControllers.length) {
      for (int i = _additionalVisitorControllers.length; i < _additionalVisitors; i++) {
        _additionalVisitorControllers.add(TextEditingController());
      }
    } else if (_additionalVisitors < _additionalVisitorControllers.length) {
      for (int i = _additionalVisitorControllers.length - 1; i >= _additionalVisitors; i--) {
        _additionalVisitorControllers[i].dispose();
        _additionalVisitorControllers.removeAt(i);
      }
    }
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
          padding: EdgeInsets.symmetric(vertical:3),
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Grievance'),
          centerTitle: true,
          backgroundColor: Color(0xFF5A8BBA),
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewerScreen(
                      assetPath: 'assets/pdfs/about_us.pdf',
                    ),
                  ),
                );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: Colors.black,
                labelStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 18,
                ),
                labelColor: Color(0xFF5A8BBA),
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(text: 'Register Grievance'),
                  Tab(text: 'Preview Grievance'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Register Grievance Tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormSectionTitle(title: 'Grievance Details'),
                    SizedBox(height: 20),

                    // State Selection
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: InputDecoration(
                        labelText: 'State*',
                        border: OutlineInputBorder(),
                      ),
                      items: _states.map((state) {
                        return DropdownMenuItem(
                          value: state,
                          child: Text(state),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                          _selectedJail = null;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a state' : null,
                    ),
                    SizedBox(height: 16),

                    // Jail Selection
                    DropdownButtonFormField<String>(
                      value: _selectedJail,
                      decoration: InputDecoration(
                        labelText: 'Jail*',
                        border: OutlineInputBorder(),
                      ),
                      items: _selectedState != null && _jailsByState[_selectedState] != null
                          ? _jailsByState[_selectedState]!.map((jail) {
                        return DropdownMenuItem(
                          value: jail,
                          child: Text(jail),
                        );
                      }).toList()
                          : [],
                      onChanged: (value) {
                        setState(() {
                          _selectedJail = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a jail' : null,
                    ),
                    SizedBox(height: 16),

                    FormSectionTitle(title: 'Prisoner Details'),
                    SizedBox(height: 20),

                    // Prisoner Name
                    CustomTextField(
                      controller: _prisonerNameController,
                      label: 'Prisoner Name*',
                      hint: 'Enter prisoner Name',
                      validator: Validators.validateName,
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          String text = newValue.text;
                          if (text.isNotEmpty) {
                            text = text.split(' ').map((word) {
                              if (word.isNotEmpty) {
                                return word[0].toUpperCase() + word.substring(1).toLowerCase();
                              }
                              return word;
                            }).join(' ');
                          }
                          return TextEditingValue(
                            text: text,
                            selection: TextSelection.collapsed(offset: text.length),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Prisoner Age
                    CustomTextField(
                      controller: _prisonerAgeController,
                      label: 'Prisoner Age*',
                      hint: 'Enter prisoner Age',
                      keyboardType: TextInputType.number,
                      validator: Validators.validateAge,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Prisoner Gender
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gender*',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: _genders.map((gender) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<String>(
                                  value: gender,
                                  groupValue: _selectedPrisonerGender,
                                  visualDensity: VisualDensity(horizontal: -4, vertical: -4), // compact look
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,    // reduces touch area
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPrisonerGender = value;
                                    });
                                  },
                                ),
                                Text(
                                  gender,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 25), // minimal spacing between options
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Category Selection
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Select Category*',
                        border: OutlineInputBorder(),
                      ),
                      items: _category.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) => value == null || value == 'SELECT' ? 'Please select Category' : null,
                    ),
                    SizedBox(height: 16),

                    // Message Field
                    CustomTextField(
                      controller: _messageController,
                      label: 'Message*',
                      hint: 'Enter issue description',
                      maxLines: 5, // 👈 Makes it look like a textarea
                      maxLength: 500, // Optional: increase limit
                      validator: (value) {
                        final pattern = RegExp(r'^[a-zA-Z0-9\s.,;!?()\-]+$');
                        if (value == null || value.isEmpty) {
                          return 'Message is required';
                        } else if (!pattern.hasMatch(value)) {
                          return 'Only letters, numbers and . , ; ! ? - ( ) are allowed';
                        }
                        return null;
                      },
                      inputFormatters: [
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          // Allow letters, numbers, common punctuation
                          final allowedPattern = RegExp(r'^[a-zA-Z0-9\s.,;!?()\-]*$');
                          if (allowedPattern.hasMatch(newValue.text)) {
                            return newValue;
                          }
                          return oldValue;
                        }),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Save',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                showSuccessDialog(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Preview Grievance Tab
            GrievancePreviewScreen(),
          ],
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
                    index: 0,
                    icon: Icons.directions_walk,
                    label: 'Meeting',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => VisitHomeScreen()),
                      );
                    },
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.gavel,
                    label: 'Parole',
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
      ),
    );
  }

  @override
  void dispose() {
    _prisonerNameController.dispose();
    _prisonerAgeController.dispose();
    _additionalVisitorsController.dispose();
    _messageController.dispose();
    for (var controller in _additionalVisitorControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}