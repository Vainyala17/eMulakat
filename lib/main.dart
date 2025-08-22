import 'package:eMulakat/services/api_service.dart';
import 'package:eMulakat/services/hive_service.dart';
import 'package:eMulakat/services/device_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'screens/splash/splash_logo.dart';
import 'utils/color_scheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  try {
    // Initialize critical services
    await HiveService.initHive();
    print('✅ Hive initialized successfully');

    // 🔥 NEW: Store device information immediately when app starts
    await _storeDeviceInformation();

    // Initialize device info and bootstrap (optional - can be done later)
    await _initializeDeviceAndBootstrap();

    print('✅ App initialized successfully');
  } catch (e) {
    print('❌ Critical error during app initialization: $e');
    // Handle critical errors appropriately
  }

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
        Locale('ta'),
        Locale('te'),
        Locale('kn'),
        Locale('ml'),
        Locale('gu'),
        Locale('bn'),
        Locale('ur'),
      ],
      path: 'assets/lang',
      fallbackLocale: Locale('en'),
      child: eMulakatApp(),
    ),
  );
}

/// 🔥 NEW: Store device information with console logging
Future<void> _storeDeviceInformation() async {
  try {
    print('🔄 Storing device information...');

    // This will get detailed device info, store it securely, and print to console
    await DeviceService.getDetailedDeviceInfo();

    print('✅ Device information stored and logged to console');
  } catch (e) {
    print('❌ Error storing device information: $e');
  }
}

/// Initialize device information and bootstrap flow
Future<void> _initializeDeviceAndBootstrap() async {
  try {
    // Print device information for debugging (this will also print stored info)
    await ApiService.printDeviceInfo();

    // Check if bootstrap is needed
    final needsBootstrap = await ApiService.isBootstrapNeeded();

    if (needsBootstrap) {
      print('🔄 Bootstrap required, starting bootstrap flow...');

      // Run bootstrap flow in background (don't block app startup)
      _runBootstrapInBackground();
    } else {
      print('✅ Bootstrap not needed, app owner info exists');

      // Optionally print existing app owner info
      final appOwnerInfo = await ApiService.getStoredAppOwnerInfo();
      if (appOwnerInfo != null) {
        print('👤 Existing client: ${appOwnerInfo['client_name']}');
      }
    }
  } catch (e) {
    print('❌ Error during device/bootstrap initialization: $e');
    // Don't let this error block the app from starting
  }
}

/// Run bootstrap in background without blocking UI
void _runBootstrapInBackground() {
  Future.microtask(() async {
    try {
      final appOwnerInfo = await ApiService.bootstrapFlow();
      if (appOwnerInfo != null) {
        print('🎉 Background bootstrap completed successfully');
        print('👤 Client: ${appOwnerInfo['client_name']}');
      } else {
        print('⚠️ Background bootstrap failed, but app can continue');
      }
    } catch (e) {
      print('❌ Background bootstrap error: $e');
      // App continues running even if bootstrap fails
    }
  });
}

class eMulakatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eMulakat',
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        colorScheme: AppColors.colorScheme,
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: SplashLogoScreen(),
    );
  }
}