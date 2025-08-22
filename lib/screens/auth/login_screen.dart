// lib/screens/auth/login_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';
import '../../policies/about_us_screen.dart';
import '../../policies/contact_us_popup.dart';
import '../../policies/privacy_policy_screen.dart';
import '../../policies/terms_of_use_screen.dart';
import '../home/bottom_nav_bar.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

class LoginScreen extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Color(0xFF5A8BBA),
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  _buildLogo(),
                  SizedBox(height: 20),

                  // International Visitor Checkbox
                  Obx(() =>
                      CheckboxListTile(
                        title: Text('International Visitor'),
                        value: controller.isInternationalVisitor.value,
                        onChanged: (value) =>
                            controller.toggleInternationalVisitor(
                                value ?? false),
                      )),
                  SizedBox(height: 16),

                  // Email Field (for international visitors)
                  Obx(() =>
                  controller.isInternationalVisitor.value
                      ? _buildEmailField()
                      : _buildMobileField()
                  ),

                  // OTP Verification Section
                  Obx(() =>
                  controller.isOtpSent.value && !controller.isOtpVerified.value
                      ? _buildOtpVerification()
                      : SizedBox.shrink()
                  ),

                  // OTP Verified Message
                  Obx(() =>
                  controller.isOtpVerified.value
                      ? _buildOtpVerifiedMessage()
                      : SizedBox.shrink()
                  ),

                  SizedBox(height: 16),

                  // Password Field
                  CustomTextField(
                    label: 'Password*',
                    hint: 'Enter your password',
                    controller: controller.passwordController,
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
                  _buildCaptchaSection(),
                  SizedBox(height: 24),

                  // Login Button
                  Obx(() =>
                      CustomButton(
                        text: 'Login',
                        onPressed: controller.login,
                        isLoading: controller.isLoading.value,
                        width: double.infinity,
                      )),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
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

  Widget _buildEmailField() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.emailController,
                label: 'Email ID*',
                hint: 'Enter Your Email ID',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                onChanged: (value) {
                  if (Validators.validateEmail(value) != null) {
                    controller.resetOtpState();
                  }
                },
              ),
            ),
            SizedBox(width: 10),
            Obx(() =>
            controller.canSendOtp()
                ? ElevatedButton(
              onPressed: controller.isOtpSent.value ? null : controller.sendOtp,
              child: Text(controller.isOtpSent.value ? 'Sent' : 'Get OTP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.isOtpSent.value
                    ? Colors.black
                    : Color(0xFF7AA9D4),
                foregroundColor: Colors.black,
              ),
            )
                : SizedBox.shrink()),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMobileField() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.mobileController,
                label: 'Mobile No*',
                hint: 'Enter Your Mobile Number',
                keyboardType: TextInputType.phone,
                validator: Validators.validateMobile,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (value) {
                  if (value.length != 10) {
                    controller.resetOtpState();
                  }
                },
              ),
            ),
            SizedBox(width: 10),
            Obx(() =>
            controller.canSendOtp()
                ? ElevatedButton(
              onPressed: controller.isOtpSent.value ? null : controller.sendOtp,
              child: Text(controller.isOtpSent.value ? 'Sent' : 'Get OTP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: controller.isOtpSent.value
                    ? Colors.black
                    : Color(0xFF7AA9D4),
                foregroundColor: Colors.black,
              ),
            )
                : SizedBox.shrink()),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOtpVerification() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.otpController,
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
                onChanged: (val) => controller.update(),
              ),
            ),
            SizedBox(width: 10),
            Column(
              children: [
                Obx(() =>
                    ElevatedButton(
                      onPressed: controller.otpController.text.length == 6
                          ? controller.verifyOtp
                          : null,
                      child: Text('Verify'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF7AA9D4),
                        foregroundColor: Colors.black,
                      ),
                    )),
                SizedBox(height: 5),
                Obx(() =>
                    TextButton(
                      onPressed: controller.canResend.value &&
                          controller.resendCounter.value < 3
                          ? controller.resendOtp
                          : null,
                      child: Text(
                        controller.canResend.value
                            ? 'Resend'
                            : 'Wait ${controller.secondsRemaining.value}s',
                        style: TextStyle(fontSize: 12),
                      ),
                    )),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        Obx(() =>
        controller.resendCounter.value > 0
            ? Text(
          'Resend attempts: ${controller.resendCounter.value}/3',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        )
            : SizedBox.shrink()),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildOtpVerifiedMessage() {
    return Column(
      children: [
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
              Expanded(
                child: Text(
                  controller.isInternationalVisitor.value
                      ? 'Email verified successfully!'
                      : 'Mobile number verified successfully!',
                  style: TextStyle(
                      color: Color(0xFF7AA9D4), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCaptchaSection() {
    return Row(
      children: [
        // Captcha Text Box
        Obx(() =>
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
                controller.captchaText.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
            )),
        SizedBox(width: 15),

        // Refresh Button
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: controller.generateCaptcha,
        ),
        SizedBox(width: 12),

        // Captcha Input Field
        Expanded(
          child: TextFormField(
            controller: controller.captchaController,
            decoration: InputDecoration(
              hintText: 'Enter captcha',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
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
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
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
                selectedIndex: 0,
                index: 0,
                icon: Icons.info_outline,
                label: 'About Us',
                onTap: () => Get.to(() => AboutUsScreen()),
              ),
              buildNavItem(
                selectedIndex: 0,
                index: 1,
                icon: Icons.shield_outlined,
                label: 'Privacy Policy',
                onTap: () => Get.to(() => PrivacyPolicyScreen()),
              ),
              buildNavItem(
                selectedIndex: 0,
                index: 2,
                icon: Icons.support_agent_outlined,
                label: 'Contact Us',
                onTap: () => ContactUsPopup.show(context),
              ),
              buildNavItem(
                selectedIndex: 0,
                index: 3,
                icon: Icons.article_outlined,
                label: 'Terms of Use',
                onTap: () => Get.to(() => TermsOfUseScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}