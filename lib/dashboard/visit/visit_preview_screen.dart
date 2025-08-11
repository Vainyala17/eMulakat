import 'package:eMulakat/dashboard/visit/whom_to_meet_screen.dart';
import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import 'visit_home.dart';

class VisitPreviewScreen extends StatefulWidget {
  @override
  _VisitPreviewScreenState createState() => _VisitPreviewScreenState();
}

class _VisitPreviewScreenState extends State<VisitPreviewScreen> {

  // Dummy data for preview - this would normally come from the previous form
  final Map<String, dynamic> _visitData = {
    'state': 'Maharashtra',
    'jail': 'Yerawada Central Prison',
    'visitDate': '25/12/2024',
    'additionalVisitors': 2,
    'additionalVisitorNames': ['Priya Sharma', 'Rohit Kumar'],
  };

  final Map<String, dynamic> _prisonerData = {
    'name': 'Amit Kumar Sharma',
    'fatherName': 'Rajesh Kumar Sharma',
    'age': '28',
    'gender': 'Male',
    'visitType': 'Physical Visit',
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

  Widget _buildAdditionalVisitorsList() {
    if (_visitData['additionalVisitors'] == 0) {
      return Text(
        'No additional visitors',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Visitors (${_visitData['additionalVisitors']}):',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        ..._visitData['additionalVisitorNames'].asMap().entries.map((entry) {
          int index = entry.key;
          String name = entry.value;
          return Padding(
            padding: EdgeInsets.only(left: 16, bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '${index + 1}. $name',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
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
                    'Visit ID: #VIS2024001',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Request Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildStatusBadge('Pending Approval', Colors.orange),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Visit Details
            _buildPreviewCard(
              title: 'Visit Details',
              data: [
                MapEntry('State', _visitData['state']),
                MapEntry('Jail', _visitData['jail']),
                MapEntry('Visit Date', _visitData['visitDate']),
                MapEntry('Visit Type', _prisonerData['visitType']),
                MapEntry('Total Visitors', '${_visitData['additionalVisitors'] + 1}'), // +1 for main visitor
              ],
            ),

            // Prisoner Details
            _buildPreviewCard(
              title: 'Prisoner Details',
              data: [
                MapEntry('Prisoner Name', _prisonerData['name']),
                MapEntry('Father/Husband Name', _prisonerData['fatherName']),
                MapEntry('Age', _prisonerData['age'] + ' years'),
                MapEntry('Gender', _prisonerData['gender']),
              ],
            ),

            // Additional Visitors
            Card(
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
                      'Visitors Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildAdditionalVisitorsList(),
                  ],
                ),
              ),
            ),

            // Visit Guidelines
            Card(
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
                      'Important Guidelines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildGuidelineItem('Carry valid photo ID for verification'),
                    _buildGuidelineItem('Arrive 30 minutes before scheduled time'),
                    _buildGuidelineItem('Follow dress code: Formal attire required'),
                    _buildGuidelineItem('No mobile phones or electronic devices allowed'),
                    _buildGuidelineItem('Visit duration: Maximum 30 minutes'),
                    _buildGuidelineItem('Respect prison rules and regulations'),
                  ],
                ),
              ),
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
                      'Visit Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTimelineItem(
                      'Visit Request Submitted',
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      Icons.check_circle,
                      Colors.green,
                      true,
                    ),
                    _buildTimelineItem(
                      'Under Review',
                      'Estimated: 1-2 working days',
                      Icons.pending,
                      Colors.orange,
                      false,
                    ),
                    _buildTimelineItem(
                      'Approval/Rejection',
                      'Estimated: 3-5 working days',
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
                    text: 'Edit Visit',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    backgroundColor: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Submit Visit',
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
                          content: Text('Downloading visit request copy...'),
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
                          content: Text('Printing visit request...'),
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

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
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
          title: Text('Submit Visit Request'),
          content: Text('Are you sure you want to submit this visit request? Once submitted, you cannot edit the details.'),
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
                  MaterialPageRoute(builder: (context) => VisitHomeScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Visit request submitted successfully! ID: #VIS2024001'),
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