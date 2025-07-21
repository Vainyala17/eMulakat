import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'screens/splash/splash_logo.dart';
import 'utils/color_scheme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
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
      child:eMulakatApp(),
    ),
  );
}

class eMulakatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eMulakat', // Connects DevicePreview to your app
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