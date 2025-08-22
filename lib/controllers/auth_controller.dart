// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  // Observable variables
  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var userToken = ''.obs;
  var userName = ''.obs;
  var userMobile = ''.obs;
  var isSpecialUser = false.obs;
  final isAuthenticated = false.obs;
  final isAuthChecking = true.obs;
  final userData = Rxn<Map<String, dynamic>>();
  final specialUserNumber = ''.obs;

  // Constants
  static const String SPECIAL_USER_NUMBER = "7702000723";

  @override
  void onInit() {
    super.onInit();
    checkExistingSession();
    checkAuthenticationStatus();
  }

  Future<void> checkAuthenticationStatus() async {
    try {
      isAuthChecking.value = true;

      // Check if user is the special user
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? specialUser = prefs.getString('special_user');

      if (specialUser == SPECIAL_USER_NUMBER) {
        // Special user authentication
        isSpecialUser.value = true;
        isAuthenticated.value = true;
        specialUserNumber.value = specialUser;
        isAuthChecking.value = false;
        return;
      }

      // Regular JWT token validation
      bool tokenValid = await AuthService.isTokenValid();

      if (tokenValid) {
        String? token = await AuthService.getToken();
        Map<String, dynamic>? user = await AuthService.getUserFromToken();

        userToken.value = token ?? '';
        userData.value = user;
        isAuthenticated.value = true;
      } else {
        await clearAuthData();
        isAuthenticated.value = false;
      }

    } catch (e) {
      print('❌ Auth check error: $e');
      await clearAuthData();
      isAuthenticated.value = false;
    } finally {
      isAuthChecking.value = false;
    }
  }

  // Check if user is already logged in
  Future<void> checkExistingSession() async {
    try {
      isLoading.value = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isSpecial = prefs.getBool('is_special_user') ?? false;

      if (isSpecial) {
        // Handle special user
        String? specialUser = prefs.getString('special_user');
        if (specialUser != null) {
          isLoggedIn.value = true;
          isSpecialUser.value = true;
          userMobile.value = specialUser;
          userName.value = specialUser;
        }
      } else {
        // Check regular token
        bool isValid = await AuthService.isTokenValid();
        if (isValid) {
          isLoggedIn.value = true;
          userToken.value = prefs.getString('auth_token') ?? '';
        }
      }
    } catch (e) {
      print('Error checking session: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Login method
  Future<bool> login(String userInput, String password, bool isSpecialCase) async {
    try {
      isLoading.value = true;

      if (isSpecialCase) {
        // Handle special case login
        await AuthService.clearTokens();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('special_user', userInput);
        await prefs.setBool('is_special_user', true);

        isLoggedIn.value = true;
        isSpecialUser.value = true;
        userMobile.value = userInput;
        userName.value = userInput;

        Get.snackbar(
          'Success',
          'Login successful!',
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );

        return true;
      } else {
        // Regular API login
        var result = await AuthService.loginUser(userInput, password);

        if (result['success'] == true) {
          isLoggedIn.value = true;
          isSpecialUser.value = false;
          userToken.value = result['token'] ?? '';
          userName.value = userInput;

          Get.snackbar(
            'Success',
            'Login successful!',
            backgroundColor: Get.theme.colorScheme.primary,
            colorText: Get.theme.colorScheme.onPrimary,
          );

          return true;
        } else {
          Get.snackbar(
            'Error',
            result['message'] ?? 'Login failed',
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
          return false;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await AuthService.clearTokens();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('special_user');
      await prefs.remove('is_special_user');

      // Reset all values
      isLoggedIn.value = false;
      isSpecialUser.value = false;
      userToken.value = '';
      userName.value = '';
      userMobile.value = '';

      Get.offAllNamed('/login');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => isLoggedIn.value;
}