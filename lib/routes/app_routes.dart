// lib/routes/app_routes.dart
import 'package:get/get.dart';
import '../bindings/bindings.dart';
import '../dashboard/grievance/grievance_details_screen.dart';
import '../screens/splash/splash_logo.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String grievance = '/grievance';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => SplashLogoScreen(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: grievance,
      page: () => GrievanceDetailsScreen(),
      binding: GrievanceBinding(),
    ),
  ];
}