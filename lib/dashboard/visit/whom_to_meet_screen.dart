import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/visitor_model.dart';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/vertical_visit_card.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';
import '../grievance/grievance_home.dart';
import '../parole/parole_home.dart';

class MeetFormScreen extends StatefulWidget {
  final bool fromChatbot;
  final int selectedIndex;
  final VisitorModel? visitorData;
  final bool fromNavbar; // New parameter to distinguish navigation path
  final bool fromRegisteredInmates; // New parameter for direct navigation
  final String? prefilledPrisonerName; // For prefilled data
  final String? prefilledPrison; // For prefilled prison address
  final bool showVisitCards; // New parameter to show visit cards first

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
  bool _showingVisitCards = false; // Track current view
  String selectedVisitType = 'Meeting'; // Default selection
  String selectedStatus = 'All';
  final List<String> _visitModes = ['Physical', 'Video Conferencing'];

  Map<String, List<VisitorModel>> visitData = {
    'Meeting': [],
  };

  // Sample visit cards data
  final List<Map<String, dynamic>> visitCards = [
    {
      "date": "16",
      "month": "Aug",
      "year": "2025",
      "day": "Saturday",
      "time": "14:00 - 16:30",
      "prisonerName": "Ravi Sharma",
      "prison": "CENTRAL JAIL NO.2, TIHAR",
      "status": "Pending",
      "additionalParticipants": "1 additional participant",
    },
    {
      "date": "18",
      "month": "Aug",
      "year": "2025",
      "day": "Monday",
      "time": "10:00 - 12:00",
      "prisonerName": "Ashok Kumar",
      "prison": "CENTRAL JAIL NO.3, TIHAR",
      "status": "Confirmed",
      "additionalParticipants": "2 additional participants",
    },
    {
      "date": "20",
      "month": "Aug",
      "year": "2025",
      "day": "Wednesday",
      "time": "15:00 - 17:00",
      "prisonerName": "Anil Kumar",
      "prison": "PHQ DELHI",
      "status": "Pending",
      "additionalParticipants": "No additional participants",
    },
  ];

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
    if (_showingVisitCards) {
      // If showing visit cards and came from form navigation, go back to previous screen
      if (widget.fromNavbar || widget.fromRegisteredInmates) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } else {
      // If in form view
      if (widget.fromChatbot) {
        // If came from chatbot, go back to chatbot (preserves chat history)
        Navigator.pop(context);
      } else if (widget.fromNavbar && !widget.showVisitCards) {
        // If came from navbar but not showing cards initially, go back to cards
        setState(() {
          _showingVisitCards = true;
          _clearFormData();
        });
      } else {
        // Normal app flow - show alert
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

  // Method to show read-only field alert
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
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;

    // Initialize visit data first
    initializeVisitData();

    // Determine initial view and mode
    // FIXED: When coming from navbar, always show visit cards first
    if (widget.fromNavbar) {
      _showingVisitCards = true;
      _isReadOnlyMode = false; // Don't set readonly initially for navbar
    } else {
      _showingVisitCards = widget.showVisitCards;
      _isReadOnlyMode = widget.fromRegisteredInmates;
    }

    if (!_showingVisitCards) {
      // Populate form data if not showing visit cards
      _populateFormData();
      // Add initial visitor field
      _additionalVisitorControllers.add(TextEditingController());
    }
  }

  void _populateFormData() {
    if (widget.visitorData != null) {
      // From existing visitor data (editing mode)
      final visitor = widget.visitorData!;
      _prisonerNameController.text = visitor.prisonerName;
      _prisonController.text = visitor.prison ?? '';
      _visitDateController.text = DateFormat('dd/MM/yyyy').format(visitor.visitDate);
      _selectedVisitMode = visitor.mode ? 'Video Conferencing' : 'Physical';

      // Populate additional visitors
      for (int i = 0; i < visitor.additionalVisitors; i++) {
        _additionalVisitorControllers.add(TextEditingController());
        if (i < visitor.additionalVisitorNames.length) {
          _additionalVisitorControllers[i].text = visitor.additionalVisitorNames[i];
        }
      }
    } else if (widget.fromRegisteredInmates) {
      // From registered inmates with prefilled data
      _prisonerNameController.text = widget.prefilledPrisonerName ?? '';
      _prisonController.text = widget.prefilledPrison ?? '';
      _isReadOnlyMode = true; // Set readonly for registered inmates
    }
  }

  // FIXED: Updated this method to properly handle card tap
  void _navigateToForm(VisitorModel visitor) {
    setState(() {
      _showingVisitCards = false;
      _isReadOnlyMode = true; // Set to read-only when coming from visit cards

      // Populate form with selected visitor data
      _prisonerNameController.text = visitor.prisonerName;
      _prisonController.text = visitor.prison ?? '';
      _visitDateController.text = DateFormat('dd/MM/yyyy').format(visitor.visitDate);
      _selectedVisitMode = visitor.mode ? 'Video Conferencing' : 'Physical';

      // Clear and populate additional visitors
      for (var controller in _additionalVisitorControllers) {
        controller.dispose();
      }
      _additionalVisitorControllers.clear();

      // Add initial visitor field
      _additionalVisitorControllers.add(TextEditingController());

      // Populate additional visitor names if any
      for (int i = 0; i < visitor.additionalVisitorNames.length; i++) {
        if (i >= _additionalVisitorControllers.length) {
          _additionalVisitorControllers.add(TextEditingController());
        }
        _additionalVisitorControllers[i].text = visitor.additionalVisitorNames[i];
      }
    });
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
      return true; // Allow normal back navigation for visit cards
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

  Widget buildVerticalVisitsList() {
    List<VisitorModel> filteredVisits = getFilteredVisits();

    if (filteredVisits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No ${selectedStatus.toLowerCase()} ${selectedVisitType.toLowerCase()} found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showingVisitCards = false;
                  _isReadOnlyMode = false; // Allow editing for new visits
                  _additionalVisitorControllers.add(TextEditingController());
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5A8BBA),
                foregroundColor: Colors.white,
              ),
              child: Text('Create New Visit'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: filteredVisits.map((visitor) {
          return VerticalVisitCard(
            visitor: visitor,
            onTap: () {
              print('Selected visit: ${visitor.visitorName} - Prison: ${visitor.prison}');
              _navigateToForm(visitor); // FIXED: Pass the visitor object
            }, sourceType: '',
          );
        }).toList(),
      ),
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
  }) {
    return GestureDetector(
      onTap: readOnly ? () => _showReadOnlyAlert(fieldName ?? label) : null,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
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
              label: 'Prison *',
              hint: 'Prison Address',
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
            // Dynamic Additional Visitor Fields
            for (int i = 0; i < _additionalVisitorControllers.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
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
                    if (_additionalVisitorControllers.length > 1)
                      IconButton(
                        onPressed: () => _removeVisitorField(i),
                        icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                      ),
                  ],
                ),
              ),

            // Add Visitor Button
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addVisitorField,
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text('Add', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5A8BBA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
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
        backgroundColor: _showingVisitCards ? Colors.grey[100] : Colors.white,
        body: _showingVisitCards ? buildVerticalVisitsList() : _buildMeetingFormView(),
        appBar: AppBar(
          title: Text(_showingVisitCards ? 'Visit History' : 'Visit Form'),
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
                        MaterialPageRoute(builder: (context) => MeetFormScreen(
                          selectedIndex: 1,
                          fromNavbar: true, // FIXED: Set fromNavbar to true
                        )),
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
                        MaterialPageRoute(
                          builder: (context) => GrievanceHomeScreen(selectedIndex: 3),
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
    _prisonerNameController.dispose();
    _prisonController.dispose();
    _visitDateController.dispose();
    for (var controller in _additionalVisitorControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}