import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../home/home_screen.dart';
import 'visitor_form_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/color_scheme.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class MeetFormScreen extends StatefulWidget {
  @override
  _MeetFormScreenState createState() => _MeetFormScreenState();
}

class _MeetFormScreenState extends State<MeetFormScreen> {
  late WebViewController controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _prisonerNameController = TextEditingController();
  final TextEditingController _prisonerFatherNameController = TextEditingController();
  final TextEditingController _prisonerAgeController = TextEditingController();
  final TextEditingController _visitDateController = TextEditingController();
  final TextEditingController _additionalVisitorsController = TextEditingController();

  String? _selectedState;
  String? _selectedJail;
  String? _selectedPrisonerGender;
  bool _isPhysicalVisit = false;
  int _additionalVisitors = 0;
  List<TextEditingController> _additionalVisitorControllers = [];

  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];

  Map<String, List<String>> _jailsByState = {
    'Maharashtra': ['Yerawada Central Prison', 'Arthur Road Jail', 'Nagpur Central Prison'],
    'Delhi': ['Tihar Jail', 'Rohini Jail', 'Mandoli Jail'],
    'Karnataka': ['Parappana Agrahara Central Prison', 'Belgaum Central Prison'],
    // Add more jails as needed
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Whom to Meet'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              controller = WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse('https://eprisons.nic.in/downloads/eMulakat_VCRequestPublic.pdf'));
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
              FormSectionTitle(title: 'Whom to Meet'),
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

              // Visit Date
              TextFormField(
                controller: _visitDateController,
                decoration: InputDecoration(
                  labelText: 'Visit Date*',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30)),
                  );
                  if (pickedDate != null) {
                    _visitDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                  }
                },
                validator: (value) => value!.isEmpty ? 'Please select visit date' : null,
              ),
              SizedBox(height: 16),
              // Additional Visitors
              CustomTextField(
                controller: _additionalVisitorsController,
                label: 'Additional Visitors',
                hint: 'Enter number of additional visitors',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10), // Limit age to 10 digits
                ],
              ),
              SizedBox(height: 16),

              // Additional Visitor Names (Dynamic)
              if (_additionalVisitors > 0) ...[
                FormSectionTitle(title: 'Additional Visitor Names'),
                SizedBox(height: 16),
                for (int i = 0; i < _additionalVisitors; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: CustomTextField(
                      controller: _additionalVisitorControllers[i],
                      label: 'Additional Visitor ${i + 1} Name*',
                      hint: 'Enter visitor name',
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
                  ),
              ],

              SizedBox(height: 20),
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

              // Prisoner Father Name
              CustomTextField(
                controller: _prisonerFatherNameController,
                label: 'Father/Husband Name*',
                hint: 'Enter Father/Husband Name',
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
              DropdownButtonFormField<String>(
                value: _selectedPrisonerGender,
                decoration: InputDecoration(
                  labelText: 'Gender*',
                  border: OutlineInputBorder(),
                ),
                items: ['Male', 'Female', 'Other'].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPrisonerGender = value;
                  });
                },
                validator: (value) => value == null ? 'Please select gender' : null,
              ),
              SizedBox(height: 16),

              // Visit Mode
              CheckboxListTile(
                title: Text('Physical Visit'),
                value: _isPhysicalVisit,
                onChanged: (value) {
                  setState(() {
                    _isPhysicalVisit = value ?? false;
                  });
                },
              ),

              SizedBox(height: 30),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Previous',
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Submit',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeScreen()),
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
    );
  }

  @override
  void dispose() {
    _prisonerNameController.dispose();
    _prisonerFatherNameController.dispose();
    _prisonerAgeController.dispose();
    _visitDateController.dispose();
    _additionalVisitorsController.dispose();
    for (var controller in _additionalVisitorControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}