import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:eMulakat/services/secure_storage_service.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DeviceService {
  static const String FINGERPRINT_KEY = 'device_fingerprint';
  //static const String APP_KEY = 'app_key';
  static const String DEVICE_INFO_KEY = 'detailed_device_info';

  /// Get device information as User-Agent string
  static Future<String> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String userAgent = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        userAgent = '${androidInfo.version.release} ${androidInfo.version.sdkInt} - ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        userAgent = '${iosInfo.systemName} ${iosInfo.systemVersion} - ${iosInfo.model}';
      }

      print('📱 Device Info: $userAgent');
      return userAgent;
    } catch (e) {
      print('❌ Error getting device info: $e');
      return 'Unknown Device';
    }
  }

  // Add these methods to your DeviceService class

  /// Check if device info has been captured for current installation
  static Future<bool> isDeviceInfoCaptured() async {
    try {
      final stored = await SecureStorageService.read(key: 'device_info_captured');
      return stored == 'true';
    } catch (e) {
      print('❌ Error checking device info capture status: $e');
      return false;
    }
  }

  /// Mark device info as captured (call this after successful capture)
  static Future<void> markDeviceInfoAsCaptured() async {
    try {
      await SecureStorageService.write(key: 'device_info_captured', value: 'true');
      print('✅ Device info marked as captured');
    } catch (e) {
      print('❌ Error marking device info as captured: $e');
    }
  }

  /// Capture device info only if not already captured
  static Future<void> captureDeviceInfoOnce({required String screenName}) async {
    try {
      final alreadyCaptured = await isDeviceInfoCaptured();

      if (alreadyCaptured) {
        print('ℹ️ Device info already captured, skipping...');
        return;
      }

      print('🔄 Capturing device info from screen: $screenName');

      // Get and store device information
      await getDetailedDeviceInfo();

      // Mark as captured to prevent future captures
      await markDeviceInfoAsCaptured();

      print('✅ Device info captured successfully from $screenName');
    } catch (e) {
      print('❌ Error capturing device info from $screenName: $e');
    }
  }

  /// Reset capture flag (only for testing - not for production use)
  static Future<void> resetDeviceInfoCaptureFlag() async {
    try {
      await SecureStorageService.delete(key: 'device_info_captured');
      print('🔄 Device info capture flag reset');
    } catch (e) {
      print('❌ Error resetting capture flag: $e');
    }
  }

  /// Get or generate device fingerprint
  static Future<String> getDeviceFingerprint() async {
    try {
      // Check if fingerprint already exists
      final cached = await SecureStorageService.read(key: FINGERPRINT_KEY);
      if (cached != null && cached.isNotEmpty) {
        print('🔍 Using cached fingerprint: ${cached.substring(0, 10)}...');
        return cached;
      }

      // Generate new fingerprint
      final deviceInfo = DeviceInfoPlugin();
      String rawId = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        rawId = androidInfo.id ?? '';

        // Fallback if id is null or empty
        if (rawId.isEmpty) {
          rawId = '${androidInfo.model}-${androidInfo.brand}-${DateTime.now().millisecondsSinceEpoch}';
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        rawId = iosInfo.identifierForVendor ?? '';

        // Fallback if identifierForVendor is null or empty
        if (rawId.isEmpty) {
          rawId = '${iosInfo.model}-${iosInfo.systemName}-${DateTime.now().millisecondsSinceEpoch}';
        }
      }

      // Create SHA256 hash of rawId
      final bytes = utf8.encode(rawId);
      final digest = sha256.convert(bytes);
      final fingerprint = digest.toString();

      // Store fingerprint securely
      await SecureStorageService.write(key: FINGERPRINT_KEY, value: fingerprint);

      print('🔐 Generated new fingerprint: ${fingerprint.substring(0, 10)}...');
      return fingerprint;
    } catch (e) {
      print('❌ Error generating fingerprint: $e');
      // Return a fallback fingerprint based on timestamp
      final fallback = sha256.convert(utf8.encode('fallback-${DateTime.now().millisecondsSinceEpoch}')).toString();
      await SecureStorageService.write(key: FINGERPRINT_KEY, value: fallback);
      return fallback;
    }
  }

  // / Generate app key (equivalent to React Native version)
  // static String generateAppKey() {
  //   // Replace these with your actual values
  //   const String ORDER_ID = "your_order_id";
  //   const String ORDER_DATE = "your_order_date";
  //   const String APP_NAME = "eMulakat";
  //
  //   final raw = '$ORDER_ID|$ORDER_DATE|$APP_NAME';
  //   final bytes = utf8.encode(raw);
  //   final digest = sha256.convert(bytes);
  //   final appKey = digest.toString();
  //
  //   print('🔧 Raw String: $raw');
  //   print('🔑 Generated app_key: ${appKey.substring(0, 10)}...');
  //
  //   return appKey;
  // }
  //
  // / Store app key securely
  // static Future<void> storeAppKey(String appKey) async {
  //   await SecureStorageService.write(key: APP_KEY, value: appKey);
  //   print('💾 App key stored securely');
  // }
  //
  // / Get stored app key
  // static Future<String?> getStoredAppKey() async {
  //   return await SecureStorageService.read(key: APP_KEY);
  // }

  /// Get complete device details (for debugging/logging) and STORE them
  static Future<Map<String, dynamic>> getDetailedDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> details = {};

      // Get IP address
      String ipAddress = await _getLocalIPAddress();

      // Get logged in mobile number
      String? loggedInMobile = await _getLoggedInMobileNumber();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        details = {
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'androidId': androidInfo.id,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'fingerprint': await getDeviceFingerprint(),
          'ipAddress': ipAddress,
          'mobileNumber': loggedInMobile ?? 'Not Available',
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        details = {
          'platform': 'iOS',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'fingerprint': await getDeviceFingerprint(),
          'ipAddress': ipAddress,
          'mobileNumber': loggedInMobile ?? 'Not Available',
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

      // 🔥 STORE device info securely
      await SecureStorageService.write(
          key: DEVICE_INFO_KEY,
          value: json.encode(details)
      );

      // 🔥 CONSOLE LOGGING - Print stored device info
      print('');
      print('🔍 ===== DEVICE INFORMATION STORED =====');
      print('📱 Platform: ${details['platform']}');
      print('🏷️ Model: ${details['model']}');
      if (details['platform'] == 'Android') {
        print('🏭 Manufacturer: ${details['manufacturer']}');
        print('🔖 Brand: ${details['brand']}');
        print('📋 Device: ${details['device']}');
        print('🤖 Android Version: ${details['androidVersion']}');
        print('📊 SDK Int: ${details['sdkInt']}');
        print('🆔 Android ID: ${details['androidId']}');
      } else if (details['platform'] == 'iOS') {
        print('📛 Name: ${details['name']}');
        print('🍎 System: ${details['systemName']} ${details['systemVersion']}');
        print('🆔 Vendor ID: ${details['identifierForVendor']}');
      }
      print('📱 Physical Device: ${details['isPhysicalDevice']}');
      print('🔐 Fingerprint: ${details['fingerprint']?.toString().substring(0, 16)}...');
      print('🌐 IP Address: ${details['ipAddress']}');
      print('📞 Mobile Number: ${details['mobileNumber']}');
      print('⏰ Timestamp: ${details['timestamp']}');
      print('💾 Device info stored securely in encrypted storage');
      print('===== END DEVICE INFO =====');
      print('');

      return details;
    } catch (e) {
      print('❌ Error getting detailed device info: $e');
      return {'error': e.toString()};
    }
  }

  static Future<String> _getLocalIPAddress() async {
    try {
      final info = NetworkInfo();

      // Try to get WiFi IP address
      final wifiIP = await info.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty) {
        return wifiIP;
      }

      // Fallback: Try to get IP using socket connection
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // This gets external IP, but we want local IP
          // Use a different approach for local IP
          for (var interface in await NetworkInterface.list()) {
            for (var addr in interface.addresses) {
              if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
                return addr.address;
              }
            }
          }
        }
      } catch (e) {
        print('❌ Error getting IP via socket: $e');
      }

      return 'Unable to detect';
    } catch (e) {
      print('❌ Error getting IP address: $e');
      return 'Unknown';
    }
  }


  /// Helper method to get logged in mobile number from secure storage
  static Future<String?> _getLoggedInMobileNumber() async {
    try {
      // Try to get from secure storage where login info is stored
      return await SecureStorageService.read(key: 'logged_in_mobile');
    } catch (e) {
      print('❌ Error getting logged in mobile: $e');
      return null;
    }
  }

  /// Store logged in mobile number (call this after successful login)
  static Future<void> storeLoggedInMobileNumber(String mobileNumber) async {
    try {
      await SecureStorageService.write(key: 'logged_in_mobile', value: mobileNumber);
      print('📞 Stored logged in mobile number');
    } catch (e) {
      print('❌ Error storing logged in mobile: $e');
    }
  }

  /// Clear logged in mobile number (call this on logout)
  static Future<void> clearLoggedInMobileNumber() async {
    try {
      await SecureStorageService.delete(key: 'logged_in_mobile');
      print('🗑️ Cleared logged in mobile number');
    } catch (e) {
      print('❌ Error clearing logged in mobile: $e');
    }
  }

  /// 🔥 NEW: Get stored device information
  static Future<Map<String, dynamic>?> getStoredDeviceInfo() async {
    try {
      final storedInfo = await SecureStorageService.read(key: DEVICE_INFO_KEY);
      if (storedInfo != null) {
        final deviceInfo = json.decode(storedInfo) as Map<String, dynamic>;

        // 🔥 CONSOLE LOGGING when retrieved
        print('');
        print('🔍 ===== RETRIEVED STORED DEVICE INFO =====');
        print('📱 Platform: ${deviceInfo['platform']}');
        print('🏷️ Model: ${deviceInfo['model']}');
        print('🔐 Fingerprint: ${deviceInfo['fingerprint']?.toString().substring(0, 16)}...');
        print('⏰ Stored at: ${deviceInfo['timestamp']}');
        print('===== END RETRIEVED INFO =====');
        print('');

        return deviceInfo;
      }
      return null;
    } catch (e) {
      print('❌ Error reading stored device info: $e');
      return null;
    }
  }

  /// 🔥 NEW: Print all stored device info to console
  static Future<void> printStoredDeviceInfoToConsole() async {
    try {
      final storedInfo = await getStoredDeviceInfo();
      if (storedInfo != null) {
        print('');
        print('🔍 ===== COMPLETE STORED DEVICE INFO =====');
        storedInfo.forEach((key, value) {
          if (key == 'fingerprint') {
            print('$key: ${value?.toString().substring(0, 20)}...');
          } else {
            print('$key: $value');
          }
        });
        print('===== END COMPLETE INFO =====');
        print('');
      } else {
        print('⚠️ No device info found in storage');
      }
    } catch (e) {
      print('❌ Error printing stored device info: $e');
    }
  }

  /// Clear stored fingerprint (for testing/reset)
  static Future<void> clearFingerprint() async {
    await SecureStorageService.delete(key: FINGERPRINT_KEY);
    print('🗑️ Fingerprint cleared');
  }

  /// Clear all stored data including device info
  static Future<void> clearAllStoredData() async {
    await SecureStorageService.deleteAll();
    print('🗑️ All stored data cleared');
  }

  /// 🔥 NEW: Clear only device info
  static Future<void> clearStoredDeviceInfo() async {
    await SecureStorageService.delete(key: DEVICE_INFO_KEY);
    print('🗑️ Stored device info cleared');
  }
}