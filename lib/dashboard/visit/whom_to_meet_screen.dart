import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/visitor_model.dart';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/bottom_nav_bar.dart';
import '../../screens/home/home_screen.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/color_scheme.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/image_uploading.dart';
import '../../utils/read_only_text_fields.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';
import '../grievance/grievance_details_screen.dart';
import '../parole/parole_screen.dart';
import 'additional_visitors.dart';

// Model class for additional visitors
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
  File? passportImage;
  File? idProofImage;
  bool isNewlyAdded;

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
    this.passportImage,
    this.idProofImage,
    this.isNewlyAdded = false,
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
  // State variables
  late int _selectedIndex;
  late bool _showingVisitCards;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _prisonerNameController = TextEditingController();
  final TextEditingController _prisonController = TextEditingController();
  final TextEditingController _visitDateController = TextEditingController();

  // Form state
  String? _selectedVisitMode;
  List<TextEditingController> _additionalVisitorControllers = [];
  bool _isReadOnlyMode = false;
  bool _showAdditionalVisitorsList = false;
  String selectedVisitType = 'Meeting';
  String selectedStatus = 'All';
  bool _isLoading = false;
  // Constants
  final List<String> _visitModes = ['Physical', 'Video Conferencing'];
  final List<String> _idProofTypes = [
    'Aadhar Card',
    'Voter ID',
    'Passport',
    'Driving License',
    'PAN Card'
  ];

  // Data
  List<AdditionalVisitor> _selectedVisitorsForDisplay = [];
  List<AdditionalVisitor> _previousVisitors = [];
  Map<String, List<VisitorModel>> visitData = {'Meeting': []};

  // Sample data
  final List<Map<String, dynamic>> inmates = [
    {
      "serial": 1,
      "prisonerName": "Ashok Kumar",
      "fatherName": "Govind Ram",
      "genderAge": "M/47",
      "relation": "Brother",
      "modeOfVisit": "Yes",
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 2,
      "prisonerName": "Anil Kumar",
      "fatherName": "Kewal Singh",
      "genderAge": "M/57",
      "relation": "Lawyer",
      "modeOfVisit": "Yes",
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 3,
      "prisonerName": "Test",
      "fatherName": "Rajesh",
      "genderAge": "M/21",
      "relation": "Lawyer",
      "modeOfVisit": "-",
      "prison": "PHQ",
    }
  ];

  @override
  void initState() {
    super.initState();
    AuthService.checkAndHandleSession(context);
    _selectedIndex = widget.selectedIndex;
    _initializePreviousVisitors();
    //_initializeVisitData();
    _setupInitialState();
    _loadDashboard();

  }

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
        'mode': _selectedVisitMode ?? '',
        'visit Date': _visitDateController.text,
        'visitors': _additionalVisitorControllers.map((c) => c.text).join(','),
      };

      // Call API service
      final response = await ApiService.raiseMeetingRequest(requestBody);

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
            const Icon(Icons.check_circle, color: Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    response['message'] ?? 'Meeting request submitted successfully!',
                    style: const TextStyle(color: Colors.black), // ✅ Fix here
                  ),
                  if (response['applicationId'] != null)
                    Text(
                      'ID: ${response['applicationId']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),

            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );

    // Navigate back after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
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

  Future<void> _loadDashboard() async {
    final api = ApiService();
    final dashboard = await api.getDashboardSummary("7702000725");
    print(dashboard); // <-- test output
  }

  void _setupInitialState() {
    if (widget.fromNavbar) {
      _showingVisitCards = true;
      _isReadOnlyMode = false;
    } else {
      _showingVisitCards = widget.showVisitCards;
      _isReadOnlyMode = widget.fromRegisteredInmates;
    }

    if (!_showingVisitCards) {
      _populateFormData();
    }
  }

  void _initializePreviousVisitors() {
    _previousVisitors = [
      AdditionalVisitor(
        visitorName: 'MEENA',
        fatherName: 'KAMAL KISHORE',
        relation: 'Sister',
        mobileNumber: 'XXXXXXXX',
        idProofType: 'Passport',
        idProofNumber: 'P1234567',
        isNewlyAdded: false,
      ),
      AdditionalVisitor(
        visitorName: 'KAMLESH',
        fatherName: 'VINESH',
        relation: 'Sister',
        mobileNumber: 'XXXXXXXX',
        idProofType: 'Driving License',
        idProofNumber: 'DL123456',
        isNewlyAdded: false,
      ),
    ];
  }

  Future<void> _pickImageForVisitor(String imageType, AdditionalVisitor visitor) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageForVisitor(ImageSource.camera, imageType, visitor);
                },
              ),
              ListTile(
                leading: Icon(Icons.image_search),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageForVisitor(ImageSource.gallery, imageType, visitor);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImageForVisitor(ImageSource source, String imageType, AdditionalVisitor visitor) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) {
      _showSnackBar('No image selected', Colors.orange);
      return;
    }

    final file = File(pickedFile.path);
    final fileSize = await file.length();

    if (fileSize > 1000 * 1024) {
      _showSnackBar('Selected image exceeds 1MB limit', Colors.red);
      return;
    }

    if (imageType == 'passport') {
      await _handlePassportImage(file, visitor);
    } else if (imageType == 'idproof') {
      await _handleIdProofImage(file, visitor);
    }
  }

  Future<void> _handlePassportImage(File file, AdditionalVisitor visitor) async {
    _showLoadingDialog();

    try {
      final isValid = await isImageSharpAndFaceVisible(file);
      Navigator.pop(context);

      if (!isValid) {
        _showSnackBar('Photo must be sharp and contain a visible face', Colors.red);
        return;
      }

      setState(() {
        visitor.passportImage = file;
        visitor.photoPath = 'visitor_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      });

      _showSnackBar('Photo uploaded successfully!', Colors.green);
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar('Error validating image: $e', Colors.red);
    }
  }

  Future<void> _handleIdProofImage(File file, AdditionalVisitor visitor) async {
    if (visitor.idProofNumber?.isEmpty ?? true) {
      _showSnackBar('Please enter ID number before uploading document', Colors.orange);
      return;
    }

    _showLoadingDialog();

    try {
      final isMatch = await isIdNumberInDocument(file, visitor.idProofNumber!);
      Navigator.pop(context);

      if (!isMatch) {
        _showSnackBar('ID number does not match document', Colors.red);
        return;
      }

      setState(() {
        visitor.idProofImage = file;
        visitor.idProofPath =
        '${visitor.idProofType?.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      });

      _showSnackBar('ID proof uploaded successfully!', Colors.green);
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar('Error validating document: $e', Colors.red);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {
    Color? iconColor,
    Color? textColor,
    double? iconSize,
    double? fontSize,
    FontWeight? fontWeight,
    String? label,
    String? value,
  }) {
    if (label != null && value != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Icon(
              icon,
              size: iconSize ?? 16,
              color: iconColor ?? Colors.grey.shade600,
            ),
            SizedBox(width: 6),
            Text(
              '$label: ',
              style: TextStyle(
                fontSize: fontSize ?? 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: fontSize ?? 14,
                  color: textColor ?? Colors.black87,
                  fontWeight: fontWeight ?? FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
              icon,
              size: iconSize ?? 18,
              color: iconColor ?? Colors.black
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 14,
                fontWeight: fontWeight ?? FontWeight.bold,
                color: textColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: inmates.length,
      itemBuilder: (context, index) {
        final inmate = inmates[index];
        return _buildInmateCard(inmate);
      },
    );
  }

  Widget _buildInmateCard(Map<String, dynamic> inmate) {
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
            _buildInmateHeader(inmate),
            const SizedBox(height: 4),
            _buildInmateDetails(inmate),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildInmateHeader(Map<String, dynamic> inmate) {
    return Row(
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.download, color: Colors.blue),
          onPressed: () => _showSnackBar('Download functionality coming soon', Colors.blue),
        ),
      ],
    );
  }

  Widget _buildInmateDetails(Map<String, dynamic> inmate) {
    return Column(
      children: [
        _buildInfoRow(Icons.perm_identity, "Father Name: ${inmate['fatherName']}"),
        _buildGenderAgeRow(inmate),
        _buildInfoRow(Icons.family_restroom, "Relation: ${inmate['relation']}"),
        _buildInfoRow(Icons.meeting_room, "Mode of Visit: ${inmate['modeOfVisit']}"),
        _buildInfoRow(Icons.location_on, "Prison: ${inmate['prison']}"),
      ],
    );
  }

  Widget _buildGenderAgeRow(Map<String, dynamic> inmate) {
    return Row(
      children: [
        const Icon(Icons.badge, size: 18, color: Colors.black),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "Gender/Age: ${inmate['genderAge']}",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        _buildArrowButton(inmate),
      ],
    );
  }

  Widget _buildArrowButton(Map<String, dynamic> inmate) {
    return GestureDetector(
      onTap: () => _navigateToMeetingForm(inmate),
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
    );
  }

  void _navigateToMeetingForm(Map<String, dynamic> inmate) {
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
  }

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
            _buildFormFields(),
            SizedBox(height: 20),
            _buildVisitModeSelection(),
            SizedBox(height: 20),
            _buildAdditionalVisitorsSection(),
            _buildSelectedVisitorsList(),
            SizedBox(height: 30),
            _buildSaveButton(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        buildReadOnlyTextField(
          context: context,
          controller: _prisonerNameController,
          label: 'Prisoner Name*',
          hint: 'Enter prisoner Name',
          validator: Validators.validateName,
          readOnly: _isReadOnlyMode,
          fieldName: 'Prisoner Name',
        ),
        SizedBox(height: 20),
        buildReadOnlyTextField(
          context: context,
          controller: _prisonController,
          label: 'Prison*',
          hint: 'Prison',
          validator: (value) => value!.isEmpty ? 'Prison is required' : null,
          readOnly: _isReadOnlyMode,
          maxLines: 2,
          fieldName: 'Prison',
        ),
        SizedBox(height: 20),
        _buildDateField(),
      ],
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _visitDateController,
      decoration: InputDecoration(
        labelText: 'Visit Date*',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
        fillColor: Colors.white,
        filled: true,
      ),
      readOnly: true,
      onTap: _selectDate,
      validator: (value) => value!.isEmpty ? 'Please select visit date' : null,
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (pickedDate != null) {
      _visitDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  Widget _buildVisitModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode of Visit*',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: _visitModes.map((visitMode) => _buildRadioOption(visitMode)).toList(),
        ),
      ],
    );
  }

  Widget _buildRadioOption(String visitMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: visitMode,
          groupValue: _selectedVisitMode,
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (value) => setState(() => _selectedVisitMode = value),
        ),
        Text(visitMode, style: TextStyle(fontSize: 15)),
        SizedBox(width: 25),
      ],
    );
  }

  Widget _buildAdditionalVisitorsSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFDDE5ED),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
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
          _buildAddVisitorButton(),
        ],
      ),
    );
  }

  Widget _buildAddVisitorButton() {
    return GestureDetector(
      onTap: () => setState(() => _showAdditionalVisitorsList = true),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFF5A8BBA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildSelectedVisitorsList() {
    if (_additionalVisitorControllers.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          'Added Visitors:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5A8BBA),
          ),
        ),
        SizedBox(height: 10),
        ...List.generate(
          _selectedVisitorsForDisplay.length,
              (index) => _buildVisitorCard(index),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVisitorCard(int index) {
    final visitor = _selectedVisitorsForDisplay[index];
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visitor.visitorName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('Father: ${visitor.fatherName}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Text('Relation: ${visitor.relation}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                Text('Mobile: ${visitor.mobileNumber}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeVisitor(index),
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _removeVisitor(int index) {
    setState(() {
      _selectedVisitorsForDisplay.removeAt(index);
      if (index < _additionalVisitorControllers.length) {
        _additionalVisitorControllers[index].dispose();
        _additionalVisitorControllers.removeAt(index);
      }
    });
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Save',
        onPressed: () => _handleFormSubmission(),
      ),
    );
  }

  // Additional visitor list methods
  Widget _buildAdditionalVisitorsListView() {
    List<AdditionalVisitor> sortedVisitors = _getSortedVisitors();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Removed the banner message completely
          Expanded(child: _buildVisitorsList(sortedVisitors)),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildVisitorsList(List<AdditionalVisitor> sortedVisitors) {
    print("DEBUG: Building visitors list with ${sortedVisitors.length} visitors");
    for (int i = 0; i < sortedVisitors.length; i++) {
      print("DEBUG: Visitor $i: ${sortedVisitors[i].visitorName}, isNewlyAdded: ${sortedVisitors[i].isNewlyAdded}");
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sortedVisitors.length + 1,
      itemBuilder: (context, index) {
        if (index == sortedVisitors.length) {
          return _buildAddNewVisitorButton();
        }
        return _buildAdditionalVisitorCard(sortedVisitors[index], index);
      },
    );
  }

  Widget _buildAddNewVisitorButton() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: ElevatedButton.icon(
        onPressed: _navigateToAddNewVisitor,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add New Visitor',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF5A8BBA),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _navigateToAddNewVisitor() async {
    print("DEBUG: Navigating to AddNewVisitorScreen");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNewVisitorScreen()),
    );

    print("DEBUG: Got result: ${result != null}");
    if (result != null) {
      print("DEBUG: Result type: ${result.runtimeType}");
      print("DEBUG: Visitor name: ${result.visitorName}");

      try {
        // Create a NEW AdditionalVisitor using your MeetFormScreen's class
        // by copying the data from the returned visitor
        final newVisitor = AdditionalVisitor(
          visitorName: result.visitorName,
          fatherName: result.fatherName,
          relation: result.relation,
          mobileNumber: result.mobileNumber,
          photoPath: result.photoPath,
          idProofType: result.idProofType,
          idProofNumber: result.idProofNumber,
          idProofPath: result.idProofPath,
          passportImage: result.passportImage,
          idProofImage: result.idProofImage,
          isNewlyAdded: true,
          isSelected: true,
        );

        print("DEBUG: Created compatible visitor object");

        setState(() {
          _previousVisitors.insert(0, newVisitor);
        });

        print("DEBUG: List length now: ${_previousVisitors.length}");
        _showSnackBar('${newVisitor.visitorName} added successfully and selected!', Colors.green);

      } catch (e) {
        print("DEBUG: Error creating visitor: $e");
        _showSnackBar('Error adding visitor. Please try again.', Colors.red);
      }
    }
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _addSelectedVisitorsToForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF5A8BBA),
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('Add Selected Visitors', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  List<AdditionalVisitor> _getSortedVisitors() {
    List<AdditionalVisitor> sortedVisitors = List.from(_previousVisitors);
    sortedVisitors.sort((a, b) {
      if (a.isNewlyAdded && !b.isNewlyAdded) return -1;
      if (!a.isNewlyAdded && b.isNewlyAdded) return 1;
      if (a.isSelected && !b.isSelected) return -1;
      if (!a.isSelected && b.isSelected) return 1;
      return 0;
    });
    return sortedVisitors;
  }

  Widget _buildAdditionalVisitorCard(AdditionalVisitor visitor, int index) {
    Color cardBorderColor = visitor.isNewlyAdded
        ? Colors.green
        : (visitor.isSelected ? const Color(0xFF5A8BBA) : Colors.grey.shade600);

    Color cardBackgroundColor = visitor.isNewlyAdded
        ? Colors.green.withOpacity(0.05)
        : (visitor.isSelected
        ? const Color(0xFF5A8BBA).withOpacity(0.05)
        : Colors.grey.shade50);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardBorderColor,
          width: visitor.isSelected || visitor.isNewlyAdded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildVisitorCardHeader(visitor, cardBackgroundColor, cardBorderColor),
          if (visitor.isSelected) _buildDocumentUploadSection(visitor),
        ],
      ),
    );
  }

  Widget _buildVisitorCardHeader(AdditionalVisitor visitor, Color backgroundColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Column(
        children: [
          if (visitor.isNewlyAdded) _buildNewVisitorBadge(),
          Row(
            children: [
              // Visitor info comes first (left side)
              _buildVisitorInfo(visitor),
              const SizedBox(width: 12),
              // Checkbox on the right side
              _buildCustomCheckbox(visitor, borderColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewVisitorBadge() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'NEWLY ADDED',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCustomCheckbox(AdditionalVisitor visitor, Color borderColor) {
    return GestureDetector(
      onTap: () => setState(() => visitor.isSelected = !visitor.isSelected),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: visitor.isSelected ? borderColor : Colors.white,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: visitor.isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  Widget _buildVisitorInfo(AdditionalVisitor visitor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            visitor.visitorName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.person_outline, '',
              label: 'Father', value: visitor.fatherName),
          _buildInfoRow(Icons.family_restroom, '',
              label: 'Relation', value: visitor.relation),
          _buildInfoRow(Icons.phone, '',
              label: 'Mobile', value: visitor.mobileNumber),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadSection(AdditionalVisitor visitor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Upload',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5A8BBA),
            ),
          ),
          const SizedBox(height: 16),
          _buildDocumentSection(
            title: 'Visitor Photo',
            icon: Icons.photo_camera,
            isUploaded: visitor.photoPath != null || visitor.passportImage != null,
            uploadedFileName: visitor.photoPath,
            onUpload: () => _pickImageForVisitor('passport', visitor),
          ),
          const SizedBox(height: 16),
          _buildIdProofSection(visitor),
        ],
      ),
    );
  }

  Widget _buildIdProofSection(AdditionalVisitor visitor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ID Proof Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildIdTypeDropdown(visitor),
        const SizedBox(height: 12),
        _buildIdNumberField(visitor),
        const SizedBox(height: 12),
        _buildDocumentSection(
          title: 'ID Proof Document',
          icon: Icons.description,
          isUploaded: visitor.idProofPath != null || visitor.idProofImage != null,
          uploadedFileName: visitor.idProofPath,
          onUpload: () => _pickImageForVisitor('idproof', visitor),
        ),
      ],
    );
  }

  Widget _buildIdTypeDropdown(AdditionalVisitor visitor) {
    return DropdownButtonFormField<String>(
      value: visitor.idProofType,
      decoration: InputDecoration(
        labelText: 'Select ID Proof Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _idProofTypes.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        );
      }).toList(),
      onChanged: (String? newValue) => setState(() => visitor.idProofType = newValue),
    );
  }

  Widget _buildIdNumberField(AdditionalVisitor visitor) {
    return TextFormField(
      initialValue: visitor.idProofNumber,
      decoration: InputDecoration(
        labelText: 'Enter ID Number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      onChanged: (value) => visitor.idProofNumber = value,
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required IconData icon,
    required bool isUploaded,
    required String? uploadedFileName,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUploaded ? Colors.green.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isUploaded ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  isUploaded ? uploadedFileName ?? 'Document uploaded' : 'No document uploaded',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUploaded ? Colors.green.shade700 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded ? Colors.green.shade600 : Color(0xFF5A8BBA),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              elevation: 0,
            ),
            child: Text(
              isUploaded ? 'Replace' : 'Upload',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _addSelectedVisitorsToForm() {
    List<AdditionalVisitor> selectedVisitors =
    _previousVisitors.where((visitor) => visitor.isSelected).toList();

    if (selectedVisitors.isEmpty) {
      _showSnackBar('Please select at least one visitor', Colors.orange);
      return;
    }

    // Clear existing controllers
    for (var controller in _additionalVisitorControllers) {
      controller.dispose();
    }
    _additionalVisitorControllers.clear();
    _selectedVisitorsForDisplay.clear();

    // Add selected visitors
    for (var visitor in selectedVisitors) {
      _selectedVisitorsForDisplay.add(visitor);
      TextEditingController controller = TextEditingController();
      controller.text = visitor.visitorName;
      _additionalVisitorControllers.add(controller);
    }

    setState(() {
      _showAdditionalVisitorsList = false;
      // Reset selection but keep newly added status for future reference
      for (var visitor in _previousVisitors) {
        visitor.isSelected = false;
        // Only reset newly added flag after they've been processed
        if (visitor.isNewlyAdded) {
          visitor.isNewlyAdded = false;
        }
      }
    });

    _showSnackBar('${selectedVisitors.length} visitor(s) added successfully', Colors.green);
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

  List<VisitorModel> getFilteredVisits() {
    List<VisitorModel> currentVisits = visitData[selectedVisitType] ?? [];

    if (selectedStatus == 'All') return currentVisits;

    VisitStatus statusFilter;
    switch (selectedStatus) {
      case 'Pending': statusFilter = VisitStatus.pending; break;
      case 'Upcoming': statusFilter = VisitStatus.upcoming; break;
      case 'Completed': statusFilter = VisitStatus.completed; break;
      case 'Expired': statusFilter = VisitStatus.expired; break;
      default: return currentVisits;
    }

    return currentVisits.where((visit) => visit.status == statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => DialogUtils.onWillPop(context, showingCards: _showingVisitCards),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigation(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title = _showAdditionalVisitorsList
        ? 'Additional Visitors'
        : (_showingVisitCards ? 'Meeting Data' : 'Visit Form');

    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: const Color(0xFF5A8BBA),
      foregroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
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
    );
  }

  Widget _buildBody() {
    if (_showAdditionalVisitorsList) {
      return _buildAdditionalVisitorsListView();
    } else if (_showingVisitCards) {
      return _buildVerticalList();
    } else {
      return _buildMeetingFormView();
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
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
              _buildNavItem(0, Icons.dashboard, 'Dashboard', () => _navigateToHome(0)),
              _buildNavItem(1, Icons.directions_walk, 'Meeting', () => _navigateToMeeting()),
              _buildNavItem(2, Icons.gavel, 'Parole', () => _navigateToParole()),
              _buildNavItem(3, Icons.report_problem, 'Grievance', () => _navigateToGrievance()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, VoidCallback onTap) {
    return buildNavItem(
      index: index,
      selectedIndex: _selectedIndex,
      icon: icon,
      label: label,
      onTap: onTap,
    );
  }

  void _navigateToHome(int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: index)),
    );
  }

  void _navigateToMeeting() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MeetFormScreen(
          selectedIndex: 1,
          showVisitCards: true,
          fromNavbar: true,
        ),
      ),
    );
  }

  void _navigateToParole() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ParoleScreen(selectedIndex: 2)),
    );
  }

  void _navigateToGrievance() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GrievanceDetailsScreen(selectedIndex: 3)),
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