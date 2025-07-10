import 'package:e_mulakat/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:math';
import '../../pdf_viewer_screen.dart';
import 'meet_form_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';

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

  String? _selectedGender;
  String? _selectedRelation;
  String? _selectedIdProof;
  bool _isInternationalVisitor = false;

  // Separate variables for different images
  File? _passportImage;  // For passport photo
  File? _idProofImage;   // For ID proof image

  // OTP related variables
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  String? _generatedOtp;
  int _resendCounter = 0;
  bool _canResend = true;

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
    Random random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  // Send OTP function
  void _sendOtp() {
    if (_mobileController.text.length == 10) {
      setState(() {
        _generatedOtp = _generateOtp();
        _isOtpSent = true;
        _canResend = false;
      });

      // Show OTP in console for testing (remove in production)
      print('Generated OTP: $_generatedOtp');

      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to ${_mobileController.text}'),
          backgroundColor: Colors.green,
        ),
      );

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

  // Verify OTP function
  void _verifyOtp() {
    if (_otpController.text == _generatedOtp) {
      setState(() {
        _isOtpVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Please try again.'),
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

      print('Resent OTP: $_generatedOtp');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP resent to ${_mobileController.text}'),
          backgroundColor: Colors.blue,
        ),
      );

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
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        if (imageType == 'passport') {
          _passportImage = File(image.path);
        } else if (imageType == 'idproof') {
          _idProofImage = File(image.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Visitor Registration'),
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormSectionTitle(title: 'Visitor Details'),
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
                label: 'Visitor Name*',
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
                label: 'Father/Husband Name*',
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
                label: 'Address*',
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
                    'Gender*',
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
                label: 'Age*',
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
                  label: 'ID Number*',
                  hint: 'Enter ${_selectedIdProof} Number',
                  keyboardType: _selectedIdProof == 'Pan Card' ? TextInputType.text : TextInputType.number,
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
                title: Text('International Visitor'),
                value: _isInternationalVisitor,
                onChanged: (value) {
                  setState(() {
                    _isInternationalVisitor = value ?? false;
                    if (_isInternationalVisitor) {
                      _mobileController.clear();
                      _isOtpSent = false;
                      _isOtpVerified = false;
                      _otpController.clear();
                    } else {
                      _emailController.clear();
                    }
                  });
                },
              ),

              // Email (for international visitors or optional for others)
              if (_isInternationalVisitor || !_isInternationalVisitor)
                CustomTextField(
                  controller: _emailController,
                  label: _isInternationalVisitor ? 'Email ID*' : 'Email ID',
                  hint: 'Enter Your Email Id',
                  keyboardType: TextInputType.emailAddress,
                  validator: _isInternationalVisitor ? Validators.validateEmail : null,
                ),
              SizedBox(height: 16),

              // Mobile Number (for non-international visitors)
              if (!_isInternationalVisitor) ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _mobileController,
                        label: 'Mobile No*',
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
                    if (_mobileController.text.length == 10 && !_isOtpVerified)
                      ElevatedButton(
                        onPressed: _isOtpSent ? null : _sendOtp,
                        child: Text(_isOtpSent ? 'Sent' : 'Get OTP'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isOtpSent ? Colors.black : Colors.blue,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),

                // OTP Verification Section
                if (_isOtpSent && !_isOtpVerified) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _otpController,
                          label: 'Enter OTP*',
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
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: _otpController.text.length == 6 ? _verifyOtp : null,
                            child: Text('Verify'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          SizedBox(height: 5),
                          TextButton(
                            onPressed: _canResend && _resendCounter < 3 ? _resendOtp : null,
                            child: Text(
                              _canResend ? 'Resend' : 'Wait...',
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
                      'Resend attempts: $_resendCounter/3',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],

                // OTP Verified Message
                if (_isOtpVerified) ...[
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.black),
                        SizedBox(width: 10),
                        Text(
                          'Mobile number verified successfully!',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ],
              SizedBox(height: 10),
              CustomTextField(
                controller: _passwordController,
                label: 'Password*',
                hint: 'Enter a secure password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password*',
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
                text: 'Save',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Check OTP verification for non-international visitors
                    if (!_isInternationalVisitor && !_isOtpVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please verify your mobile number with OTP'),
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
        ),
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