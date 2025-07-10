import 'package:e_mulakat/dashboard/grievance/grievance_details_screen.dart';
import 'package:e_mulakat/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'dart:math';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../../utils/validators.dart';
import '../visit/visit_home.dart';
import 'grievance_home.dart';

class ComplaintScreen extends StatefulWidget {
  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  int _selectedIndex = 0;
  late WebViewController controller;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _selectedRelation;
  bool _isInternationalVisitor = false;

  // OTP related variables
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  String? _generatedOtp;
  int _resendCounter = 0;
  bool _canResend = true;

  final List<String> _relations = ['Father', 'Mother', 'Spouse', 'Brother', 'Sister', 'Son', 'Daughter', 'Friend', 'Other'];

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
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final _ = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.white,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Complainant Details'),
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
              FormSectionTitle(title: 'Complainant Details'),
              SizedBox(height: 20),
              // Visitor Name
              CustomTextField(
                controller: _nameController,
                label: 'Name*',
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
              // Save Button
              CustomButton(
                text: 'Save & Next',
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
                      MaterialPageRoute(builder: (context) => GrievanceDetailsScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF5A8BBA),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.directions_walk,
                  label: 'Visit',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VisitHomeScreen()),
                    );
                  },
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.report_problem,
                  label: 'Grievance',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GrievanceHomeScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}