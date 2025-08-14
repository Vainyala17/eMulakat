import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import '../home/home_screen.dart';
import '../../pdf_viewer_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';


class VisitorFormScreen extends StatefulWidget {
  final VoidCallback? onProfileCompleted;

  const VisitorFormScreen({Key? key, this.onProfileCompleted}) : super(key: key);

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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _selectedGender;
  String? _selectedIdProof;
  List<num> laplacianKernel = [
    0,  1,  0,
    1, -4,  1,
    0,  1,  0,
  ];
  File? _passportImage;  // For passport photo
  File? _idProofImage;   // For ID proof image
  final List<String> _genders = ['Male', 'Female', 'Transgender'];
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

                  // Call the callback to mark profile as completed
                  if (widget.onProfileCompleted != null) {
                    widget.onProfileCompleted!();
                  }

                  // Navigate back to HomeScreen or pop back to previous screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                        (route) => false, // Remove all previous routes
                  );
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white, // Changed to white for better contrast
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        title: Text('Create Profile'.tr()),
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
          return Form( // Wrap with Form widget
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormSectionTitle(title: 'Personal Details'.tr()),
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
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _genders.map((gender) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: gender,
                                groupValue: _selectedGender,
                                visualDensity: VisualDensity(horizontal: -4, vertical: -4), // compact look
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,    // reduces touch area
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                },
                              ),
                              Text(
                                gender,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: 25), // minimal spacing between options
                            ],
                          );
                        }).toList(),
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
                  
                  // Password Field
                  CustomTextField(
                    label: 'Password*'.tr(),
                    hint: 'Enter your password',
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
          );
        },
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}