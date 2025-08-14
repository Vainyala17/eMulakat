import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/visitor_model.dart';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../utils/color_scheme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';
import '../grievance/grievance_details_screen.dart';
import '../parole/parole_screen.dart';
import 'additional_visitors.dart';

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
  File? passportImage;  // Add this
  File? idProofImage;   // Add this

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
    this.passportImage,   // Add this
    this.idProofImage,    // Add this
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
  List<AdditionalVisitor> _selectedVisitorsForDisplay = [];
  // Sample previous visitors data

  final List<AdditionalVisitor> _previousVisitors = [

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
  Map<String, List<VisitorModel>> visitData = {
    'Meeting': [],
  };

  @override
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
     // _additionalVisitorControllers.add(TextEditingController());
    }
  }
// Add Laplacian kernel for sharpness detection
  List<num> laplacianKernel = [
    0,  1,  0,
    1, -4,  1,
    0,  1,  0,
  ];

  double computeLaplacianVariance(img.Image image) {
    final grayscale = img.grayscale(image);

    final kernel = [
      [0, -1, 0],
      [-1, 4, -1],
      [0, -1, 0],
    ];

    int width = grayscale.width;
    int height = grayscale.height;

    double sum = 0;
    double sumSquared = 0;
    int pixelCount = 0;

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        double result = 0;

        for (int ky = 0; ky < 3; ky++) {
          for (int kx = 0; kx < 3; kx++) {
            final pixel = grayscale.getPixel(x + kx - 1, y + ky - 1);
            final luminance = img.getLuminance(pixel).toDouble();
            result += luminance * kernel[ky][kx];
          }
        }

        sum += result;
        sumSquared += result * result;
        pixelCount++;
      }
    }

    if (pixelCount == 0) return 0;

    double mean = sum / pixelCount;
    double variance = (sumSquared / pixelCount) - (mean * mean);
    return variance;
  }

  Future<bool> isImageSharpAndFaceVisible(File file, {double threshold = 100}) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return false;

      final variance = computeLaplacianVariance(image);
      print('Sharpness (variance): $variance');
      final isSharp = variance > threshold;

      if (!isSharp) return false;

      final inputImage = InputImage.fromFile(file);
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          enableContours: false,
          enableClassification: false,
        ),
      );

      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      final hasFace = faces.isNotEmpty;
      print('Face detected: $hasFace');

      return hasFace;
    } catch (e) {
      print('Error in face detection: $e');
      return false;
    }
  }

  Future<bool> isIdNumberInDocument(File imageFile, String enteredNumber) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizer = TextRecognizer();
    final result = await recognizer.processImage(inputImage);
    await recognizer.close();

    print(result.text);
    final extractedText = result.text.replaceAll(RegExp(r'\s+'), '');
    print(extractedText);
    final cleanedInput = enteredNumber.replaceAll(RegExp(r'\s+'), '');

    return extractedText.contains(cleanedInput);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected'), backgroundColor: Colors.orange),
      );
      return;
    }

    final file = File(pickedFile.path);
    final fileSize = await file.length();

    if (fileSize > 1000 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected image exceeds 1MB limit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (imageType == 'passport') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        final isValid = await isImageSharpAndFaceVisible(file);
        Navigator.pop(context);

        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo must be sharp and contain a visible face'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          visitor.passportImage = file;
          visitor.photoPath = 'visitor_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error validating image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (imageType == 'idproof') {
      if (visitor.idProofNumber == null || visitor.idProofNumber!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter ID number before uploading document'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        final isMatch = await isIdNumberInDocument(file, visitor.idProofNumber!);
        Navigator.pop(context);

        if (!isMatch) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ID number does not match document'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          visitor.idProofImage = file;
          visitor.idProofPath = '${visitor.idProofType?.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID proof uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error validating document: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: visitor.isSelected ? const Color(0xFF5A8BBA) : Colors.grey.shade600,
          width: visitor.isSelected ? 2 : 1,
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
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: visitor.isSelected
                  ? const Color(0xFF5A8BBA).withOpacity(0.05)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Custom Checkbox
                GestureDetector(
                  onTap: () {
                    setState(() {
                      visitor.isSelected = !visitor.isSelected;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: visitor.isSelected ? const Color(0xFF5A8BBA) : Colors.white,
                      border: Border.all(
                        color: visitor.isSelected
                            ? const Color(0xFF5A8BBA)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: visitor.isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Visitor Info
                Expanded(
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
                ),
              ],
            ),
          ),

          // Document Upload Section (only visible when selected)
          if (visitor.isSelected) ...[
            Container(
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

                  // Photo Upload
                  _buildDocumentSection(
                    title: 'Visitor Photo',
                    icon: Icons.photo_camera,
                    isUploaded: visitor.photoPath != null,
                    uploadedFileName: visitor.photoPath,
                    onUpload: () =>
                        _pickImageForVisitor('passport', visitor),
                  ),

                  const SizedBox(height: 16),

                  // ID Proof Details
                  const Text(
                    'ID Proof Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ID Type Dropdown
                  DropdownButtonFormField<String>(
                    value: visitor.idProofType,
                    decoration: InputDecoration(
                      labelText: 'Select ID Proof Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: _idProofTypes.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        visitor.idProofType = newValue;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  // ID Number Input
                  TextFormField(
                    initialValue: visitor.idProofNumber,
                    decoration: InputDecoration(
                      labelText: 'Enter ID Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    style:
                    const TextStyle(fontSize: 14, color: Colors.black87),
                    onChanged: (value) {
                      visitor.idProofNumber = value;
                    },
                  ),

                  const SizedBox(height: 12),

                  // ID Proof Upload
                  _buildDocumentSection(
                    title: 'ID Proof Document',
                    icon: Icons.description,
                    isUploaded: visitor.idProofPath != null,
                    uploadedFileName: visitor.idProofPath,
                    onUpload: () =>
                        _pickImageForVisitor('idproof', visitor),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  // Widget to build the additional visitors list view
  Widget _buildAdditionalVisitorsListView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
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
          // Bottom button area - not inside Expanded
          Container(
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

    // Clear existing controllers
    for (var controller in _additionalVisitorControllers) {
      controller.dispose();
    }
    _additionalVisitorControllers.clear();

    // Add selected visitors to display list and create controllers
    for (var visitor in selectedVisitors) {
      _selectedVisitorsForDisplay.add(visitor);
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

// Helper method for document upload sections
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
                  isUploaded
                      ? uploadedFileName ?? 'Document uploaded'
                      : 'No document uploaded',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
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
  // Replace your existing _buildInfoRow method with this unified version
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

    // Original format for your inmates list
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
                _buildInfoRow(Icons.perm_identity, "Father Name: ${inmate['fatherName']}"),

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
                        borderRadius: BorderRadius.circular(20),
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
            ),

            if (_additionalVisitorControllers.isNotEmpty)
              Column(
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
                  // Display visitor cards instead of just text fields
                  ...List.generate(
                    _selectedVisitorsForDisplay.length,
                        (index) => Container(
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
                                  _selectedVisitorsForDisplay[index].visitorName,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Father: ${_selectedVisitorsForDisplay[index].fatherName}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                                Text(
                                  'Relation: ${_selectedVisitorsForDisplay[index].relation}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                                Text(
                                  'Mobile: ${_selectedVisitorsForDisplay[index].mobileNumber}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedVisitorsForDisplay.removeAt(index);
                                if (index < _additionalVisitorControllers.length) {
                                  _additionalVisitorControllers[index].dispose();
                                  _additionalVisitorControllers.removeAt(index);
                                }
                              });
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),

            SizedBox(height: 30),

            // Schedule Visit Button
            SizedBox(
              width: double.infinity,
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
            SizedBox(height: 20), // Extra padding at bottom
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
            : (_showingVisitCards ? Colors.white : Colors.white),
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
                  // In your Meeting navbar onTap:
                  _buildNavItem(
                    index: 1,
                    icon: Icons.directions_walk,
                    label: 'Meeting',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeetFormScreen(
                            selectedIndex: 1,
                            showVisitCards: true,
                            fromNavbar: true, // Make sure this is set
                          ),
                        ),
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
                          builder: (context) => ParoleScreen(selectedIndex: 2),
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


