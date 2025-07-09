// import 'package:flutter/material.dart';
// import 'dart:math';
// import '../../policies/contact_us_popup.dart';
// import '../../policies/privacy_policy_screen.dart';
// import '../../policies/terms_of_use_screen.dart';
// import 'login_screen.dart';
// import '../../widgets/custom_textfield.dart';
// import '../../widgets/custom_button.dart';
// import '../../utils/validators.dart';
//
// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _captchaController = TextEditingController();
//
//   String _captchaText = '';
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _generateCaptcha();
//   }
//
//   void _generateCaptcha() {
//     final random = Random();
//     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     _captchaText = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
//     setState(() {});
//   }
//
//   void _register() async {
//     if (_formKey.currentState!.validate()) {
//       if (_captchaController.text.toUpperCase() != _captchaText) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Invalid captcha')),
//         );
//         return;
//       }
//
//       setState(() {
//         _isLoading = true;
//       });
//
//       // Simulate registration process
//       await Future.delayed(Duration(seconds: 2));
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Registration successful! Please login.')),
//       );
//
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Register'),
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 20),
//                 // App Logo
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).primaryColor,
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: Icon(
//                     Icons.security,
//                     size: 40,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 30),
//
//                 // Name Field
//                 CustomTextField(
//                   label: 'Full Name',
//                   hint: 'Enter your full name',
//                   isRequired: true,
//                   controller: _nameController,
//                   validator: Validators.validateName,
//                 ),
//                 SizedBox(height: 16),
//
//                 // Email Field
//                 CustomTextField(
//                   label: 'Email',
//                   hint: 'Enter your email',
//                   isRequired: true,
//                   controller: _emailController,
//                   validator: Validators.validateEmail,
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 SizedBox(height: 16),
//
//                 // Mobile Field
//                 CustomTextField(
//                   label: 'Mobile Number',
//                   hint: 'Enter your mobile number',
//                   isRequired: true,
//                   controller: _mobileController,
//                   validator: Validators.validateMobile,
//                   keyboardType: TextInputType.phone,
//                   maxLength: 10,
//                 ),
//                 SizedBox(height: 16),
//
//                 // Password Field
//                 CustomTextField(
//                   label: 'Password',
//                   hint: 'Enter your password',
//                   isRequired: true,
//                   controller: _passwordController,
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Password is required';
//                     }
//                     if (value.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),
//
//                 // Confirm Password Field
//                 CustomTextField(
//                   label: 'Confirm Password',
//                   hint: 'Confirm your password',
//                   isRequired: true,
//                   controller: _confirmPasswordController,
//                   obscureText: true,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please confirm your password';
//                     }
//                     if (value != _passwordController.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),
//
//                 // Captcha
//                 Row(
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: Container(
//                         height: 50,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Center(
//                           child: Text(
//                             _captchaText,
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 5,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     IconButton(
//                       onPressed: _generateCaptcha,
//                       icon: Icon(Icons.refresh),
//                     ),
//                     SizedBox(width: 8),
//                     Expanded(
//                       flex: 2,
//                       child: CustomTextField(
//                         label: '',
//                         hint: 'Enter captcha',
//                         controller: _captchaController,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Captcha is required';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 24),
//
//                 // Register Button
//                 CustomButton(
//                   text: 'Register',
//                   onPressed: _register,
//                   isLoading: _isLoading,
//                   width: double.infinity,
//                 ),
//                 SizedBox(height: 16),
//
//                 // Login Link
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginScreen()),
//                     );
//                   },
//                   child: Text('Already have an account? Login'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: EdgeInsets.symmetric(vertical: 8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
//                 );
//               },
//               child: Text('Privacy Policy'),
//             ),
//             GestureDetector(
//               onTap: () {
//                 ContactUsPopup.show(context);
//               },
//               child: Text(
//                 'Contact Us',
//                 style: TextStyle(
//                   color: Theme.of(context).primaryColor,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => TermsOfUseScreen()),
//                 );
//               },
//               child: Text('Terms of Use'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }