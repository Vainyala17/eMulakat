import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/visitor_model.dart';
import '../pdf_viewer_screen.dart';
import '../utils/color_scheme.dart';

class eVisitorPassScreen extends StatefulWidget {
  final VisitorModel visitor;

  const eVisitorPassScreen({super.key, required this.visitor});

  @override
  _eVisitorPassScreenState createState() => _eVisitorPassScreenState();
}

class _eVisitorPassScreenState extends State<eVisitorPassScreen> {
  List<String> _selectedInstructions = [];



  final List<String> instructions = [
    'Carry original ID proof',
    'Arrive 30 minutes early',
    'No mobile phones allowed',
    'Dress code: Formal attire',
    'No food items permitted',
    'Follow security guidelines',
    'Maintain silence during visit',
    'No recording devices',
    'Follow visitor queue',
    'Be respectful to staff',
    'No cash/valuables allowed',
    'Follow time limits strictly',
    'No smoking/alcohol',
    'Cooperate with security',
    'Follow COVID protocols',
    'No unauthorized photos'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('eVisitor Pass'),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildPassCard(),
            SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPassCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildPassInfo(),
          _buildVisitorSection(),
          _buildPrisonSection(),
          _buildInstructionsSection(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance,
            size: 50,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'MINISTRY OF HOME AFFAIRS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'VISITOR PASS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPassInfo() {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.03),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPassInfoItem(
                  'VALID DATE AND DURATION',
                  '15-JULY-2025 :: 11:30-16:15 HRS',
                  Icons.access_time,
                ),
                SizedBox(height: 15),
                _buildPassInfoItem(
                  'REGISTRATION NUMBER',
                  '2/0000/2025/43.57/9/2025/10249',
                  Icons.confirmation_number,
                ),
                SizedBox(height: 15),
                _buildPassInfoItem(
                  'REGISTRATION DATE',
                  '10 JULY 2025 :: 9:10 HRS',
                  Icons.date_range,
                ),
              ],
            ),
          ),
          SizedBox(width: 30),
          _buildQRCodeSection(),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.qr_code_2, size: 80, color: AppColors.primary),
          SizedBox(height: 8),
          Text(
            'QR CODE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorSection() {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('VISITOR DETAILS', Icons.person),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visitor Details
              Expanded(
                child: Column(
                  children: [
                    _buildInfoField('NAME', widget.visitor.visitorName ?? 'N/A'),
                    SizedBox(height: 12),
                    _buildInfoField('F/H NAME', widget.visitor.fatherName ?? 'N/A'),
                    SizedBox(height: 12),
                    _buildInfoField('GENDER', widget.visitor.gender ?? 'N/A'),
                    SizedBox(height: 12),
                    _buildInfoField('MOBILE NO.', widget.visitor.mobile  ?? 'N/A'),
                    SizedBox(height: 12),
                    SizedBox(height: 12),
                    _buildInfoField('ADDRESS', widget.visitor.address ?? 'N/A'),
                    SizedBox(height: 12),
                    _buildInfoField('ID TYPE', widget.visitor.idProof ?? 'N/A'),
                    SizedBox(height: 12),
                    _buildInfoField('ID NUMBER', widget.visitor.idNumber ?? 'N/A'),
                    SizedBox(height: 15),
                    _buildVisitModeCard(),
                  ],
                ),
              ),
              SizedBox(width: 10),
              _buildPhotoSection(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitModeCard() {
    bool isVideoMode = widget.visitor.mode == false;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isVideoMode ? Colors.green.withOpacity(0.08) : Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVideoMode ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isVideoMode ? Icons.video_call : Icons.directions_walk,
                color: isVideoMode ? Colors.green[600] : Colors.blue[600],
                size: 24,
              ),
              SizedBox(width: 20),
              Text(
                isVideoMode ? 'Video Conference' : 'Physical Visit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isVideoMode ? Colors.green[700] : Colors.blue[700],
                ),
              ),
            ],
          ),
          if (isVideoMode) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'VIDEO CONFERENCE LINK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'https://meet.google.com/jdj-uyxi-gfu',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 40,
            color: Colors.grey[500],
          ),
          SizedBox(height: 8),
          Text(
            'PHOTO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrisonSection() {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('TO MEET', Icons.account_balance),
          SizedBox(height: 20),
          _buildInfoField('PRISONER NAME', widget.visitor.prisonerName ?? 'N/A'),
          SizedBox(height: 12),
          _buildInfoField('PRISON DETAILS', widget.visitor.jail ?? 'TIHAR CENTRAL JAIL NO.2\nDELHI - 110092'),
          SizedBox(height: 12),
          _buildInfoField('APPROVING OFFICER', 'SHRI RAMA REDDY (JAILOR)'),
          SizedBox(height: 20),
          _buildApprovalCard(),
        ],
      ),
    );
  }

  Widget _buildApprovalCard() {
    final status = widget.visitor.status;
    final visitDate = widget.visitor.visitDate;
    final startTime = widget.visitor.startTime ?? '--:--';
    final endTime = widget.visitor.endTime ?? '--:--';
    final dayOfWeek = widget.visitor.dayOfWeek ?? 'N/A';

    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (status) {
      case VisitStatus.approved:
        statusIcon = Icons.verified;
        statusColor = Colors.green;
        statusText = 'APPROVED';
        break;
      case VisitStatus.rejected:
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        statusText = 'REJECTED';
        break;
      case VisitStatus.pending:
        statusIcon = Icons.hourglass_bottom;
        statusColor = Colors.orange;
        statusText = 'PENDING';
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'APPROVAL STATUS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              visitDate != null
                  ? 'DATE: ${DateFormat('dd MMMM yyyy').format(visitDate)}\n:: $startTime - $endTime HRS \n($dayOfWeek)'
                  : 'DATE: N/A\n:: --:-- HRS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInstructionsSection() {
    return Container(
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('INSTRUCTIONS', Icons.rule),
          SizedBox(height: 15),
          Text(
            'Please follow all applicable instructions during your visit:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 10),
          _buildInstructionsGrid(),
        ],
      ),
    );
  }

  Widget _buildInstructionsGrid() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(instructions.length, (index) {
          bool isChecked = _selectedInstructions.contains(index.toString());

          return CheckboxListTile(
            value: isChecked,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedInstructions.add(index.toString());
                } else {
                  _selectedInstructions.remove(index.toString());
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              '${index + 1}. ${instructions[index]}',
              style: TextStyle(
                fontSize: 14,
                color: isChecked ? AppColors.primary : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
          );
        }),
      ),
    );
  }



  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
              SizedBox(width: 8),
              Text(
                'This is a digitally generated visitor pass',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            'Generated on: ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassInfoItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _downloadPass,
            icon: Icon(Icons.download, color: Colors.white, size: 18),
            label: Text(
              'DOWNLOAD PASS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  void _downloadPass() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.download, color: Colors.black),
            SizedBox(width: 12),
            Text(
              'Pass downloaded successfully!',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF7AA9D4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

}