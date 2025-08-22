import 'package:flutter/material.dart';
import '../services/device_service.dart';
import '../pdf_viewer_screen.dart';

class AccountSettingsScreen extends StatelessWidget {
  /// Show Device Info Dialog
  void _showDeviceInfoDialog(BuildContext context) async {
    // Show loading first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get stored device info
      final deviceInfo = await DeviceService.getStoredDeviceInfo();

      // Close loading dialog
      Navigator.pop(context);

      // 🔥 ALSO PRINT TO CONSOLE
      await DeviceService.printStoredDeviceInfoToConsole();

      if (deviceInfo != null) {
        // Show device info dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.phone_android, color: Colors.blue),
                SizedBox(width: 8),
                Text('Device Information'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfoRow('Platform', deviceInfo['platform'] ?? 'Unknown'),
                  _buildInfoRow('Model', deviceInfo['model'] ?? 'Unknown'),

                  if (deviceInfo['platform'] == 'Android') ...[
                    _buildInfoRow('Manufacturer', deviceInfo['manufacturer'] ?? 'Unknown'),
                    _buildInfoRow('Brand', deviceInfo['brand'] ?? 'Unknown'),
                    _buildInfoRow('Device', deviceInfo['device'] ?? 'Unknown'),
                    _buildInfoRow('Android Version', deviceInfo['androidVersion'] ?? 'Unknown'),
                    _buildInfoRow('SDK Int', deviceInfo['sdkInt']?.toString() ?? 'Unknown'),
                    _buildInfoRow('Android ID', _truncateText(deviceInfo['androidId'] ?? 'Unknown')),
                  ],

                  if (deviceInfo['platform'] == 'iOS') ...[
                    _buildInfoRow('Name', deviceInfo['name'] ?? 'Unknown'),
                    _buildInfoRow('System', '${deviceInfo['systemName']} ${deviceInfo['systemVersion']}'),
                    _buildInfoRow('Vendor ID', _truncateText(deviceInfo['identifierForVendor'] ?? 'Unknown')),
                  ],

                  _buildInfoRow('Physical Device', deviceInfo['isPhysicalDevice']?.toString() ?? 'Unknown'),
                  _buildInfoRow('Fingerprint', _truncateText(deviceInfo['fingerprint'] ?? 'Unknown')),
                  _buildInfoRow('App Key', _truncateText(deviceInfo['appKey'] ?? 'Not Generated')),
                  _buildInfoRow('Stored At', _formatTimestamp(deviceInfo['timestamp'])),

                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 16, color: Colors.blue),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This information is stored securely on your device',
                            style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  // Refresh device info
                  Navigator.pop(context);
                  await DeviceService.getDetailedDeviceInfo(); // This will store fresh info
                  _showDeviceInfoDialog(context); // Show dialog again with fresh data
                },
                child: Text('Refresh'),
              ),
            ],
          ),
        );
      } else {
        // No device info found, generate it
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Device Information'),
            content: Text('No device information found. Would you like to generate it?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Generate device info
                  await DeviceService.getDetailedDeviceInfo();
                  _showDeviceInfoDialog(context); // Show dialog with generated info
                },
                child: Text('Generate'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      Navigator.pop(context);

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load device information: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Build info row widget
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Truncate long text
  String _truncateText(String text, {int maxLength = 20}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Format timestamp
  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Unknown';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Setting & Account'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(
                    assetPath: 'assets/pdfs/about_us.pdf',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // User Info Section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, size: 30, color: Colors.white),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('your.email@example.com', style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),

          Divider(),

          // Account Options
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('My Profile'),
            onTap: () {
              // Navigate to Profile screen
            },
          ),
          ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('My Address'),
            onTap: () {
              // Navigate to Address screen
            },
          ),

          Divider(),

          // Settings Options
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            onTap: () {
              // Change language
            },
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Dark Mode'),
            onTap: () {
              // Toggle dark mode
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {
              // Navigate to Notification settings
            },
          ),

          // 🔥 NEW: Device Information Option
          ListTile(
            leading: Icon(Icons.phone_android, color: Colors.green),
            title: Text('Device Information'),
            subtitle: Text('View stored device details'),
            onTap: () => _showDeviceInfoDialog(context),
          ),

          Divider(),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Logout logic
            },
          ),
        ],
      ),
    );
  }
}