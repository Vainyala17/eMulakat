import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/visitor_model.dart';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/bottom_nav_bar.dart';
import '../../screens/home/home_screen.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/device_service.dart';
import '../../utils/color_scheme.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/read_only_text_fields.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../parole/parole_screen.dart';
import '../visit/whom_to_meet_screen.dart';

class GrievanceDetailsScreen extends StatefulWidget {
  final bool fromChatbot;
  final int selectedIndex;
  final VisitorModel? visitorData;
  final bool fromNavbar;
  final bool fromRegisteredInmates;
  final String? prefilledPrisonerName;
  final String? prefilledPrison;
  final bool showVisitCards;

  const GrievanceDetailsScreen({
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
  _GrievanceDetailsScreenState createState() => _GrievanceDetailsScreenState();
}

class _GrievanceDetailsScreenState extends State<GrievanceDetailsScreen> {
  int _selectedIndex = 0;
  bool _showingVisitCards = false;
  late WebViewController controller;
  bool _isReadOnlyMode = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController(); // Added separate controller for message

  final TextEditingController _prisonerNameController = TextEditingController();
  final TextEditingController _prisonController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  final List<String> _category = [
    'SELECT',
    'III Treated by the prison authorities',
    'Basic Facilities not provided inside prison',
    'Manhandling by co prisoners',
    'Others'
  ];

  Map<String, List<VisitorModel>> visitData = {
    'Grievance': [],
  };

  final List<Map<String, dynamic>> inmates = [
    {
      "serial": 1,
      "prisonerName": "Sid Kumar",
      "category": "III Treated by the prison authorities",
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 2,
      "prisonerName": "Dilip Mhatre",
      "category": "Manhandling by co prisoners",
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 3,
      "prisonerName": "Nirav Rao",
      "category": "other",
      "prison": "PHQ",
    },
    {
      "serial": 4,
      "prisonerName": "Mahesh Patil",
      "category": "Basic Facilities not provided inside prison",
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 5,
      "prisonerName": "Ramesh Dodhia",
      "category": "Manhandling by co prisoners",
      "prison": "PHQ",
    }
  ];

  @override
  void initState() {
    super.initState();
    AuthService.checkAndHandleSession(context);
    _selectedIndex = widget.selectedIndex;
    //initializeVisitData();
    _loadDashboard();

    // 🔥 NEW: Capture device info once when screen loads
    _captureDeviceInfo();

    // Show visit cards by default unless explicitly coming from registered inmates
    if (widget.fromRegisteredInmates) {
      _showingVisitCards = false;
      _isReadOnlyMode = true;

      // ✅ Add this: Populate prefilled values
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
// Add this new method to GrievanceDetailsScreen class:
  /// Capture device information once per installation
  Future<void> _captureDeviceInfo() async {
    try {
      await DeviceService.captureDeviceInfoOnce(screenName: 'Grievance');
    } catch (e) {
      print('❌ Error in grievance device info capture: $e');
    }
  }

  Future<void> _loadDashboard() async {
    final api = ApiService();
    final dashboard = await api.getDashboardSummary("7702000725");
    print(dashboard); // <-- test output
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
        'category': _selectedCategory ?? '',
        'message': _messageController.text,
      };

      // Call API service
      final response = await ApiService.raiseGrievanceRequest(requestBody);

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
                    response['message'] ?? 'Grievance request submitted successfully!',
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
                // Gender/Age with arrow icon
                Row(
                  children: [
                    const Icon(Icons.badge, size: 18, color: Colors.black),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Category: ${inmate['category']}",
                        style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GrievanceDetailsScreen(
                              selectedIndex: 3,
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
                _buildInfoRow(Icons.location_on, "Prison: ${inmate['prison']}"),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
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

  Widget _buildGrievanceForm(){
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormSectionTitle(title: 'Grievance Details'),
            SizedBox(height: 20),
// Prisoner Name - Read only when from registered inmates or visit cards
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

            // Prison Address - Read only when from registered inmates or visit cards
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
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _showingVisitCards ? _buildVerticalList() : _buildGrievanceForm(),
        appBar: AppBar(
          title: const Text('Grievance'),
          centerTitle: true,
          backgroundColor: const Color(0xFF5A8BBA),
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Normal back navigation
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
                    selectedIndex : _selectedIndex,
                    index: 0,
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 0)),
                      );
                    },
                  ),
                  buildNavItem(
                    selectedIndex : _selectedIndex,
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
                    selectedIndex : _selectedIndex,
                    index: 2,
                    icon: Icons.gavel,
                    label: 'Parole',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParoleScreen(selectedIndex: 2),
                        ),
                      );
                    },
                  ),
                  buildNavItem(
                    selectedIndex : _selectedIndex,
                    index: 3,
                    icon: Icons.report_problem,
                    label: 'Grievance',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => GrievanceDetailsScreen(
                          selectedIndex: 3,
                          fromNavbar: true,)
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
    _messageController.dispose();
    super.dispose();
  }
}