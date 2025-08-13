import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/home/home_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/form_section_title.dart';

class ParoleScreen extends StatefulWidget {
  const ParoleScreen({super.key});

  @override
  State<ParoleScreen> createState() => _ParoleScreenState();
}

class _ParoleScreenState extends State<ParoleScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedState;
  String? _selectedPoliceStation;
  String? _selectedDistrict;
  String? _selectedReason;

  final TextEditingController _paroleFromDateController = TextEditingController();
  final TextEditingController _paroleToDateController = TextEditingController();
  final TextEditingController _AddressPlaceController = TextEditingController();


  final List<String> _reason = ["To maintain family and social ties",
  "other"];
  final List<String> _states = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
    'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
    'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
    'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'
  ];
  final Map<String, List<String>> _districtByState = {
    'Andhra Pradesh': [
      'Alluri Sitharama Raju', 'Anakapalli', 'Parvathipuram Manyam', 'Srikakulam',
      'Visakhapatnam', 'Vizianagaram',
      'Bapatla', 'Dr. B. R. Ambedkar Konaseema', 'East Godavari', 'Eluru', 'Guntur',
      'Kakinada', 'Krishna', 'NTR',
      'Palnadu', 'Prakasam', 'Sri Potti Sriramulu Nellore', 'West Godavari', 'Anantapur',
      'Annamayya', 'Chittoor', 'YSR Kadapa', 'Kurnool', 'Nandyal','Sri Sathya Sai',
      'Tirupati',
    ],
    'Maharashtra': [
      'Ahmednagar',
      'Akola', 'Amravati', 'Aurangabad', 'Bhandara',
      'Beed', 'Buldhana', 'Chandrapur', 'Dhule', 'Gadchiroli', 'Gondia', 'Hingoli', 'Jalgaon', 'Jalna',
      'Kolhapur', 'Latur', 'Mumbai City', 'Mumbai Suburban', 'Nanded', 'Nandurbar', 'Nagpur',
      'Nashik', 'Osmanabad', 'Palghar', 'Parbhani', 'Pune', 'Raigad', 'Ratnagiri', 'Sangli',
      'Satara', 'Sindhudurg', 'Solapur', 'Thane', 'Wardha', 'Washim', 'Yavatmal',
    ],
  };

  static const Map<String, Map<String, Map<String, List<String>>>> _policeStationsByDistrict = {
    "Andhra Pradesh": {
      "districts": {
        "Visakhapatnam": [
          "Visakhapatnam City Police Station",
          "Gajuwaka Police Station",
          "Madhurawada Police Station",
          "MVP Colony Police Station",
          "Dwaraka Nagar Police Station"
        ],
        "Vijayawada": [
          "Vijayawada City Police Station",
          "Governorpet Police Station",
          "Patamata Police Station",
          "Krishna Lanka Police Station",
          "Benz Circle Police Station"
        ],
        "Guntur": [
          "Guntur City Police Station",
          "Guntur Rural Police Station",
          "Narasaraopet Police Station",
          "Mangalagiri Police Station",
          "Tenali Police Station"
        ],
        "Tirupati": [
          "Tirupati Urban Police Station",
          "Tirupati Rural Police Station",
          "Alipiri Police Station",
          "Chandragiri Police Station"
        ]
      }
    },
    "Maharashtra": {
      "districts": {
        "Mumbai City": [
          "Colaba Police Station",
          "Marine Drive Police Station",
          "Azad Maidan Police Station",
          "JJ Marg Police Station",
          "MRA Marg Police Station",
          "Fort Police Station"
        ],
        "Mumbai Suburban": [
          "Andheri Police Station",
          "Bandra Police Station",
          "Kurla Police Station",
          "Mulund Police Station",
          "Borivali Police Station",
          "Malad Police Station"
        ],
        "Pune": [
          "Pune City Police Station",
          "Shivajinagar Police Station",
          "Kothrud Police Station",
          "Hadapsar Police Station",
          "Warje Police Station",
          "Aundh Police Station"
        ],
        "Nagpur": [
          "Nagpur City Police Station",
          "Sitabuldi Police Station",
          "Dhantoli Police Station",
          "Ganeshpeth Police Station",
          "Kotwali Police Station"
        ],
        "Nashik": [
          "Nashik City Police Station",
          "Mumbai Naka Police Station",
          "Gangapur Police Station",
          "Panchavati Police Station"
        ]
      }
    },
    // ... Repeat same pattern for other states
  };


  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Please use Logout and close the App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // stay
            child: const Text('OK'),
          ),
        ],
      ),
    ) ??
        false;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child:Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormSectionTitle(title: 'Parole Application'),
                SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _selectedReason,
                  decoration: InputDecoration(
                    labelText: 'Reason*',
                    border: OutlineInputBorder(),
                  ),
                  items: _reason.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a reason' : null,
                ),
                SizedBox(height: 16),

                // Visit Date
                TextFormField(
                  controller: _paroleFromDateController,
                  decoration: InputDecoration(
                    labelText: 'Parole From*',
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
                      _paroleFromDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                    }
                  },
                  validator: (value) => value!.isEmpty ? 'Please select date' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _paroleToDateController,
                  decoration: InputDecoration(
                    labelText: 'Parole To*',
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
                      _paroleToDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                    }
                  },
                  validator: (value) => value!.isEmpty ? 'Please select date' : null,
                ),
                SizedBox(height: 16),

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
                      _selectedDistrict = null;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a state' : null,
                ),
                SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: InputDecoration(
                    labelText: 'District*',
                    border: OutlineInputBorder(),
                  ),
                  items: _selectedState != null && _districtByState[_selectedState] != null
                      ? _districtByState[_selectedState]!.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList()
                      : [],
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a District' : null,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPoliceStation,
                  decoration: const InputDecoration(
                    labelText: 'Police Station*',
                    border: OutlineInputBorder(),
                  ),
                  items: (_selectedState != null &&
                      _selectedDistrict != null &&
                      _policeStationsByDistrict[_selectedState]?["districts"]?[_selectedDistrict] != null)
                      ? _policeStationsByDistrict[_selectedState]!["districts"]![_selectedDistrict]!
                      .map((station) => DropdownMenuItem<String>(
                    value: station,
                    child: Text(station),
                  ))
                      .toList()
                      : [],
                  onChanged: (value) {
                    setState(() {
                      _selectedPoliceStation = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a police station' : null,
                ),

                SizedBox(height: 16),

                CustomTextField(
                  controller: _AddressPlaceController,
                  label: 'Address of Place to Visit*',
                  hint: 'Application Testing',
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _paroleFromDateController.dispose();
    _paroleToDateController.dispose();
    super.dispose();
  }
}
