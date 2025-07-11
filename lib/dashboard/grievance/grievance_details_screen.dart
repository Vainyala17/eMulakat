import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/color_scheme.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';
import '../visit/visit_home.dart';
import 'grievance_home.dart';

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

  String? _selectedState;
  String? _selectedJail;
  String? _selectedPrisonerGender;
  String? _selectedCategory;
  int _additionalVisitors = 0;
  List<TextEditingController> _additionalVisitorControllers = [];

  final List<String> _genders = ['Male', 'Female', 'Transgender'];
  final List<String> _category = ['SELECT',
    'III Treated by the prison authorities',
    'Basic Facilities not provided inside prison',
  'Manhandling by co prisoners',
  'Others'];

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
      'Alipore Women’s Correctional Home',
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
    final _ = _selectedIndex == index;

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Grievance Details'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
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
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
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
                    // Convert first letter of each word to uppercase
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
                  LengthLimitingTextInputFormatter(3), // Limit age to 3 digits
                ],
              ),
              SizedBox(height: 16),

              // Prisoner Gender
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gender*',
                    style: TextStyle(fontSize: 16,),
                  ),
                  ..._genders.map((gender) {
                    return RadioListTile<String>(
                      title: Text(gender),
                      value: gender,
                      groupValue: _selectedPrisonerGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedPrisonerGender = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                  if (_selectedPrisonerGender == null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Text(
                        'Select your gender',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  border: OutlineInputBorder(),
                ),
                items: _category.map((relation) {
                  return DropdownMenuItem(
                    value: relation,
                    child: Text(relation),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) => value == null ? 'Please select Category' : null,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _prisonerNameController,
                label: 'Message*',
                hint: 'Enter issue Description',
                validator: Validators.validateName,
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Convert first letter of each word to uppercase
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => GrievanceHomeScreen()),
                          );
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

  @override
  void dispose() {
    _prisonerNameController.dispose();
    _prisonerAgeController.dispose();
    super.dispose();
  }
}