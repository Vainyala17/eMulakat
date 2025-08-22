// lib/bindings/auth_binding.dart
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/grievance_controller.dart';
import '../controllers/login_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}


class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<LoginController>(() => LoginController());
  }
}


class GrievanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<GrievanceController>(() => GrievanceController());
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Put AuthController immediately as it's used across the app
    Get.put<AuthController>(AuthController());
  }
}