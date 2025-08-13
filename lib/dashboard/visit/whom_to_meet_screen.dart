import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/visitor_model.dart';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/vertical_visit_card.dart';
import '../../utils/color_scheme.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';
import '../grievance/grievance_details_screen.dart';
import '../grievance/grievance_home.dart';
import '../parole/parole_home.dart';
import 'additional_visitors.dart';

// Model for additional visitor data
class AdditionalVisitor {
  String visitorName;
  String fatherName;
  String relation;
  String mobileNumber;
  String? photoPath;
  String? idProofType;
  String? idProofNumber;
  String? idProofPath;
  bool isSelected;

  AdditionalVisitor({
    required this.visitorName,
    required this.fatherName,
    required this.relation,
    required this.mobileNumber,
    this.photoPath,
    this.idProofType,
    this.idProofNumber,
    this.idProofPath,
    this.isSelected = false,
  });
}

class MeetFormScreen extends StatefulWidget {
  final bool fromChatbot;
  final int selectedIndex;
  final VisitorModel? visitorData;
  final bool fromNavbar;
  final bool fromRegisteredInmates;
  final String? prefilledPrisonerName;
  final String? prefilledPrison;
  final bool showVisitCards;

  const MeetFormScreen({
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
  _MeetFormScreenState createState() => _MeetFormScreenState();
}

class _MeetFormScreenState extends State<MeetFormScreen> {
  late int _selectedIndex;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _prisonerNameController = TextEditingController();
  final TextEditingController _prisonController = TextEditingController();
  final TextEditingController _visitDateController = TextEditingController();

  String? _selectedVisitMode;
  List<TextEditingController> _additionalVisitorControllers = [];
  bool _isReadOnlyMode = false;
  bool _showingVisitCards = false;
  bool _showAdditionalVisitorsList = false; // New state for showing visitors list
  String selectedVisitType = 'Meeting';
  String selectedStatus = 'All';
  final List<String> _visitModes = ['Physical', 'Video Conferencing'];
  final List<String> _idProofTypes = ['Aadhar Card', 'Voter ID', 'Passport', 'Driving License', 'PAN Card'];
  // Sample previous visitors data
  List<AdditionalVisitor> _previousVisitors = [
    AdditionalVisitor(
      visitorName: 'KAMAL KISHORE',
      fatherName: 'RAM KISHAN',
      relation: 'Others',
      mobileNumber: 'XXXXXXXX',
      idProofType: 'Aadhar Card',
      idProofNumber: 'XXXX-XXXX-1234',
    ),
    AdditionalVisitor(
      visitorName: 'USHA',
      fatherName: 'ASHOK KUMAR',
      relation: 'Husband / Wife',
      mobileNumber: 'XXXXXXXX',
      idProofType: 'Voter ID',
      idProofNumber: 'VOT123456',
    ),
    AdditionalVisitor(
      visitorName: 'MEENA',
      fatherName: 'KAMAL KISHORE',
      relation: 'Sister',
      mobileNumber: 'XXXXXXXX',
      idProofType: 'Passport',
      idProofNumber: 'P1234567',
    ),
    AdditionalVisitor(
      visitorName: 'KAMLESH',
      fatherName: 'VINESH',
      relation: 'Sister',
      mobileNumber: 'XXXXXXXX',
      idProofType: 'Driving License',
      idProofNumber: 'DL123456',
    ),
  ];

  final List<Map<String, dynamic>> inmates = [
    {
      "serial": 1,
      "prisonerName": "Ashok Kumar",
      "visitorName": "Govind Ram",
      "genderAge": "M/47",
      "relation": "Brother",
      "modeOfVisit": "Yes",
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 2,
      "prisonerName": "Anil Kumar",
      "visitorName": "Kewal Singh",
      "genderAge": "M/57",
      "relation": "Lawyer",
      "modeOfVisit": "Yes",
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 3,
      "prisonerName": "Test",
      "visitorName": "Rajesh",
      "genderAge": "M/21",
      "relation": "Lawyer",
      "modeOfVisit": "-",
      "prison": "PHQ",
    }
  ];

  Map<String, List<VisitorModel>> visitData = {
    'Meeting': [],
  };

  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    initializeVisitData();

    if (widget.fromNavbar) {
      _showingVisitCards = true;
      _isReadOnlyMode = false;
    } else {
      _showingVisitCards = widget.showVisitCards;
      _isReadOnlyMode = widget.fromRegisteredInmates;
    }

    if (!_showingVisitCards) {
      _populateFormData();
      _additionalVisitorControllers.add(TextEditingController());
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
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  // Widget to build additional visitor card
  Widget _buildAdditionalVisitorCard(AdditionalVisitor visitor, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: visitor.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      visitor.isSelected = value ?? false;
                    });
                  },
                  activeColor: Color(0xFF5A8BBA),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor.visitorName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Father: ${visitor.fatherName}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        'Relation: ${visitor.relation}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        'Mobile: ${visitor.mobileNumber}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photo:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () {
                          // Photo upload functionality
                          _showPhotoUploadDialog(visitor);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          visitor.photoPath ?? 'Browse...',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID Details:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: visitor.idProofType,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 12, color: Colors.black),
                        items: _idProofTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            visitor.idProofType = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        initialValue: visitor.idProofNumber,
                        decoration: InputDecoration(
                          hintText: 'Enter Card Number',
                          hintStyle: TextStyle(fontSize: 12),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 12),
                        onChanged: (value) {
                          visitor.idProofNumber = value;
                        },
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // ID proof upload functionality
                          _showIdProofUploadDialog(visitor);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          visitor.idProofPath ?? 'Browse...',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the additional visitors list view
  Widget _buildAdditionalVisitorsListView() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Additional Visitors List',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A8BBA),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showAdditionalVisitorsList = false;
                  });
                },
                icon: Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _previousVisitors.length + 1, // +1 for Add button
              itemBuilder: (context, index) {
                if (index == _previousVisitors.length) {
                  // Add new visitor button at the end
                  return Container(
                    margin: EdgeInsets.only(top: 16),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Navigate to add new visitor screen
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddNewVisitorScreen(),
                          ),
                        );

                        if (result != null && result is AdditionalVisitor) {
                          setState(() {
                            _previousVisitors.add(result);
                          });
                        }
                      },
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Add New Visitor',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5A8BBA),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }

                return _buildAdditionalVisitorCard(_previousVisitors[index], index);
              },
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _addSelectedVisitorsToForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5A8BBA),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add Selected Visitors',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addSelectedVisitorsToForm() {
    List<AdditionalVisitor> selectedVisitors = _previousVisitors
        .where((visitor) => visitor.isSelected)
        .toList();

    if (selectedVisitors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one visitor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Clear existing additional visitor controllers
    for (var controller in _additionalVisitorControllers) {
      controller.dispose();
    }
    _additionalVisitorControllers.clear();

    // Add selected visitors to form
    for (var visitor in selectedVisitors) {
      TextEditingController controller = TextEditingController();
      controller.text = visitor.visitorName;
      _additionalVisitorControllers.add(controller);
    }

    setState(() {
      _showAdditionalVisitorsList = false;
      // Reset selection for next time
      for (var visitor in _previousVisitors) {
        visitor.isSelected = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedVisitors.length} visitor(s) added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPhotoUploadDialog(AdditionalVisitor visitor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Photo'),
          content: Text('Photo upload functionality will be implemented here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  visitor.photoPath = 'photo_uploaded.jpg';
                });
              },
              child: Text('Upload'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Custom TextFormField widget for read-only fields with styling
  Widget _buildReadOnlyTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool readOnly = false,
    int maxLines = 1,
    String? fieldName,
    bool isRequired = false,
  }) {
    return GestureDetector(
      onTap: readOnly ? () => _showReadOnlyAlert(fieldName ?? label) : null,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: isRequired ? '$label*' : label,
          hintText: hint,
          border: OutlineInputBorder(),
          fillColor: readOnly ? Colors.grey[200] : Colors.white,
          filled: true,
          suffixIcon: readOnly ? Icon(Icons.lock_outline, color: Colors.grey) : null,
        ),
        style: TextStyle(
          color: readOnly ? Colors.grey[600] : Colors.black,
        ),
        validator: validator,
        readOnly: readOnly,
        maxLines: maxLines,
        inputFormatters: readOnly ? [] : [
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
    );
  }
  void _showIdProofUploadDialog(AdditionalVisitor visitor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload ID Proof'),
          content: Text('ID proof upload functionality will be implemented here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  visitor.idProofPath = 'id_proof_uploaded.pdf';
                });
              },
              child: Text('Upload'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void initializeVisitData() {
    // Sample Meeting data
    visitData['Meeting'] = [
      VisitorModel(
        visitorName: 'Sunita Roy',
        fatherName: 'Bimal Roy',
        address: '321 MG Road, Nagpur',
        gender: 'Female',
        age: 38,
        relation: 'Wife',
        idProof: 'Passport',
        idNumber: 'P1234567',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Nagpur Central Jail',
        visitDate: DateTime.now().subtract(Duration(days: 3)),
        additionalVisitors: 0,
        additionalVisitorNames: [],
        prisonerName: 'Rajesh Roy',
        prisonerFatherName: 'Mohan Roy',
        prisonerAge: 42,
        prisonerGender: 'Male',
        mode: false,
        status: VisitStatus.expired,
        startTime: '11:00',
        endTime: '13:00',
        dayOfWeek: 'Thursday',
        prison: 'Nagpur Central Jail',
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
        visitDate: DateTime.now().add(Duration(days: 5)),
        additionalVisitors: 1,
        additionalVisitorNames: ['Sita Sharma'],
        prisonerName: 'Ravi Sharma',
        prisonerFatherName: 'Naresh Sharma',
        prisonerAge: 40,
        prisonerGender: 'Male',
        mode: true,
        status: VisitStatus.pending,
        startTime: '14:00',
        endTime: '16:30',
        dayOfWeek: 'Friday',
        prison: 'CENTRAL JAIL NO.2, TIHAR',
      ),
      VisitorModel(
        visitorName: 'Anand Gupta',
        fatherName: 'Mahesh Gupta',
        address: '456 FC Road, Pune',
        gender: 'Male',
        age: 28,
        relation: 'Son',
        idProof: 'Aadhar',
        idNumber: 'XXXX-XXXX-5678',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Yerwada Jail',
        visitDate: DateTime.now().add(Duration(days: 2)),
        additionalVisitors: 0,
        additionalVisitorNames: [],
        prisonerName: 'Ashok Kumar',
        prisonerFatherName: 'Ramesh Gupta',
        prisonerAge: 55,
        prisonerGender: 'Male',
        mode: false,
        status: VisitStatus.completed,
        startTime: '10:00',
        endTime: '12:00',
        dayOfWeek: 'Wednesday',
        prison: 'CENTRAL JAIL NO.3, TIHAR',
      ),
      VisitorModel(
        visitorName: 'Meena Patel',
        fatherName: 'Raj Patel',
        address: '789 SB Road, Pune',
        gender: 'Female',
        age: 45,
        relation: 'Mother',
        idProof: 'Voter ID',
        idNumber: 'VOT9876543',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Pune Central Jail',
        visitDate: DateTime.now().add(Duration(days: 1)),
        additionalVisitors: 1,
        additionalVisitorNames: ['Kiran Patel'],
        prisonerName: 'Anil Kumar',
        prisonerFatherName: 'Raj Patel',
        prisonerAge: 25,
        prisonerGender: 'Male',
        mode: true,
        status: VisitStatus.upcoming,
        startTime: '09:00',
        endTime: '17:00',
        dayOfWeek: 'Monday',
        prison: 'PHQ DELHI',
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
        visitDate: DateTime.now().add(Duration(days: 5)),
        additionalVisitors: 1,
        additionalVisitorNames: ['Sita Sharma'],
        prisonerName: 'Ravi Sharma',
        prisonerFatherName: 'Naresh Sharma',
        prisonerAge: 40,
        prisonerGender: 'Male',
        mode: true,
        status: VisitStatus.pending,
        startTime: '14:00',
        endTime: '16:30',
        dayOfWeek: 'Friday',
        prison: 'CENTRAL JAIL NO.2, TIHAR',
      ),
      VisitorModel(
        visitorName: 'Sunita Roy',
        fatherName: 'Bimal Roy',
        address: '321 MG Road, Nagpur',
        gender: 'Female',
        age: 38,
        relation: 'Wife',
        idProof: 'Passport',
        idNumber: 'P1234567',
        isInternational: false,
        state: 'Maharashtra',
        jail: 'Nagpur Central Jail',
        visitDate: DateTime.now().subtract(Duration(days: 3)),
        additionalVisitors: 0,
        additionalVisitorNames: [],
        prisonerName: 'Rajesh Roy',
        prisonerFatherName: 'Mohan Roy',
        prisonerAge: 42,
        prisonerGender: 'Male',
        mode: false,
        status: VisitStatus.expired,
        startTime: '11:00',
        endTime: '13:00',
        dayOfWeek: 'Thursday',
        prison: 'Nagpur Central Jail',
      ),
    ];
  }

  void _handleAppBarBack() {
    if (_showAdditionalVisitorsList) {
      setState(() {
        _showAdditionalVisitorsList = false;
      });
    } else if (_showingVisitCards) {
      if (widget.fromNavbar || widget.fromRegisteredInmates) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      if (widget.fromChatbot) {
        Navigator.pop(context);
      } else if (widget.fromNavbar && !widget.showVisitCards) {
        setState(() {
          _showingVisitCards = true;
          _clearFormData();
        });
      } else {
        _onWillPop();
      }
    }
  }

  void _clearFormData() {
    _prisonerNameController.clear();
    _prisonController.clear();
    _visitDateController.clear();
    _selectedVisitMode = null;
    for (var controller in _additionalVisitorControllers) {
      controller.dispose();
    }
    _additionalVisitorControllers.clear();
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

  void _showReadOnlyAlert(String fieldName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, color: Colors.orange, size: 60),
              SizedBox(height: 16),
              Text(
                "Field Locked",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Can't edit $fieldName field. This information is pre-filled and cannot be modified.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5A8BBA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
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

  void _populateFormData() {
    if (widget.visitorData != null) {
      final visitor = widget.visitorData!;
      _prisonerNameController.text = visitor.prisonerName;
      _prisonController.text = visitor.prison ?? '';
      _visitDateController.text = DateFormat('dd/MM/yyyy').format(visitor.visitDate);
      _selectedVisitMode = visitor.mode ? 'Video Conferencing' : 'Physical';

      for (int i = 0; i < visitor.additionalVisitors; i++) {
        _additionalVisitorControllers.add(TextEditingController());
        if (i < visitor.additionalVisitorNames.length) {
          _additionalVisitorControllers[i].text = visitor.additionalVisitorNames[i];
        }
      }
    } else if (widget.fromRegisteredInmates) {
      _prisonerNameController.text = widget.prefilledPrisonerName ?? '';
      _prisonController.text = widget.prefilledPrison ?? '';
      _isReadOnlyMode = true;
    }
  }

  void _addVisitorField() {
    setState(() {
      _additionalVisitorControllers.add(TextEditingController());
    });
  }

  void _removeVisitorField(int index) {
    if (_additionalVisitorControllers.length > 1) {
      setState(() {
        _additionalVisitorControllers[index].dispose();
        _additionalVisitorControllers.removeAt(index);
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_showingVisitCards) {
      return true;
    }

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Please use Logout and close the App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      ),
    ) ?? false;
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                "Your visit has been successfully scheduled!",
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
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                // Header with Serial No. and Prisoner Name
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
                _buildInfoRow(Icons.perm_identity, "Father Name: ${inmate['visitorName']}"),

                // Gender/Age with arrow icon
                Row(
                  children: [
                    const Icon(Icons.badge, size: 18, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Gender/Age: ${inmate['genderAge']}",
                        style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeetFormScreen(
                              selectedIndex: 1,
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

                _buildInfoRow(Icons.family_restroom, "Relation: ${inmate['relation']}"),
                _buildInfoRow(Icons.meeting_room, "Mode of Visit: ${inmate['modeOfVisit']}"),
                _buildInfoRow(Icons.location_on, "Prison: ${inmate['prison']}"),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // Meeting Form View
  Widget _buildMeetingFormView() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormSectionTitle(title: 'Meeting Details'),
            SizedBox(height: 20),

            // Prisoner Name - Read only when from registered inmates or visit cards
            _buildReadOnlyTextField(
              controller: _prisonerNameController,
              label: 'Prisoner Name*',
              hint: 'Enter prisoner Name',
              validator: Validators.validateName,
              readOnly: _isReadOnlyMode,
              fieldName: 'Prisoner Name',
            ),
            SizedBox(height: 20),

            // Prison Address - Read only when from registered inmates or visit cards
            _buildReadOnlyTextField(
              controller: _prisonController,
              label: 'Prison*',
              hint: 'Prison',
              validator: (value) => value!.isEmpty ? 'Prison is required' : null,
              readOnly: _isReadOnlyMode,
              maxLines: 2,
              fieldName: 'Prison',
            ),
            SizedBox(height: 20),

            // Visit Date - Always editable
            TextFormField(
              controller: _visitDateController,
              decoration: InputDecoration(
                labelText: 'Visit Date*',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
                fillColor: Colors.white,
                filled: true,
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
            SizedBox(height: 20),

            // Visit Mode Selection - Always editable
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode of Visit*',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _visitModes.map((visitMode) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(
                          value: visitMode,
                          groupValue: _selectedVisitMode,
                          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onChanged: (value) {
                            setState(() {
                              _selectedVisitMode = value;
                            });
                          },
                        ),
                        Text(
                          visitMode,
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(width: 25),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Additional Visitors Section with improved UI
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Additional Visitors List',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5A8BBA),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAdditionalVisitorsList = true;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF5A8BBA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Dynamic Additional Visitor Fields
                  // Only show fields when controllers list is not empty
                  if (_additionalVisitorControllers.isNotEmpty)
                    for (int i = 0; i < _additionalVisitorControllers.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _additionalVisitorControllers[i],
                                label: 'Additional Visitor Name ${i + 1}',
                                hint: 'Enter Additional visitor name',
                                inputFormatters: [
                                  TextInputFormatter.withFunction((oldValue, newValue) {
                                    String text = newValue.text;
                                    if (text.isNotEmpty) {
                                      text = text.split(' ').map((word) {
                                        if (word.isNotEmpty) {
                                          return word[0].toUpperCase() +
                                              word.substring(1).toLowerCase();
                                        }
                                        return word;
                                      }).join(' ');
                                    }
                                    return TextEditingValue(
                                      text: text,
                                      selection:
                                      TextSelection.collapsed(offset: text.length),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            if (_additionalVisitorControllers.length > 1)
                              IconButton(
                                onPressed: () => _removeVisitorField(i),
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Schedule Visit Button
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Save',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_selectedVisitMode == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please select visit mode'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _showAdditionalVisitorsList
            ? Colors.white
            : (_showingVisitCards ? Colors.grey[100] : Colors.white),
        body: _showAdditionalVisitorsList
            ? _buildAdditionalVisitorsListView()
            : (_showingVisitCards ? _buildVerticalList() : _buildMeetingFormView()),
        appBar: AppBar(
          title: Text(_showAdditionalVisitorsList
              ? 'Additional Visitors'
              : (_showingVisitCards ? 'Meeting Data' : 'Visit Form')),
          centerTitle: true,
          backgroundColor: const Color(0xFF5A8BBA),
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleAppBarBack,
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
                  _buildNavItem(
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
                  _buildNavItem(
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
                  _buildNavItem(
                    index: 2,
                    icon: Icons.gavel,
                    label: 'Parole',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParoleHomeScreen(selectedIndex: 2),
                        ),
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
                        MaterialPageRoute(builder: (context) => GrievanceDetailsScreen(selectedIndex: 3)),
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
    _prisonController.dispose();
    _visitDateController.dispose();
    for (var controller in _additionalVisitorControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}


