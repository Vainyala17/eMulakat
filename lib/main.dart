import 'package:flutter/material.dart';
import 'screens/splash/splash_logo.dart';
import 'utils/color_scheme.dart';

void main() {
  runApp( eMulakatApp());
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
      home: SplashLogoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}