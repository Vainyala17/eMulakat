import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/visitor_model.dart';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/bottom_nav_bar.dart';
import '../../screens/home/home_screen.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart'; // Import your API service
import '../../services/device_service.dart';
import '../../utils/color_scheme.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/read_only_text_fields.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/form_section_title.dart';
import '../grievance/grievance_details_screen.dart';
import '../visit/whom_to_meet_screen.dart';

class ParoleScreen extends StatefulWidget {
  final bool fromChatbot;
  final int selectedIndex;
  final VisitorModel? visitorData;
  final bool fromNavbar;
  final bool fromRegisteredInmates;
  final String? prefilledPrisonerName;
  final String? prefilledPrison;
  final bool showVisitCards;

  const ParoleScreen({
    Key? key,
    this.fromChatbot = false,
    this.visitorData,
    this.selectedIndex = 0,
    this.fromNavbar = false,
    this.fromRegisteredInmates = false,
    this.prefilledPrisonerName,
    this.prefilledPrison,
    this.showVisitCards = false,
  }) : super(key: key);

  @override
  State<ParoleScreen> createState() => _ParoleScreenState();
}

class _ParoleScreenState extends State<ParoleScreen> {
  late int _selectedIndex;
  final _formKey = GlobalKey<FormState>();
  bool _showingVisitCards = false;
  String? _selectedState;
  String? _selectedPoliceStation;
  String? _selectedDistrict;
  String? _selectedReason;
  String selectedVisitType = 'Parole';
  String selectedStatus = 'All';
  bool _isReadOnlyMode = false;
  bool _isLoading = false;

  final TextEditingController _paroleFromDateController = TextEditingController();
  final TextEditingController _paroleToDateController = TextEditingController();
  final TextEditingController _AddressPlaceController = TextEditingController();
  final TextEditingController _prisonerNameController = TextEditingController();
  final TextEditingController _prisonController = TextEditingController();

  final List<String> _reason = ["To maintain family and social ties", "other"];
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

  Map<String, List<VisitorModel>> visitData = {
    'Parole': [],
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
  };

  final List<Map<String, dynamic>> inmates = [
    {
      "serial": 1,
      "prisonerName": "Raj Shekar",
      "paroleFrom": "5 Jul 2025",
      "paroleTo": "25 Sep 2025",
      "reason": "To maintain family and social ties",
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 2,
      "prisonerName": "Ram Kumar",
      "paroleFrom": "15 Nov 2025",
      "paroleTo": "27 Nov 2025",
      "reason": "Other",
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 3,
      "prisonerName": "Prashant Singh",
      "paroleFrom": "18 Nov 2025",
      "paroleTo": "1 Dec 2025",
      "reason": "To maintain family and social ties",
      "prison": "PHQ",
    }
  ];

  @override
  void initState() {
    super.initState();
    AuthService.checkAndHandleSession(context);
    _selectedIndex = widget.selectedIndex;

    // 🔥 NEW: Capture device info once when screen loads
    _captureDeviceInfo();

    if (widget.fromRegisteredInmates) {
      _showingVisitCards = false;
      _isReadOnlyMode = true;

      if (widget.prefilledPrisonerName != null) {
        _prisonerNameController.text = widget.prefilledPrisonerName!;
      }
      if (widget.prefilledPrison != null) {
        _prisonController.text = widget.prefilledPrison!;
      }
    } else {
      _showingVisitCards = widget.showVisitCards || !widget.fromChatbot;
      _isReadOnlyMode = false;
    }
  }

// Add this new method to ParoleScreen class:
  /// Capture device information once per installation
  Future<void> _captureDeviceInfo() async {
    try {
      await DeviceService.captureDeviceInfoOnce(screenName: 'Parole');
    } catch (e) {
      print('❌ Error in parole device info capture: $e');
    }
  }
  // Handle form submission using API service
  Future<void> _handleFormSubmission() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare request body
      Map<String, String> requestBody = {
        'prisonerName': _prisonerNameController.text,
        'prison': _prisonController.text,
        'reason': _selectedReason ?? '',
        'paroleFromDate': _paroleFromDateController.text,
        'paroleToDate': _paroleToDateController.text,
        'state': _selectedState ?? '',
        'district': _selectedDistrict ?? '',
        'policeStation': _selectedPoliceStation ?? '',
        'addressOfPlace': _AddressPlaceController.text,
      };

      // Call API service
      final response = await ApiService.raiseParoleRequest(requestBody);

      // Handle success - show success message and go back
      _showSuccessMessage(response);

    } catch (e) {
      _showErrorMessage('An error occurred: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show success message and navigate back
  void _showSuccessMessage(Map<String, dynamic> response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    response['message'] ?? 'Parole request submitted successfully!',
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (response['applicationId'] != null)
                    Text(
                      'ID: ${response['applicationId']}',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate back immediately, don't wait
    Navigator.of(context).pop();
  }

  // Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildVerticalList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: inmates.length,
      itemBuilder: (context, index) {
        final inmate = inmates[index];
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 1),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.black, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${inmate['prisonerName']} (#${inmate['serial']})",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Download functionality coming soon')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.explicit_outlined, "Reason: ${inmate['reason']}"),
                Row(
                  children: [
                    const Icon(Icons.date_range_outlined, size: 18, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Parole From: ${inmate['paroleFrom']}",
                        style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParoleScreen(
                              selectedIndex: 2,
                              fromRegisteredInmates: true,
                              prefilledPrisonerName: inmate['prisonerName'],
                              prefilledPrison: inmate['prison'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ],
                ),
                _buildInfoRow(Icons.date_range, "Parole To: ${inmate['paroleTo']}"),
                _buildInfoRow(Icons.location_on, "Prison: ${inmate['prison']}"),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParoleForm(){
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormSectionTitle(title: 'Parole Application'),
            SizedBox(height: 20),

            buildReadOnlyTextField(
              context : context,
              controller: _prisonerNameController,
              label: 'Prisoner Name*',
              hint: 'Enter prisoner Name',
              validator: Validators.validateName,
              readOnly: _isReadOnlyMode,
              fieldName: 'Prisoner Name',
            ),
            SizedBox(height: 20),

            buildReadOnlyTextField(
              context : context,
              controller: _prisonController,
              label: 'Prison*',
              hint: 'Prison',
              validator: (value) => value!.isEmpty ? 'Prison is required' : null,
              readOnly: _isReadOnlyMode,
              maxLines: 2,
              fieldName: 'Prison',
            ),
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
              maxLines: 5,
              maxLength: 500,
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
                  final allowedPattern = RegExp(r'^[a-zA-Z0-9\s.,;!?()\-]*$');
                  if (allowedPattern.hasMatch(newValue.text)) {
                    return newValue;
                  }
                  return oldValue;
                }),
              ],
            ),
            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _isLoading
                      ? Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Submitting...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                      : CustomButton(
                    text: 'Save',
                    onPressed: () => _handleFormSubmission(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => DialogUtils.onWillPop(context, showingCards: _showingVisitCards),
      child:Scaffold(
        backgroundColor: Colors.white,
        body: _showingVisitCards ? _buildVerticalList() : _buildParoleForm(),
        appBar: AppBar(
          title: const Text('Parole'),
          centerTitle: true,
          backgroundColor: const Color(0xFF5A8BBA),
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Check if we can pop, if not navigate to home
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                // Navigate to home screen if there's no previous screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(selectedIndex: 0),
                  ),
                );
              }
            },
          ),
          actions: [
            if (_showingVisitCards)
              IconButton(
                icon: const Icon(Icons.help_outline),
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF5A8BBA),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  buildNavItem(
                    selectedIndex :_selectedIndex,
                    index: 0,
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeScreen(selectedIndex: 0),
                        ),
                      );
                    },
                  ),
                  buildNavItem(
                    selectedIndex :_selectedIndex,
                    index: 1,
                    icon: Icons.directions_walk,
                    label: 'Meeting',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MeetFormScreen(selectedIndex: 1,showVisitCards: true,)),
                      );
                    },
                  ),
                  buildNavItem(
                    selectedIndex :_selectedIndex,
                    index: 2,
                    icon: Icons.gavel,
                    label: 'Parole',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParoleScreen(
                            selectedIndex: 2,
                            fromNavbar: true,
                          ),
                        ),
                      );
                    },
                  ),
                  buildNavItem(
                    selectedIndex :_selectedIndex,
                    index: 3,
                    icon: Icons.report_problem,
                    label: 'Grievance',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GrievanceDetailsScreen(selectedIndex: 3),
                        ),
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
    _paroleFromDateController.dispose();
    _paroleToDateController.dispose();
    _AddressPlaceController.dispose();
    _prisonerNameController.dispose();
    _prisonController.dispose();
    super.dispose();
  }
}