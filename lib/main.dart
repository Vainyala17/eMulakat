// main.dart
import 'package:eMulakat/services/hive_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/bindings.dart';
import 'routes/app_pages.dart';
import 'utils/color_scheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    // Only initialize critical services in main()
    await HiveService.initHive();
    print('✅ App initialized successfully');
  } catch (e) {
    print('❌ Critical error during app initialization: $e');
    // Handle critical errors appropriately
  }

  runApp(eMulakatApp());
}

class eMulakatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'eMulakat',
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        colorScheme: AppColors.colorScheme,
      ),
      debugShowCheckedModeBanner: false,

      // GetX Configuration
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),

      // Localization (if using easy_localization)
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Navigation observers for debugging (optional)
      // navigatorObservers: [GetObserver()],
    );
  }
}