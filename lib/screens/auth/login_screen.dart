import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../../policies/about_us_screen.dart';
import '../../policies/contact_us_popup.dart';
import '../../policies/privacy_policy_screen.dart';
import '../../policies/terms_of_use_screen.dart';
import '../../services/auth_service.dart';
import '../home/bottom_nav_bar.dart';
import '../home/home_screen.dart';
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
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
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

  // Special case numbers that bypass OTP (for testing)
  final List<String> _specialCaseNumbers = ['7702000725', '9999999999'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingSession();
      _generateCaptcha();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  // Helper method to show error messages
  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper method to show success messages
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Check if user is already logged in
  void _checkExistingSession() async {
    try {
      bool isValid = await AuthService.isTokenValid();
      if (isValid && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      print('Error checking session: $e');
    }
  }

  void _startResendTimer() {
    _secondsRemaining = 30;
    _canResend = false;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
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
      } else {
        timer.cancel();
      }
    });
  }

  void _generateCaptcha() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    _captchaText = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
    setState(() {});
  }

  bool _isSpecialCase(String input) {
    return !_isInternationalVisitor && _specialCaseNumbers.contains(input);
  }

  // In your LoginScreen _login method, replace this:
  void _login() async {
    // Validate form first - SAFE NULL CHECK
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // Validate captcha - SAFE NULL CHECK
    if (_captchaController.text.toUpperCase() != _captchaText) {
      _showErrorMessage('Invalid captcha. Please try again.');
      _generateCaptcha();
      _captchaController.clear();
      return;
    }

    String userInput = _isInternationalVisitor
        ? _emailController.text.trim()
        : _mobileController.text.trim();

    // Check if it's a special case
    bool isSpecialCase = _isSpecialCase(userInput);

    // For non-special cases, check OTP verification
    if (!isSpecialCase && !_isOtpVerified) {
      _showErrorMessage(_isInternationalVisitor
          ? 'Please verify your email first'
          : 'Please verify your mobile number first');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isSpecialCase) {
        // Handle special case - direct navigation without API call
        print('Special case login for: $userInput');

        // Clear any existing tokens
        await AuthService.clearTokens();

        // Save special user identifier
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('special_user', userInput);
        await prefs.setBool('is_special_user', true);

        if (mounted) {
          _showSuccessMessage('Login successful!');

          // Small delay for user feedback
          await Future.delayed(Duration(milliseconds: 500));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }
      } else {
        // Regular API-based login
        print('Regular login attempt for: $userInput');

        var result = await AuthService.loginUser(userInput, _passwordController.text);

        if (mounted) {
          if (result['success'] == true) {
            print('Login successful');
            _showSuccessMessage('Login successful!');

            // Small delay for user feedback
            await Future.delayed(Duration(milliseconds: 500));

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else {
            print('Login failed: ${result['message']}');
            _showErrorMessage(result['message'] ?? 'Login failed. Please try again.');
          }
        }
      }
    } catch (e) {
      print('Login exception: $e');
      if (mounted) {
        _showErrorMessage('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _generateOtp() {
    return _dummyOtp;
  }

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
        _resendCounter = 0;
      });

      print('Generated OTP: $_generatedOtp');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP sent to $recipient',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
      );

      _startResendTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid ${_isInternationalVisitor ? "email" : "mobile number"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _verifyOtp() {
    if (_otpController.text == _generatedOtp) {
      setState(() {
        _isOtpVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP verified successfully!',
            style: TextStyle(color: Colors.white),
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

  void _resendOtp() {
    if (_canResend && _resendCounter < 3) {
      setState(() {
        _resendCounter++;
        _generatedOtp = _generateOtp();
        _otpController.clear();
      });

      print('Resent OTP: $_generatedOtp');

      String recipient = _isInternationalVisitor ? _emailController.text : _mobileController.text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'OTP resent to $recipient',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
      );
      _startResendTimer();
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
        foregroundColor: Colors.black,
        // actions: [
        //   PopupMenuButton<Locale>(
        //     icon: Icon(Icons.language),
        //     onSelected: (Locale locale) {
        //       context.setLocale(locale); // Change app language
        //     },
        //     itemBuilder: (context) => [
        //       PopupMenuItem(value: Locale('en'), child: Text('English')),
        //       PopupMenuItem(value: Locale('hi'), child: Text('हिंदी')),
        //       PopupMenuItem(value: Locale('mr'), child: Text('मराठी')),
        //       PopupMenuItem(value: Locale('ta'), child: Text('தமிழ்')),
        //       PopupMenuItem(value: Locale('te'), child: Text('తెలుగు')),
        //       PopupMenuItem(value: Locale('kn'), child: Text('ಕನ್ನಡ')),
        //       PopupMenuItem(value: Locale('ml'), child: Text('മലയാളം')),
        //       PopupMenuItem(value: Locale('gu'), child: Text('ગુજરાતી')),
        //       PopupMenuItem(value: Locale('bn'), child: Text('বাংলা')),
        //       PopupMenuItem(value: Locale('ur'), child: Text('اردو')),
        //       PopupMenuItem(value: Locale('pa'), child: Text('ਪੰਜਾਬੀ')),
        //     ],
        //   )
        // ],
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
                  SizedBox(height: 20),
                  _buildLogo(),
                  SizedBox(height: 20),
                  CheckboxListTile(
                    title: Text('International Visitor'),
                    value: _isInternationalVisitor,
                    onChanged: (value) {
                      setState(() {
                        _isInternationalVisitor = value ?? false;
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
                            child: Text(_isOtpSent ? 'Sent': 'Get OTP'),
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
                  ],

                  SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password*',
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
                  SizedBox(height: 24),

                  // Captcha
                  Row(
                    children: [
                      // Captcha Text Box
                      Container(
                        width: 100,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey[100],
                        ),
                        child: Text(
                          _captchaText,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      SizedBox(width: 15),

                      // Refresh Button
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: _generateCaptcha,
                      ),
                      SizedBox(width: 12),

                      // Captcha Input Field
                      Expanded(
                        child: TextFormField(
                          controller: _captchaController,
                          decoration: InputDecoration(
                            hintText: 'Enter captcha',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
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
                buildNavItem(
                  selectedIndex: _selectedIndex,
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
                buildNavItem(
                  selectedIndex: _selectedIndex,
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
                buildNavItem(
                  selectedIndex: _selectedIndex,
                  index: 2,
                  icon: Icons.support_agent_outlined,
                  label: 'Contact Us',
                  onTap: () {
                    ContactUsPopup.show(context);
                  },
                ),
                buildNavItem(
                  selectedIndex: _selectedIndex,
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








//
// import 'dart:async';
// //import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:math';
// import '../../policies/about_us_screen.dart';
// import '../../policies/contact_us_popup.dart';
// import '../../policies/privacy_policy_screen.dart';
// import '../../policies/terms_of_use_screen.dart';
// import '../../services/auth_service.dart';
// import '../home/bottom_nav_bar.dart';
// import '../home/home_screen.dart';
// import '../../widgets/custom_textfield.dart';
// import '../../widgets/custom_button.dart';
// import '../../utils/validators.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   int _selectedIndex = 0;
//
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _otpController = TextEditingController();
//   final _captchaController = TextEditingController();
//
//   String _captchaText = '';
//   bool _isLoading = false;
//   bool _isInternationalVisitor = false;
//
//   // OTP related variables
//   bool _isOtpSent = false;
//   bool _isOtpVerified = false;
//   String? _generatedOtp;
//   int _resendCounter = 0;
//   bool _canResend = true;
//   Timer? _resendTimer;
//   int _secondsRemaining = 30;
//
//   // Dummy OTP for testing
//   final String _dummyOtp = "123456";
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // _checkExistingSession();
//       _generateCaptcha();
//     });
//   }
//
//   // Helper method to show error messages
//   void _showErrorMessage(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 3),
//         ),
//       );
//     }
//   }
//
//   void _startResendTimer() {
//     _secondsRemaining = 30;
//     _resendTimer?.cancel();
//     _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       if (_secondsRemaining > 0) {
//         setState(() {
//           _secondsRemaining--;
//         });
//       } else {
//         timer.cancel();
//         setState(() {
//           _canResend = true;
//         });
//       }
//     });
//   }
//
//   void _generateCaptcha() {
//     final random = Random();
//     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     _captchaText = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
//     setState(() {});
//   }
//
//   void _login() async {
//     // Validate form first
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//
//     // Validate captcha
//     if (_captchaController.text.toUpperCase() != _captchaText) {
//       _showErrorMessage('Invalid captcha. Please try again.');
//       _generateCaptcha(); // Generate new captcha
//       return;
//     }
//
//     // Check OTP verification (except for special case)
//     String userInput = _isInternationalVisitor
//         ? _emailController.text.trim()
//         : _mobileController.text.trim();
//
//     // Special case for sir's number - skip OTP verification
//     bool isSpecialCase = !_isInternationalVisitor;
//
//     if (!isSpecialCase && !_isOtpVerified) {
//       _showErrorMessage(_isInternationalVisitor
//           ? 'Please verify your email first'
//           : 'Please verify your mobile number first');
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     // Simulate login process
//     await Future.delayed(Duration(seconds: 2));
//
//     // Set profile status to incomplete for new login
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('profile_completed', false);
//
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => HomeScreen()),
//     );
//   }
//
//   String _generateOtp() {
//     return _dummyOtp;
//   }
//
//   void _sendOtp() {
//     bool isValid = false;
//     String recipient = '';
//
//     if (_isInternationalVisitor) {
//       if (_emailController.text.isNotEmpty &&
//           Validators.validateEmail(_emailController.text) == null) {
//         isValid = true;
//         recipient = _emailController.text;
//       }
//     } else {
//       if (_mobileController.text.length == 10) {
//         isValid = true;
//         recipient = _mobileController.text;
//       }
//     }
//
//     if (isValid) {
//       setState(() {
//         _generatedOtp = _generateOtp();
//         _isOtpSent = true;
//         _canResend = false;
//         _resendCounter = 0; // Reset counter on fresh send
//       });
//
//       print('Generated OTP: $_generatedOtp');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'OTP resent to $recipient',
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Colors.blue,
//         ),
//       );
//
//       _startResendTimer();
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please enter a valid ${_isInternationalVisitor ? "email" : "mobile number"}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   void _verifyOtp() {
//     if (_otpController.text == _generatedOtp) {
//       setState(() {
//         _isOtpVerified = true;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'OTP verified successfully!',
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Color(0xFF7AA9D4),
//         ),
//       );
//     }
//     else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Invalid OTP. Please try again.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
//
//   // Resend OTP function
//   void _resendOtp() {
//     if (_canResend && _resendCounter < 3) {
//       setState(() {
//         _resendCounter++;
//         _generatedOtp = _generateOtp();
//         _canResend = false;
//         _otpController.clear();
//       });
//
//       print('Resent OTP: $_generatedOtp');
//
//       String recipient = _isInternationalVisitor ? _emailController.text : _mobileController.text;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'OTP resent to $recipient',
//             style: TextStyle(color: Colors.black),
//           ),
//           backgroundColor: Colors.blue,
//         ),
//       );
//       _startResendTimer();
//
//       // Enable resend after 30 seconds
//       Future.delayed(Duration(seconds: 30), () {
//         if (mounted) {
//           setState(() {
//             _canResend = true;
//           });
//         }
//       });
//     }
//   }
//
//   // Check if OTP can be sent
//   bool _canSendOtp() {
//     if (_isInternationalVisitor) {
//       return _emailController.text.isNotEmpty &&
//           Validators.validateEmail(_emailController.text) == null &&
//           !_isOtpVerified;
//     } else {
//       return _mobileController.text.length == 10 && !_isOtpVerified;
//     }
//   }
//
//   Widget _buildLogo() {
//     return Container(
//       width: 120,
//       height: 80,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Image.asset(
//           'assets/images/npip_logo.png',
//           fit: BoxFit.contain,
//           errorBuilder: (context, error, stackTrace) {
//             return Container(
//               color: Colors.white,
//               child: Center(
//                 child: Text(
//                   'NPIP',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF5A8BBA),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text('Login'),
//         centerTitle: true,
//         backgroundColor: Color(0xFF5A8BBA),
//         foregroundColor: Colors.black,
//       ),
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   SizedBox(height: 40),
//                   _buildLogo(),
//                   SizedBox(height: 30),
//                   CheckboxListTile(
//                     title: Text('International Visitor'),
//                     value: _isInternationalVisitor,
//                     onChanged: (value) {
//                       setState(() {
//                         _isInternationalVisitor = value ?? false;
//                         _emailController.clear();
//                         _mobileController.clear();
//                         _otpController.clear();
//                         _isOtpSent = false;
//                         _isOtpVerified = false;
//                         _resendCounter = 0;
//                         _canResend = true;
//                       });
//                     },
//                   ),
//                   SizedBox(height: 20),
//
//                   // Email Field (for international visitors)
//                   if (_isInternationalVisitor) ...[
//                     Row(
//                       children: [
//                         Expanded(
//                           child: CustomTextField(
//                             controller: _emailController,
//                             label: 'Email ID*',
//                             hint: 'Enter Your Email ID',
//                             keyboardType: TextInputType.emailAddress,
//                             validator: Validators.validateEmail,
//                             onChanged: (value) {
//                               setState(() {
//                                 if (Validators.validateEmail(value) != null) {
//                                   _isOtpSent = false;
//                                   _isOtpVerified = false;
//                                   _otpController.clear();
//                                 }
//                               });
//                             },
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         if (_canSendOtp())
//                           ElevatedButton(
//                             onPressed: _isOtpSent ? null : _sendOtp,
//                             child: Text(_isOtpSent ? 'Sent' : 'Get OTP'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _isOtpSent ? Colors.black : Color(0xFF7AA9D4),
//                               foregroundColor: Colors.black,
//                             ),
//                           ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                   ],
//
//                   // Mobile Field (for domestic visitors)
//                   if (!_isInternationalVisitor) ...[
//                     Row(
//                       children: [
//                         Expanded(
//                           child: CustomTextField(
//                             controller: _mobileController,
//                             label: 'Mobile No*',
//                             hint: 'Enter Your Mobile Number',
//                             keyboardType: TextInputType.phone,
//                             validator: Validators.validateMobile,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                               LengthLimitingTextInputFormatter(10),
//                             ],
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value.length != 10) {
//                                   _isOtpSent = false;
//                                   _isOtpVerified = false;
//                                   _otpController.clear();
//                                 }
//                               });
//                             },
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         if (_canSendOtp())
//                           ElevatedButton(
//                             onPressed: _isOtpSent ? null : _sendOtp,
//                             child: Text(_isOtpSent ? 'Sent': 'Get OTP'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: _isOtpSent ? Colors.black : Color(0xFF7AA9D4),
//                               foregroundColor: Colors.black,
//                             ),
//                           ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                   ],
//
//                   // OTP Verification Section
//                   if (_isOtpSent && !_isOtpVerified) ...[
//                     Row(
//                       children: [
//                         Expanded(
//                           child: CustomTextField(
//                             controller: _otpController,
//                             label: 'Enter OTP*',
//                             hint: 'Enter 6-digit OTP',
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                               LengthLimitingTextInputFormatter(6),
//                             ],
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter OTP';
//                               }
//                               if (value.length != 6) {
//                                 return 'OTP must be 6 digits';
//                               }
//                               return null;
//                             },
//                             onChanged: (val) {
//                               setState(() {}); // Refresh the verify button state
//                             },
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         Column(
//                           children: [
//                             ElevatedButton(
//                               onPressed: _otpController.text.length == 6 ? _verifyOtp : null,
//                               child: Text('Verify'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Color(0xFF7AA9D4),
//                                 foregroundColor: Colors.black,
//                               ),
//                             ),
//                             SizedBox(height: 5),
//                             TextButton(
//                               onPressed: _canResend && _resendCounter < 3 ? _resendOtp : null,
//                               child: Text(
//                                 _canResend
//                                     ? 'Resend'
//                                     : 'Wait ${_secondsRemaining}s',
//                                 style: TextStyle(fontSize: 12),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     if (_resendCounter > 0)
//                       Text(
//                         'Resend attempts: $_resendCounter/3',
//                         style: TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                     SizedBox(height: 10),
//                   ],
//                   if (_isOtpVerified) ...[
//                     Container(
//                       padding: EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(5),
//                         border: Border.all(color: Color(0xFF7AA9D4)),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.check_circle, color: Color(0xFF7AA9D4)),
//                           SizedBox(width: 10),
//                           Text(
//                             _isInternationalVisitor
//                                 ? 'Email verified successfully!'
//                                 : 'Mobile number verified successfully!',
//                             style: TextStyle(color: Color(0xFF7AA9D4), fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   SizedBox(height: 30),
//                   // Captcha
//                   Row(
//                     children: [
//                       // Captcha Text Box
//                       Container(
//                         width: 100,
//                         height: 50,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(4),
//                           color: Colors.grey[100],
//                         ),
//                         child: Text(
//                           _captchaText,
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 3,
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 15),
//
//                       // Refresh Button
//                       IconButton(
//                         icon: Icon(Icons.refresh),
//                         onPressed: _generateCaptcha,
//                       ),
//                       SizedBox(width: 12),
//
//                       // Captcha Input Field
//                       Expanded(
//                         child: TextFormField(
//                           controller: _captchaController,
//                           decoration: InputDecoration(
//                             hintText: 'Enter captcha',
//                             border: OutlineInputBorder(),
//                             contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Captcha is required';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 30),
//
//                   // Login Button
//                   CustomButton(
//                     text: 'Login',
//                     onPressed: _login,
//                     isLoading: _isLoading,
//                     width: double.infinity,
//                   ),
//                   SizedBox(height:20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Color(0xFF5A8BBA),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: Offset(0, -2),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Container(
//             height: 60,
//             child: Row(
//               children: [
//                 buildNavItem(
//                   selectedIndex :_selectedIndex,
//                   index: 0,
//                   icon: Icons.info_outline,
//                   label: 'About Us',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => AboutUsScreen()),
//                     );
//                   },
//                 ),
//                 buildNavItem(
//                   selectedIndex :_selectedIndex,
//                   index: 1,
//                   icon: Icons.shield_outlined,
//                   label: 'Privacy Policy',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
//                     );
//                   },
//                 ),
//                 buildNavItem(
//                   selectedIndex :_selectedIndex,
//                   index: 2,
//                   icon: Icons.support_agent_outlined,
//                   label: 'Contact Us',
//                   onTap: () {
//                     ContactUsPopup.show(context);
//                   },
//                 ),
//                 buildNavItem(
//                   selectedIndex :_selectedIndex,
//                   index: 3,
//                   icon: Icons.article_outlined,
//                   label: 'Terms of Use',
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => TermsOfUseScreen()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _resendTimer?.cancel();
//     super.dispose();
//   }
// }
