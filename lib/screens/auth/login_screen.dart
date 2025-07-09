import 'package:e_mulakat/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../policies/contact_us_popup.dart';
import '../../policies/privacy_policy_screen.dart';
import '../../policies/terms_of_use_screen.dart';
import '../registration/visitor_form_screen.dart';
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
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();

  String _captchaText = '';
  bool _isLoading = false;

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

  void _login() async {
    if (_formKey.currentState!.validate()) {
      if (_captchaController.text.toUpperCase() != _captchaText) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid captcha')),
        );
        return;
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
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: Colors.white,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
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
      backgroundColor: Colors.white, // Light grey background
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Color(0xFF5A8BBA),
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
                SizedBox(height: 40),                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  isRequired: true,
                  controller: _emailController,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
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
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text('Forgot Password?'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF5A8BBA), // Your specified color
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
            height: 70,
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.shield_outlined, // Better icon for privacy
                  label: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
                    );
                  },
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.support_agent_outlined, // Better icon for contact
                  label: 'Contact Us',
                  onTap: () {
                    ContactUsPopup.show(context);
                  },
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.article_outlined, // Better icon for terms
                  label: 'Terms Of Use',
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