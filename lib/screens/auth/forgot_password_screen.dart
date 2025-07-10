import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../policies/contact_us_popup.dart';
import '../../policies/privacy_policy_screen.dart';
import '../../policies/terms_of_use_screen.dart';
import 'login_screen.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool isInternationalVisitor;

  const ForgotPasswordScreen({
    Key? key,
    this.isInternationalVisitor = false,
  }) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _captchaController = TextEditingController();

  String _captchaText = '';
  bool _isLoading = false;

  // OTP related variables
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  String? _generatedOtp;
  int _resendCounter = 0;
  bool _canResend = true;

  // Step tracking
  int _currentStep = 1; // 1: Send OTP, 2: Verify OTP, 3: Reset Password

  // Dummy OTP for testing
  final String _dummyOtp = "123456";

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    _captchaText = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
    setState(() {});
  }

  // Generate random OTP (but we'll use dummy OTP for testing)
  String _generateOtp() {
    return _dummyOtp;
  }

  // Send OTP function
  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_captchaController.text.toUpperCase() != _captchaText) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid captcha'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _generatedOtp = _generateOtp();
      _isOtpSent = true;
      _canResend = false;
      _currentStep = 2;
      _isLoading = false;
    });

    // Show OTP in console for testing
    print('Generated OTP: $_generatedOtp');

    String recipient = widget.isInternationalVisitor ? _emailController.text : _mobileController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to $recipient'),
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

  // Verify OTP function
  void _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter OTP'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP must be 6 digits'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    if (_otpController.text == _generatedOtp) {
      setState(() {
        _isOtpVerified = true;
        _currentStep = 3;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Resend OTP function
  void _resendOtp() async {
    if (_canResend && _resendCounter < 3) {
      setState(() {
        _resendCounter++;
        _generatedOtp = _generateOtp();
        _canResend = false;
        _otpController.clear();
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });

      print('Resent OTP: $_generatedOtp');

      String recipient = widget.isInternationalVisitor ? _emailController.text : _mobileController.text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP resent to $recipient'),
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

  // Reset Password function
  void _resetPassword() async {
    if (_newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter new password'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 6 characters'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back to login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Forgot Password'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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

                // Instruction Text
                Text(
                  widget.isInternationalVisitor
                      ? 'Reset password using Email ID'
                      : 'Reset password using Mobile Number',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                SizedBox(height: 16),
                Text(
                  'Enter your ${widget.isInternationalVisitor ? 'email address' : 'mobile number'} and we\'ll send you a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                SizedBox(height: 32),

                // Email or Mobile Field
                if (widget.isInternationalVisitor)
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    isRequired: true,
                    controller: _emailController,
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  )
                else
                  CustomTextField(
                    label: 'Mobile No',
                    hint: 'Enter your mobile number',
                    isRequired: true,
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    validator: Validators.validateMobile,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),

                SizedBox(height: 16),

                // Captcha Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
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
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: _generateCaptcha,
                      icon: Icon(Icons.refresh),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
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

                // Reset Button
                CustomButton(
                  text: 'Send Reset Link',
                  onPressed: _resetPassword,
                  isLoading: _isLoading,
                  width: double.infinity,
                ),

                SizedBox(height: 16),

                // Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Back to Login'),
                ),
              ],
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
                    ContactUsPopup.show(context);
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
}