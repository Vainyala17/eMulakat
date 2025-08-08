// import 'dart:async';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:math';
// import '../../policies/contact_us_popup.dart';
// import '../../policies/privacy_policy_screen.dart';
// import '../../policies/terms_of_use_screen.dart';
// import 'login_screen.dart';
// import '../../widgets/custom_textfield.dart';
// import '../../widgets/custom_button.dart';
// import '../../utils/validators.dart';
//
// class ForgotPasswordScreen extends StatefulWidget {
//   final bool isInternationalVisitor;
//
//   const ForgotPasswordScreen({
//     Key? key,
//     this.isInternationalVisitor = false,
//   }) : super(key: key);
//
//   @override
//   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// }
//
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   int _selectedIndex = 0;
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _mobileController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _captchaController = TextEditingController();
//
//   String _captchaText = '';
//   bool _isLoading = false;
//   int _secondsRemaining = 30;
//
//   // Dummy OTP for testing
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
//   // Reset Password function
//   void _resetPassword() async {
//     if (_newPasswordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please enter new password'.tr()), backgroundColor: Colors.red),
//       );
//       return;
//     }
//
//     if (_newPasswordController.text.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Password must be at least 6 characters'.tr()), backgroundColor: Colors.red),
//       );
//       return;
//     }
//
//     if (_newPasswordController.text != _confirmPasswordController.text) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Passwords do not match'.tr()), backgroundColor: Colors.red),
//       );
//       return;
//     }
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     await Future.delayed(Duration(seconds: 2));
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Password reset successfully!'.tr()),
//         backgroundColor: Colors.green,
//       ),
//     );
//
//     // Navigate back to login
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//     );
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
//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     final isSelected = _selectedIndex == index;
//
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _selectedIndex = index;
//           });
//           onTap();
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 8),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 size: 20,
//                 color: Colors.white,
//               ),
//               SizedBox(height: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
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
//         title: Text('Forgot Password'.tr()),
//         centerTitle: true,
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.black,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 40),
//                 _buildLogo(),
//                 SizedBox(height: 40),
//
//                 // Instruction Text
//                 Text(
//                   widget.isInternationalVisitor
//                       ? 'Reset password using Email ID'.tr()
//                       : 'Reset password using Mobile Number'.tr(),
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//
//                 SizedBox(height: 16),
//                 Text(
//                   'Enter your ${widget.isInternationalVisitor ? 'email address'.tr() : 'mobile number'} and we\'ll send you a link to reset your password.'.tr(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//                 ),
//
//                 SizedBox(height: 32),
//
//                 // Email or Mobile Field
//                 if (widget.isInternationalVisitor)
//                   CustomTextField(
//                     label: 'Email ID*'.tr(),
//                     hint: 'Enter your email',
//                     controller: _emailController,
//                     validator: Validators.validateEmail,
//                     keyboardType: TextInputType.emailAddress,
//                   )
//                 else
//                   CustomTextField(
//                     label: 'Mobile No*'.tr(),
//                     hint: 'Enter your mobile number',
//                     controller: _mobileController,
//                     keyboardType: TextInputType.phone,
//                     validator: Validators.validateMobile,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(10),
//                     ],
//                   ),
//
//                 SizedBox(height: 35),
//
//                 // Captcha Row
//                 Row(
//                   children: [
//                     // Captcha Text Box
//                     Container(
//                       width: 100,
//                       height: 50,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                         borderRadius: BorderRadius.circular(4),
//                         color: Colors.grey[100],
//                       ),
//                       child: Text(
//                         _captchaText,
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 3,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width:15),
//
//                     // Refresh Button
//                     IconButton(
//                       icon: Icon(Icons.refresh),
//                       onPressed: _generateCaptcha,
//                     ),
//                     SizedBox(width: 12),
//
//                     // Captcha Input Field
//                     Expanded(
//                       child: TextFormField(
//                         controller: _captchaController,
//                         decoration: InputDecoration(
//                           hintText: 'Enter captcha',
//                           border: OutlineInputBorder(),
//                           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                         ),
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
//
//                 SizedBox(height: 24),
//
//                 // Reset Button
//                 CustomButton(
//                   text: 'Send Reset Link',
//                   onPressed: _resetPassword,
//                   isLoading: _isLoading,
//                   width: double.infinity,
//                 ),
//
//                 SizedBox(height: 16),
//
//                 // Back to Login
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginScreen()),
//                     );
//                   },
//                   child: Text('Back to Login'.tr()),
//                 ),
//               ],
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
//                 _buildNavItem(
//                   index: 0,
//                   icon: Icons.info_outline,
//                   label: 'About Us'.tr(),
//                   onTap: () {
//                     ContactUsPopup.show(context);
//                   },
//                 ),
//                 _buildNavItem(
//                   index: 1,
//                   icon: Icons.shield_outlined,
//                   label: 'Privacy Policy'.tr(),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
//                     );
//                   },
//                 ),
//                 _buildNavItem(
//                   index: 2,
//                   icon: Icons.support_agent_outlined,
//                   label: 'Contact Us'.tr(),
//                   onTap: () {
//                     ContactUsPopup.show(context);
//                   },
//                 ),
//                 _buildNavItem(
//                   index: 3,
//                   icon: Icons.article_outlined,
//                   label: 'Terms of Use'.tr(),
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
// }