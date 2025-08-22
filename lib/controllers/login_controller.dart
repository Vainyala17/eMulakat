// lib/controllers/login_controller.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  // Get auth controller instance
  final AuthController _authController = Get.find<AuthController>();

  // Form controllers
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final captchaController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  // Observable variables
  var isLoading = false.obs;
  var isInternationalVisitor = false.obs;
  var captchaText = ''.obs;

  // OTP related observables
  var isOtpSent = false.obs;
  var isOtpVerified = false.obs;
  var generatedOtp = ''.obs;
  var resendCounter = 0.obs;
  var canResend = true.obs;
  var secondsRemaining = 30.obs;

  // Constants
  final String dummyOtp = "123456";
  final List<String> specialCaseNumbers = ['7702000725', '9999999999'];
  final List<String> categories = [
    'SELECT',
    'III Treated by the prison authorities',
    'Basic Facilities not provided inside prison',
    'Manhandling by co prisoners',
    'Others'
  ];

  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();
    generateCaptcha();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    emailController.dispose();
    mobileController.dispose();
    otpController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    super.onClose();
  }

  // Generate captcha
  void generateCaptcha() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    captchaText.value = List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Toggle international visitor
  void toggleInternationalVisitor(bool value) {
    isInternationalVisitor.value = value;
    emailController.clear();
    mobileController.clear();
    otpController.clear();
    resetOtpState();
  }

  // Reset OTP state
  void resetOtpState() {
    isOtpSent.value = false;
    isOtpVerified.value = false;
    resendCounter.value = 0;
    canResend.value = true;
    _resendTimer?.cancel();
  }

  // Check if it's a special case
  bool isSpecialCase(String input) {
    return !isInternationalVisitor.value && specialCaseNumbers.contains(input);
  }

  // Check if OTP can be sent
  bool canSendOtp() {
    if (isInternationalVisitor.value) {
      return emailController.text.isNotEmpty &&
          GetUtils.isEmail(emailController.text) &&
          !isOtpVerified.value;
    } else {
      return mobileController.text.length == 10 && !isOtpVerified.value;
    }
  }

  // Start resend timer
  void startResendTimer() {
    secondsRemaining.value = 30;
    canResend.value = false;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
        canResend.value = true;
      }
    });
  }

  // Send OTP
  void sendOtp() {
    bool isValid = false;
    String recipient = '';

    if (isInternationalVisitor.value) {
      if (emailController.text.isNotEmpty && GetUtils.isEmail(emailController.text)) {
        isValid = true;
        recipient = emailController.text;
      }
    } else {
      if (mobileController.text.length == 10) {
        isValid = true;
        recipient = mobileController.text;
      }
    }

    if (isValid) {
      generatedOtp.value = dummyOtp;
      isOtpSent.value = true;
      resendCounter.value = 0;

      Get.snackbar(
        'OTP Sent',
        'OTP sent to $recipient',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      startResendTimer();
    } else {
      Get.snackbar(
        'Error',
        'Please enter a valid ${isInternationalVisitor.value ? "email" : "mobile number"}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Verify OTP
  void verifyOtp() {
    if (otpController.text == generatedOtp.value) {
      isOtpVerified.value = true;
      Get.snackbar(
        'Success',
        'OTP verified successfully!',
        backgroundColor: const Color(0xFF7AA9D4),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Invalid OTP. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Resend OTP
  void resendOtp() {
    if (canResend.value && resendCounter.value < 3) {
      resendCounter.value++;
      generatedOtp.value = dummyOtp;
      otpController.clear();

      String recipient = isInternationalVisitor.value
          ? emailController.text
          : mobileController.text;

      Get.snackbar(
        'OTP Resent',
        'OTP resent to $recipient',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      startResendTimer();
    }
  }

  // Login method
  Future<void> login() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate captcha
    if (captchaController.text.toUpperCase() != captchaText.value) {
      Get.snackbar(
        'Error',
        'Invalid captcha. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      generateCaptcha();
      captchaController.clear();
      return;
    }

    String userInput = isInternationalVisitor.value
        ? emailController.text.trim()
        : mobileController.text.trim();

    bool isSpecial = isSpecialCase(userInput);

    // For non-special cases, check OTP verification
    if (!isSpecial && !isOtpVerified.value) {
      Get.snackbar(
        'Error',
        isInternationalVisitor.value
            ? 'Please verify your email first'
            : 'Please verify your mobile number first',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      bool loginSuccess = await _authController.login(
          userInput,
          passwordController.text,
          isSpecial
      );

      if (loginSuccess) {
        // Navigate to home screen
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}