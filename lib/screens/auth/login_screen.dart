import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../policies/about_us_screen.dart';
import '../../policies/contact_us_popup.dart';
import '../../policies/privacy_policy_screen.dart';
import '../../policies/terms_of_use_screen.dart';
import '../home/home_screen.dart';
import '../registration/visitor_register_screen.dart';
import 'forgot_password_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _selectedIndex = 0;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  final _captchaController = TextEditingController();

  String _captchaText = '';
  bool _isLoading = false;
  bool _isInternationalVisitor = false;

  // OTP related variables
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  String? _generatedOtp;
  int _resendCounter = 0;
  bool _canResend = true;
  Timer? _resendTimer;
  int _secondsRemaining = 30;

  // Dummy OTP for testing
  final String _dummyOtp = "123456";

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
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

  void _generateCaptcha() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    _captchaText = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
    setState(() {});
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      if (_captchaController.text.toUpperCase() != _captchaText) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid captcha')),
        );
        return;
      }

      // Check if OTP verification is required and completed
      if (_isInternationalVisitor) {
        // For international visitors, email must be verified
        if (!_isOtpVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please verify your email first')),
          );
          return;
        }
      } else {
        // For domestic visitors, mobile must be verified
        if (!_isOtpVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please verify your mobile number first')),
          );
          return;
        }
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate login process
      await Future.delayed(Duration(seconds: 2));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  // Generate random OTP (but we'll use dummy OTP for testing)
  String _generateOtp() {
    // Return dummy OTP for testing
    return _dummyOtp;
  }

  // Send OTP function for both email and mobile
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

      print('Generated OTP: $_generatedOtp');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP resent to $recipient',
            style: TextStyle(color: Colors.black), // <-- Text color
          ),
          backgroundColor: Colors.blue, // <-- Background color
        ),
      );

      _startResendTimer(); // ✅ Start countdown
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid ${_isInternationalVisitor ? "email" : "mobile number"}'),
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
            'OTP verified successfully!',
            style: TextStyle(color: Colors.black), // <-- Text color
          ),
          backgroundColor: Color(0xFF7AA9D4),
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

      String recipient = _isInternationalVisitor ? _emailController.text : _mobileController.text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP resent to $recipient',
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

  // Check if OTP can be sent
  bool _canSendOtp() {
    if (_isInternationalVisitor) {
      return _emailController.text.isNotEmpty &&
          Validators.validateEmail(_emailController.text) == null &&
          !_isOtpVerified;
    } else {
      return _mobileController.text.length == 10 && !_isOtpVerified;
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

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/npip_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.white,
              child: Center(
                child: Text(
                  'NPIP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A8BBA),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Color(0xFF5A8BBA),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  _buildLogo(),
                  SizedBox(height: 40),

                  // International Visitor Checkbox
                  CheckboxListTile(
                    title: Text('International Visitor'),
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
                  SizedBox(height: 16),

                  // Email Field (for international visitors)
                  if (_isInternationalVisitor) ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _emailController,
                            label: 'Email ID*',
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
                            child: Text(_isOtpSent ? 'Sent' : 'Get OTP'),
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
                        if (_canSendOtp())
                          ElevatedButton(
                            onPressed: _isOtpSent ? null : _sendOtp,
                            child: Text(_isOtpSent ? 'Sent' : 'Get OTP'),
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
                              child: Text('Verify'),
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
                                    ? 'Resend'
                                    : 'Wait ${_secondsRemaining}s',
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
                                ? 'Email verified successfully!'
                                : 'Mobile number verified successfully!',
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
                    label: 'Password',
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

                  // Captcha
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            _captchaText,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: _generateCaptcha,
                        icon: Icon(Icons.refresh),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: CustomTextField(
                          label: '',
                          hint: 'Enter captcha',
                          controller: _captchaController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Captcha is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Login Button
                  CustomButton(
                    text: 'Login',
                    onPressed: _login,
                    isLoading: _isLoading,
                    width: double.infinity,
                  ),
                  SizedBox(height: 16),

                  // Register Link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VisitorFormScreen()),
                      );
                    },
                    child: Text('Don\'t have an account? Register'),
                  ),

                  // Forgot Password Link
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen(
                            isInternationalVisitor: _isInternationalVisitor,
                          ),
                        ),
                      );
                    },
                    child: Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
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
                  icon: Icons.info_outline,
                  label: 'About Us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUsScreen()),
                    );
                  },
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.shield_outlined,
                  label: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                    );
                  },
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.support_agent_outlined,
                  label: 'Contact Us',
                  onTap: () {
                    ContactUsPopup.show(context);
                  },
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.article_outlined,
                  label: 'Terms of Use',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TermsOfUseScreen()),
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
    _resendTimer?.cancel();
    super.dispose();
  }

}