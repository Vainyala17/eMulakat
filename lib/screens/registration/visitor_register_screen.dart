import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:math';
import '../../pdf_viewer_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../auth/login_screen.dart';

class VisitorFormScreen extends StatefulWidget {
  @override
  _VisitorFormScreenState createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  late WebViewController controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final String _dummyOtp = "123456";
  String? _selectedGender;
  String? _selectedRelation;
  String? _selectedIdProof;
  bool _isInternationalVisitor = false;
  List<num> laplacianKernel = [
    0,  1,  0,
    1, -4,  1,
    0,  1,  0,
  ];


  // Separate variables for different images
  File? _passportImage;  // For passport photo
  File? _idProofImage;   // For ID proof image

  // OTP related variables
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  String? _generatedOtp;
  int _resendCounter = 0;
  bool _canResend = true;
  Timer? _resendTimer;
  int _secondsRemaining = 30;

  final List<String> _genders = ['Male', 'Female', 'Transgender'];
  final List<String> _relations = ['Father', 'Mother', 'Spouse', 'Brother', 'Sister', 'Son', 'Daughter', 'Friend', 'Other'];
  final List<String> _idProofs = ['Aadhar Card', 'Pan Card', 'Driving License', 'Passport', 'Voter ID', 'Others', 'Not Available'];

  final Map<String, int> _idLimits = {
    'Aadhar Card': 12,
    'Pan Card': 10,
    'Driving License': 16,
    'Passport': 8,
    'Voter ID': 10,
    'Others': 20,
    'Not Available': 0,
  };

  @override
  void initState() {
    super.initState();
  }

  // Generate random OTP
  String _generateOtp() {
    // Return dummy OTP for testing
    return _dummyOtp;
  }

  void _startResendTimer() {
    _secondsRemaining = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  double computeLaplacianVariance(img.Image image) {
    final grayscale = img.grayscale(image);
    final filtered = img.convolution(
      grayscale,
      filter: laplacianKernel,
      div: 1,
    );

    int width = filtered.width;
    int height = filtered.height;
    int pixelCount = width * height;

    double sum = 0;
    double sumSquared = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = filtered.getPixel(x, y);
        final luminance = img.getLuminance(pixel).toDouble();
        sum += luminance;
        sumSquared += luminance * luminance;
      }
    }

    double mean = sum / pixelCount;
    double variance = (sumSquared / pixelCount) - (mean * mean);
    return variance;
  }

  Future<bool> isImageSharpAndFaceVisible(File file, {double threshold = 100}) async {
    // Decode image
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return false;

    // Sharpness check
    final variance = computeLaplacianVariance(image);
    print('Sharpness (variance): $variance');
    final isSharp = variance > threshold;
    print("Hello");
    if (!isSharp) return false;

    // Face detection
    final inputImage = InputImage.fromFile(file);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableContours: false,
        enableClassification: false,
      ),
    );

    final faces = await faceDetector.processImage(inputImage);
    await faceDetector.close();

    final hasFace = faces.isNotEmpty;
    print('Face detected: $hasFace');

    return hasFace;
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

  // Send OTP function
  void _sendOtp() {
    bool isValid = false;
    String recipient = '';

    if (_isInternationalVisitor) {
      if (_emailController.text.isNotEmpty &&
          Validators.validateEmail(_emailController.text) == null) {
        isValid = true;
        recipient = _emailController.text;
      }
    } else {
      if (_mobileController.text.length == 10) {
        isValid = true;
        recipient = _mobileController.text;
      }
    }

    if (isValid) {
      setState(() {
        _generatedOtp = _generateOtp();
        _isOtpSent = true;
        _canResend = false;
        _resendCounter = 0; // Reset counter on fresh send
      });

      print('Generated OTP: $_generatedOtp'.tr());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP resent to $recipient'.tr(),
            style: TextStyle(color: Colors.black), // <-- Text color
          ),
          backgroundColor: Colors.blue, // <-- Background color
        ),
      );

      _startResendTimer(); // ✅ Start countdown
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid ${_isInternationalVisitor ? "email" : "mobile number"}'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Verify OTP function
  void _verifyOtp() {
    if (_otpController.text == _generatedOtp) {
      setState(() {
        _isOtpVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP verified successfully!'.tr(),
            style: TextStyle(color: Colors.black), // <-- Text color
          ),
          backgroundColor: Color(0xFF7AA9D4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Please try again.'.tr()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Resend OTP function
  void _resendOtp() {
    if (_canResend && _resendCounter < 3) {
      setState(() {
        _resendCounter++;
        _generatedOtp = _generateOtp();
        _canResend = false;
        _otpController.clear();
      });

      print('Resent OTP: $_generatedOtp'.tr());

      String recipient = _isInternationalVisitor ? _emailController.text : _mobileController.text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP resent to $recipient'.tr(),
            style: TextStyle(color: Colors.black), // <-- Text color
          ),
          backgroundColor: Colors.blue, // <-- Background color
        ),
      );
      _startResendTimer();

      // Enable resend after 30 seconds
      Future.delayed(Duration(seconds: 30), () {
        if (mounted) {
          setState(() {
            _canResend = true;
          });
        }
      });
    }
  }

  bool _canSendOtp() {
    if (_isInternationalVisitor) {
      return _emailController.text.isNotEmpty &&
          Validators.validateEmail(_emailController.text) == null &&
          !_isOtpVerified;
    } else {
      return _mobileController.text.length == 10 && !_isOtpVerified;
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
      maxWidth: 1024, // Resize large images
      maxHeight: 1024,
      imageQuality: 85, // Reduce image size
    );

    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No image selected'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileSize = await file.length();

      if (fileSize > 10000 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected image exceeds 1000KB limit'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }


      if (imageType == 'passport') {
        final isValid = await isImageSharpAndFaceVisible(file);
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

        final isMatch = await isIdNumberInDocument(file, _idNumberController.text);
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Visitor Registration'.tr()),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormSectionTitle(title: 'Visitor Details'.tr()),
                SizedBox(height: 20),

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

                // Visitor Name
                CustomTextField(
                  controller: _nameController,
                  label: 'Visitor Name*'.tr(),
                  hint: 'Enter your Name',
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

                // Father/Husband Name
                CustomTextField(
                  controller: _fatherNameController,
                  label: 'Father/Husband Name*'.tr(),
                  hint: 'Enter Father/Husband Name',
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

                // Address
                CustomTextField(
                  controller: _addressController,
                  label: 'Address*'.tr(),
                  hint: 'Enter Your Address',
                  validator: Validators.validateAddress,
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

                // Gender
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender*'.tr(),
                      style: TextStyle(fontSize: 16,),
                    ),
                    ..._genders.map((gender) {
                      return RadioListTile<String>(
                        title: Text(gender),
                        value: gender,
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                    if (_selectedGender == null)
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

                // Age
                CustomTextField(
                  controller: _ageController,
                  label: 'Age*'.tr(),
                  hint: 'Enter Your Age',
                  keyboardType: TextInputType.number,
                  validator: Validators.validateAge,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                ),
                SizedBox(height: 16),

                // Relation
                DropdownButtonFormField<String>(
                  value: _selectedRelation,
                  decoration: InputDecoration(
                    labelText: 'Select Relation',
                    border: OutlineInputBorder(),
                  ),
                  items: _relations.map((relation) {
                    return DropdownMenuItem(
                      value: relation,
                      child: Text(relation),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRelation = value;
                    });
                  },
                  validator: (value) => value == null ? 'Please select relation' : null,
                ),
                SizedBox(height: 16),

                // ID Proof
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
                    label: 'ID Number*'.tr(),
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
                SizedBox(height: 16),

                // International Visitor Checkbox
                CheckboxListTile(
                  title: Text('International Visitor'.tr()),
                  value: _isInternationalVisitor,
                  onChanged: (value) {
                    setState(() {
                      _isInternationalVisitor = value ?? false;
                      // Clear all fields when switching
                      _emailController.clear();
                      _mobileController.clear();
                      _otpController.clear();
                      _isOtpSent = false;
                      _isOtpVerified = false;
                      _resendCounter = 0;
                      _canResend = true;
                    });
                  },
                ),

                // Email (for international visitors or optional for others)
                if (_isInternationalVisitor) ...  [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _emailController,
                          label: 'Email ID*'.tr(),
                          hint: 'Enter Your Email ID',
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          onChanged: (value) {
                            setState(() {
                              if (Validators.validateEmail(value) != null) {
                                _isOtpSent = false;
                                _isOtpVerified = false;
                                _otpController.clear();
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      if (_canSendOtp())
                        ElevatedButton(
                          onPressed: _isOtpSent ? null : _sendOtp,
                          child: Text(_isOtpSent ? 'Sent'.tr() : 'Get OTP'.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isOtpSent ? Colors.black : Color(0xFF7AA9D4),
                            foregroundColor: Colors.black,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],

                // Mobile Field (for domestic visitors)
                if (!_isInternationalVisitor) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _mobileController,
                          label: 'Mobile No*'.tr(),
                          hint: 'Enter Your Mobile Number',
                          keyboardType: TextInputType.phone,
                          validator: Validators.validateMobile,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          onChanged: (value) {
                            setState(() {
                              if (value.length != 10) {
                                _isOtpSent = false;
                                _isOtpVerified = false;
                                _otpController.clear();
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      if (_canSendOtp())
                        ElevatedButton(
                          onPressed: _isOtpSent ? null : _sendOtp,
                          child: Text(_isOtpSent ? 'Sent'.tr() : 'Get OTP'.tr()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isOtpSent ? Colors.black : Color(0xFF7AA9D4),
                            foregroundColor: Colors.black,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],

                // OTP Verification Section
                if (_isOtpSent && !_isOtpVerified) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _otpController,
                          label: 'Enter OTP*'.tr(),
                          hint: 'Enter 6-digit OTP',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter OTP';
                            }
                            if (value.length != 6) {
                              return 'OTP must be 6 digits';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            setState(() {}); // Refresh the verify button state
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: _otpController.text.length == 6 ? _verifyOtp : null,
                            child: Text('Verify'.tr()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF7AA9D4),
                              foregroundColor: Colors.black, // <-- Set text/icon color to white
                            ),
                          ),
                          SizedBox(height: 5),
                          TextButton(
                            onPressed: _canResend && _resendCounter < 3 ? _resendOtp : null,
                            child: Text(
                              _canResend
                                  ? 'Resend'.tr()
                                  : 'Wait ${_secondsRemaining}s.tr()',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (_resendCounter > 0)
                    Text(
                      'Resend attempts: $_resendCounter/3'.tr(),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  SizedBox(height: 10),
                ],

                // OTP Verified Message
                if (_isOtpVerified) ...[
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Color(0xFF7AA9D4)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Color(0xFF7AA9D4)),
                        SizedBox(width: 10),
                        Text(
                          _isInternationalVisitor
                              ? 'Email verified successfully!'.tr()
                              : 'Mobile number verified successfully!'.tr(),
                          style: TextStyle(color: Color(0xFF7AA9D4), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],

                SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  label: 'Password'.tr(),
                  hint: 'Enter your password',
                  isRequired: true,
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password*'.tr(),
                  hint: 'Re-enter your password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                // Save Button
                CustomButton(
                  text: 'Save'.tr(),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Check OTP verification for non-international visitors
                      if (!_isInternationalVisitor && !_isOtpVerified) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please verify your mobile number with OTP'.tr()),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _idNumberController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}