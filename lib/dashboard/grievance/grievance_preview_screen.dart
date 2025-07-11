import 'package:flutter/material.dart';
import '../../pdf_viewer_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/form_section_title.dart';
import '../visit/visit_home.dart';
import 'grievance_home.dart';

class GrievancePreviewScreen extends StatefulWidget {
  @override
  _GrievancePreviewScreenState createState() => _GrievancePreviewScreenState();
}

class _GrievancePreviewScreenState extends State<GrievancePreviewScreen> {
  int _selectedIndex = 0;

  // Dummy data for preview
  final Map<String, dynamic> _complainantData = {
    'name': 'Rajesh Kumar Sharma',
    'relation': 'Father',
    'email': 'rajesh.sharma@email.com',
    'mobile': '9876543210',
    'isInternational': false,
    'isOtpVerified': true,
  };

  final Map<String, dynamic> _grievanceData = {
    'state': 'Maharashtra',
    'jail': 'Yerawada Central Prison',
    'prisonerName': 'Amit Kumar Sharma',
    'prisonerAge': '28',
    'prisonerGender': 'Male',
    'category': 'Basic Facilities not provided inside prison',
    'message': 'The prisoner is not getting proper medical facilities and the food quality is very poor. There are also issues with cleanliness in the barracks.',
  };

  Widget _buildPreviewCard({
    required String title,
    required List<MapEntry<String, String>> data,
  }) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 12),
            ...data.map((entry) => _buildDataRow(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grievance ID: #GRV2024001',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildStatusBadge('Pending Review', Colors.orange),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Complainant Details
            _buildPreviewCard(
              title: 'Complainant Details',
              data: [
                MapEntry('Name', _complainantData['name']),
                MapEntry('Relation to Prisoner', _complainantData['relation']),
                MapEntry('Email', _complainantData['email']),
                MapEntry('Mobile Number', _complainantData['mobile']),
                MapEntry('Visitor Type', _complainantData['isInternational'] ? 'International' : 'Domestic'),
                MapEntry('Mobile Verification', _complainantData['isOtpVerified'] ? 'Verified ✓' : 'Not Verified ✗'),
              ],
            ),

            // Prison & Prisoner Details
            _buildPreviewCard(
              title: 'Prison & Prisoner Details',
              data: [
                MapEntry('State', _grievanceData['state']),
                MapEntry('Jail', _grievanceData['jail']),
                MapEntry('Prisoner Name', _grievanceData['prisonerName']),
                MapEntry('Prisoner Age', _grievanceData['prisonerAge'] + ' years'),
                MapEntry('Prisoner Gender', _grievanceData['prisonerGender']),
              ],
            ),

            // Grievance Details
            _buildPreviewCard(
              title: 'Grievance Details',
              data: [
                MapEntry('Category', _grievanceData['category']),
                MapEntry('Issue Description', _grievanceData['message']),
              ],
            ),

            // Action Timeline
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Action Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTimelineItem(
                      'Grievance Submitted',
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute}',
                      Icons.check_circle,
                      Colors.green,
                      true,
                    ),
                    _buildTimelineItem(
                      'Under Review',
                      'Estimated: 2-3 working days',
                      Icons.pending,
                      Colors.orange,
                      false,
                    ),
                    _buildTimelineItem(
                      'Resolution',
                      'Estimated: 7-10 working days',
                      Icons.done_all,
                      Colors.grey,
                      false,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Edit Grievance',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Submit Grievance',
                    onPressed: () {
                      _showSubmissionDialog();
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Download/Print Options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Download functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Downloading grievance copy...'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    icon: Icon(Icons.download),
                    label: Text('Download PDF'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Print functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Printing grievance...'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    icon: Icon(Icons.print),
                    label: Text('Print'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, IconData icon, Color color, bool isCompleted) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? color : color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : color,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.black87 : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit Grievance'),
          content: Text('Are you sure you want to submit this grievance? Once submitted, you cannot edit the details.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GrievanceHomeScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Grievance submitted successfully! ID: #GRV2024001'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}