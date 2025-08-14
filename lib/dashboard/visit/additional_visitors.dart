import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';

// Import the AdditionalVisitor model from the main file
// In a real app, this would be in a separate models file
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
  });
}

class AddNewVisitorScreen extends StatefulWidget {
  @override
  _AddNewVisitorScreenState createState() => _AddNewVisitorScreenState();
}

class _AddNewVisitorScreenState extends State<AddNewVisitorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _visitorNameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  String? _selectedRelation;
  String? _selectedIdProof;
  // Separate variables for different images
  File? _passportImage;  // For passport photo
  File? _idProofImage;   // For ID proof image
  List<num> laplacianKernel = [
    0,  1,  0,
    1, -4,  1,
    0,  1,  0,
  ];
  final List<String> _relations = [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Son',
    'Daughter',
    'Husband / Wife',
    'Uncle',
    'Aunt',
    'Cousin',
    'Friend',
    'Lawyer',
    'Others'
  ];
  final Map<String, int> _idLimits = {
    'Aadhar Card': 12,
    'Pan Card': 10,
    'Driving License': 16,
    'Passport': 8,
    'Voter ID': 10,
    'Others': 20,
    'Not Available': 0,
  };
  final List<String> _idProofs = [
    'Aadhar Card',
    'Voter ID',
    'Passport',
    'Driving License',
    'PAN Card',
    'Ration Card'
  ];

  double computeLaplacianVariance(img.Image image) {
    final grayscale = img.grayscale(image);

    // Correct Laplacian kernel as a 3x3 matrix
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

    // Apply Laplacian filter manually
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
      // Decode image
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return false;

      // Sharpness check
      final variance = computeLaplacianVariance(image);
      print('Sharpness (variance): $variance');
      final isSharp = variance > threshold;

      if (!isSharp) return false;

      // Face detection
      final inputImage = InputImage.fromFile(file);
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate, // Changed from fast to accurate
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
  // Pick image function with type parameter
  Future<void> _pickImage(String imageType) async {
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
                  _getImage(ImageSource.camera, imageType);
                },
              ),
              ListTile(
                leading: Icon(Icons.image_search),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery, imageType);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Get image function with type parameter
  Future<void> _getImage(ImageSource source, String imageType) async {
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

    // Fix: Changed from 10000 * 1024 to 1000 * 1024 for 1MB limit
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
      // Show loading indicator during validation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final isValid = await isImageSharpAndFaceVisible(file);
        Navigator.pop(context); // Close loading dialog

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
          _passportImage = file;
        });
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error validating image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (imageType == 'idproof') {
      if (_idNumberController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter ID number before uploading document'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final isMatch = await isIdNumberInDocument(file, _idNumberController.text);
        Navigator.pop(context); // Close loading dialog

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
          _idProofImage = file;
        });
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error validating document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  bool isImageUnderSizeLimit(File imageFile, {int maxKB = 10000}) {
    final bytes = imageFile.lengthSync();
    return bytes <= maxKB * 1024;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add New Visitor'),
        centerTitle: true,
        backgroundColor: const Color(0xFF5A8BBA),
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormSectionTitle(title: 'Visitor Information'),
              SizedBox(height: 20),

              // Visitor Name
              CustomTextField(
                controller: _visitorNameController,
                label: 'Visitor Name*',
                hint: 'Enter visitor name',
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

              // Father Name
              CustomTextField(
                controller: _fatherNameController,
                label: 'Father Name*',
                hint: 'Enter father name',
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

              // Relation Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Relation*',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedRelation,
                    decoration: InputDecoration(
                      hintText: 'Select relation',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    items: _relations.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRelation = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select relation';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Mobile Number
              CustomTextField(
                controller: _mobileController,
                label: 'Mobile Number*',
                hint: 'Enter mobile number',
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mobile number is required';
                  }
                  if (value.length != 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Photo Upload Section
              // Passport Photo Upload
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 100,
                  height: 130,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _passportImage != null
                      ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _passportImage!,
                          width: 100,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 3,
                        right: 3,
                        child: IconButton(
                          icon: Icon(Icons.close, size: 18, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _passportImage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                      : InkWell(
                    onTap: () => _pickImage('passport'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, size: 30, color: Colors.black,),
                        SizedBox(height: 5),
                        Text(
                          'Upload\nPhoto',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: _selectedIdProof,
                decoration: InputDecoration(
                  labelText: 'Select Identity Proof',
                  border: OutlineInputBorder(),
                ),
                items: _idProofs.map((idProof) {
                  return DropdownMenuItem(
                    value: idProof,
                    child: Text(idProof),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIdProof = value;
                    _idNumberController.clear();
                  });
                },
                validator: (value) => value == null ? 'Please select ID proof' : null,
              ),
              SizedBox(height: 16),

              // ID Number
              if (_selectedIdProof != null && _selectedIdProof != 'Not Available')
                CustomTextField(
                  controller: _idNumberController,
                  label: 'ID Number*',
                  hint: 'Enter ${_selectedIdProof} Number',
                  validator: (value) => Validators.validateIdNumber(value, _selectedIdProof!, _idLimits[_selectedIdProof!] ?? 0),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_idLimits[_selectedIdProof!] ?? 0),
                    if (_selectedIdProof == 'Pan Card')
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))
                    else if (_selectedIdProof == 'Passport')
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]'))
                    else
                      FilteringTextInputFormatter.digitsOnly,
                    if (_selectedIdProof == 'Pan Card')
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return TextEditingValue(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        );
                      }),
                  ],
                ),
              SizedBox(height: 16),

              // ID Proof Image Upload
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 500,
                  height: 130,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _idProofImage != null
                      ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _idProofImage!,
                          width: 500,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(Icons.close, size: 18, color: Colors.red),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _idProofImage = null;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                      : InkWell(
                    onTap: () => _pickImage('idproof'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, size: 50, color: Colors.black,),
                        SizedBox(height: 8),
                        Text(
                          'Upload ID Proof Image',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Save Button
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Save Visitor',
                      onPressed: () {
                        _saveVisitor();
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

  void _saveVisitor() {
    if (_formKey.currentState!.validate()) {
      // Check if photo is uploaded
      if (_passportImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload a photo'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if ID proof is uploaded (only if ID proof type is selected)
      if (_selectedIdProof != null && _selectedIdProof != 'Not Available' && _idProofImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload ID proof'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create new visitor object
      AdditionalVisitor newVisitor = AdditionalVisitor(
        visitorName: _visitorNameController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        relation: _selectedRelation!,
        mobileNumber: _mobileController.text.trim(),
        passportImage: _passportImage, // Fixed: use _passportImage instead of _idProofImage
        idProofType: _selectedIdProof,
        idProofNumber: _idNumberController.text.trim(),
        idProofImage: _idProofImage,
      );

      // Show success dialog
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
                  "Visitor added successfully!",
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
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(newVisitor); // Return to previous screen with new visitor
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
  }

  @override
  void dispose() {
    _visitorNameController.dispose();
    _fatherNameController.dispose();
    _mobileController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }
}