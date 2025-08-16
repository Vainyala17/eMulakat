import 'package:flutter/material.dart';
import '../../dashboard/grievance/grievance_details_screen.dart';
import '../../dashboard/grievance/grievance_home.dart';
import '../../dashboard/parole/parole_home.dart';
import '../../dashboard/parole/parole_screen.dart';
import '../../dashboard/visit/whom_to_meet_screen.dart';
import '../../models/visitor_model.dart';
import '../../utils/color_scheme.dart';

class VerticalVisitCard extends StatelessWidget {
  final VisitorModel visitor;
  final VoidCallback onTap;
  final String sourceType;
  final Map<String, dynamic>? inmate;

  const VerticalVisitCard({
    Key? key,
    required this.visitor,
    required this.sourceType,
    required this.onTap,
    this.inmate,
  }) : super(key: key);

  // Icons for different source types
  Map<String, IconData> get sourceTypeIcons => {
    'meeting': Icons.people_alt_rounded,
    'parole': Icons.exit_to_app_rounded,
    'grievance': Icons.report_problem_rounded,
  };

  // Enhanced icons for different info types
  Map<String, IconData> get infoIcons => {
    'person': Icons.person_rounded,
    'father': Icons.family_restroom_rounded,
    'meeting': Icons.handshake_rounded,
    'mode': Icons.videocam_rounded,
    'physical': Icons.place_rounded,
    'video': Icons.video_call_rounded,
    'date': Icons.calendar_today_rounded,
    'approved': Icons.check_circle_rounded,
    'remarks': Icons.note_alt_rounded,
    'address': Icons.home_rounded,
    'reason': Icons.help_center_rounded,
    'category': Icons.category_rounded,
    'description': Icons.description_rounded,
    'relation': Icons.family_restroom_rounded,
    'time': Icons.access_time_rounded,
    'jail': Icons.location_city_rounded,
    'status': Icons.info_rounded,
    'visitor': Icons.badge_rounded,
    'prisoner': Icons.person_pin_rounded,
  };

  String getDayOfWeek(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String getMonthName(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.month - 1];
  }

  Color statusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.completed:
        return const Color(0xFF4CAF50);
      case VisitStatus.expired:
        return const Color(0xFFF44336);
      case VisitStatus.pending:
        return const Color(0xFFFF9800);
      case VisitStatus.upcoming:
        return const Color(0xFF2196F3);
    }
  }


  String getStatusText(VisitStatus status) {
    switch (status) {
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.expired:
        return 'Expired';
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.upcoming:
        return 'Upcoming';
    }
  }

  // Generate dummy data based on visit type
  String _getVisitRegNo() {
    return 'VR-${DateTime.now().year}-${(visitor.visitorName.hashCode % 9999).abs().toString().padLeft(4, '0')}';
  }

  String _getRefNo() {
    return 'PR-${DateTime.now().year}-${(visitor.prisonerName.hashCode % 9999).abs().toString().padLeft(4, '0')}';
  }

  String _getGrievanceRegNo() {
    return 'GR-${DateTime.now().year}-${(visitor.visitorName.hashCode % 9999).abs().toString().padLeft(4, '0')}';
  }

  String _getModeOfMeeting() {
    return visitor.mode ? 'Physical': 'Video Conferencing';
  }

  String _getApprovedDate() {
    if (visitor.status == VisitStatus.upcoming || visitor.status == VisitStatus.completed) {
      return '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}';
    }
    return 'Pending';
  }

  String _getRemarks() {
    switch (visitor.status) {
      case VisitStatus.completed:
        return 'Visit completed successfully';
      case VisitStatus.upcoming:
        return 'Approved for visit';
      case VisitStatus.pending:
        return 'Under review';
      case VisitStatus.expired:
        return 'Visit slot expired';
      default:
        return 'No remarks';
    }
  }

  String _getLeaveFromDate() {
    return '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}';
  }

  String _getLeaveToDate() {
    DateTime toDate = visitor.visitDate.add(Duration(days: 7));
    return '${toDate.day}/${toDate.month}/${toDate.year}';
  }

  String _getSpentAddress() {
    return visitor.address;
  }

  String _getReason() {
    return 'Family emergency';
  }

  String _getGrievanceCategory() {
    final categories = ['Medical', 'Food', 'Legal', 'Family', 'Facilities'];
    return categories[visitor.visitorName.hashCode % categories.length];
  }

  String _getGrievanceDescription() {
    return 'Issue regarding ${_getGrievanceCategory().toLowerCase()} facilities and services';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        _navigateToDetailScreen(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Header Section with Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getGradientColors(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCardHeader(),
                    Row(
                      children: [
                        _buildStatusBadge(),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _navigateToDetailScreen(context),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildCardContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (sourceType.toLowerCase()) {
      case 'meeting':
        return [const Color(0xFF6992B8), const Color(0xFFA7C7E8)];
      case 'parole':
        return [const Color(0xFF6992B8), const Color(0xFFA7C7E8)];
      case 'grievance':
        return [const Color(0xFF6992B8), const Color(0xFFA7C7E8)];
      default:
        return [const Color(0xFF6992B8), const Color(0xFFA7C7E8)];
    }
  }

  Widget _buildCardHeader() {
    String title = '';
    //IconData headerIcon = Icons.help_outline_rounded;

    switch (sourceType.toLowerCase()) {
      case 'meeting':
        title = _getVisitRegNo();
        sourceTypeIcons['meeting'] ;
        break;
      case 'parole':
        title = _getRefNo();
       sourceTypeIcons['parole'] ;
        break;
      case 'grievance':
        title = _getGrievanceRegNo();
         sourceTypeIcons['grievance'];
        break;
      default:
        title = _getVisitRegNo();
    }

    return Row(
      children: [
        // Container(
        //   padding: EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: Colors.white.withOpacity(0.2),
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(
        //       color: Colors.white.withOpacity(0.3),
        //       width: 1,
        //     ),
        //   ),
        //   // child: Icon(
        //   //   color: Colors.white,
        //   //   size: 24,
        //   // ),
        // ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sourceType.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardContent() {
    switch (sourceType.toLowerCase()) {
      case 'meeting':
        return _buildMeetingContent();
      case 'parole':
        return _buildParoleContent();
      case 'grievance':
        return _buildGrievanceContent();
      default:
        return _buildMeetingContent();
    }
  }

  Widget _buildMeetingContent() {
    return Column(
      children: [
        _buildInfoRowWithIcon(infoIcons['prisoner']!, 'Meeting With', visitor.prisonerName),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(
          visitor.mode ? infoIcons['physical']! : infoIcons['video']!,
          'Mode of Meeting',
          _getModeOfMeeting(),
        ),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(
          infoIcons['date']!,
          'Requested Date',
          '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}',
        ),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(infoIcons['approved']!, 'Approved Date', _getApprovedDate()),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(infoIcons['remarks']!, 'Remarks', _getRemarks()),
      ],
    );
  }

  Widget _buildParoleContent() {
    return Column(
      children: [
        _buildInfoRowWithIcon(infoIcons['prisoner']!, 'Prisoner Name', visitor.prisonerName),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(infoIcons['father']!, 'Father Name', visitor.prisonerFatherName),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(infoIcons['date']!, 'Leave From', _getLeaveFromDate()),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(infoIcons['date']!, 'Leave To', _getLeaveToDate()),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(infoIcons['address']!, 'Spent Address', _getSpentAddress()),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(infoIcons['reason']!, 'Reason', _getReason()),
      ],
    );
  }

  Widget _buildGrievanceContent() {
    return Column(
      children: [
        _buildInfoRowWithIcon(infoIcons['prisoner']!, 'Prisoner Name', visitor.prisonerName),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(infoIcons['category']!, 'Category', _getGrievanceCategory()),
        const SizedBox(height: 12),
        _buildInfoRowWithIcon(infoIcons['description']!, 'Grievance', _getGrievanceDescription()),
      ],
    );
  }

  Widget _buildInfoRowWithIcon(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor(visitor.status), // ✅ full badge color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getStatusText(visitor.status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  void _navigateToDetailScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailViewScreen(
          visitor: visitor,
          sourceType: sourceType,
        ),
      ),
    );
  }
}

// Enhanced Detail View Screen
class DetailViewScreen extends StatelessWidget {
  final VisitorModel visitor;
  final String sourceType;

  const DetailViewScreen({
    Key? key,
    required this.visitor,
    required this.sourceType,
  }) : super(key: key);

  // Enhanced icons for different info types
  Map<String, IconData> get infoIcons => {
    'person': Icons.person_rounded,
    'father': Icons.family_restroom_rounded,
    'meeting': Icons.handshake_rounded,
    'mode': Icons.videocam_rounded,
    'physical': Icons.place_rounded,
    'video': Icons.video_call_rounded,
    'date': Icons.calendar_today_rounded,
    'approved': Icons.check_circle_rounded,
    'remarks': Icons.note_alt_rounded,
    'address': Icons.home_rounded,
    'reason': Icons.help_center_rounded,
    'category': Icons.category_rounded,
    'description': Icons.description_rounded,
    'relation': Icons.family_restroom_rounded,
    'time': Icons.access_time_rounded,
    'jail': Icons.location_city_rounded,
    'status': Icons.info_rounded,
    'visitor': Icons.badge_rounded,
    'prisoner': Icons.person_pin_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('${sourceType} Details',style: TextStyle(color: Colors.black),),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,color: Colors.black,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientColors(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getSourceIcon(),
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sourceType.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getHeaderTitle(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Details Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24.0),
              child: _buildDetailContent(),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (sourceType.toLowerCase()) {
      case 'meeting':
        return [const Color(0xFF6992B8), const Color(0xFFA7C7E8)];
      case 'parole':
        return [const Color(0xFF6992B8), const Color(0xFFA7C7E8)];
      case 'grievance':
        return [const Color(0xFF6992B8), const Color(0xFFA7C7E8)];
      default:
        return [const Color(0xFF6992B8), const Color(0xFFA7C7E8)];
    }
  }

  IconData _getSourceIcon() {
    switch (sourceType.toLowerCase()) {
      case 'meeting':
        return Icons.people_alt_rounded;
      case 'parole':
        return Icons.exit_to_app_rounded;
      case 'grievance':
        return Icons.report_problem_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getHeaderTitle() {
    switch (sourceType.toLowerCase()) {
      case 'meeting':
        return _getVisitRegNo();
      case 'parole':
        return _getRefNo();
      case 'grievance':
        return _getGrievanceRegNo();
      default:
        return 'Details';
    }
  }

  Widget _buildDetailContent() {
    switch (sourceType.toLowerCase()) {
      case 'meeting':
        return _buildMeetingDetails();
      case 'parole':
        return _buildParoleDetails();
      case 'grievance':
        return _buildGrievanceDetails();
      default:
        return _buildMeetingDetails();
    }
  }

  Widget _buildMeetingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRowWithIcon(infoIcons['visitor']!, 'Visit Registration No.', _getVisitRegNo()),
        _buildDetailRowWithIcon(infoIcons['prisoner']!, 'Meeting With', visitor.prisonerName),
        _buildDetailRowWithIcon(
          visitor.mode ? infoIcons['physical']! : infoIcons['video']!,
          'Mode of Meeting',
          visitor.mode ? 'Physical' : 'Video Conferencing',
        ),
        _buildDetailRowWithIcon(
          infoIcons['date']!,
          'Requested Visit Date',
          '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}',
        ),
        _buildDetailRowWithIcon(infoIcons['approved']!, 'Approved Visit Date', _getApprovedDate()),
        _buildDetailRowWithIcon(infoIcons['status']!, 'Visit Status', _getStatusText(visitor.status)),
        _buildDetailRowWithIcon(infoIcons['remarks']!, 'Remarks', _getRemarks()),
        _buildDetailRowWithIcon(infoIcons['person']!, 'Visitor Name', visitor.visitorName),
        _buildDetailRowWithIcon(infoIcons['jail']!, 'Jail', visitor.jail),
        _buildDetailRowWithIcon(infoIcons['time']!, 'Time Slot', '${visitor.startTime} - ${visitor.endTime}'),
      ],
    );
  }

  Widget _buildParoleDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRowWithIcon(infoIcons['visitor']!, 'Reference No.', _getRefNo()),
        _buildDetailRowWithIcon(infoIcons['prisoner']!, 'Prisoner Name', visitor.prisonerName),
        _buildDetailRowWithIcon(infoIcons['father']!, 'Father Name', visitor.prisonerFatherName),
        _buildDetailRowWithIcon(infoIcons['date']!, 'Leave From Date', _getLeaveFromDate()),
        _buildDetailRowWithIcon(infoIcons['date']!, 'Leave To Date', _getLeaveToDate()),
        _buildDetailRowWithIcon(infoIcons['address']!, 'Spent Address', visitor.address),
        _buildDetailRowWithIcon(infoIcons['reason']!, 'Reason', 'Family emergency'),
        _buildDetailRowWithIcon(infoIcons['status']!, 'Status', _getStatusText(visitor.status)),
        _buildDetailRowWithIcon(infoIcons['person']!, 'Applicant', visitor.visitorName),
        _buildDetailRowWithIcon(infoIcons['relation']!, 'Relation', visitor.relation),
      ],
    );
  }

  Widget _buildGrievanceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRowWithIcon(infoIcons['visitor']!, 'Grievance Registration No.', _getGrievanceRegNo()),
        _buildDetailRowWithIcon(infoIcons['prisoner']!, 'Prisoner Name', visitor.prisonerName),
        _buildDetailRowWithIcon(infoIcons['category']!, 'Grievance Category', _getGrievanceCategory()),
        _buildDetailRowWithIcon(infoIcons['description']!, 'Grievance Description', _getGrievanceDescription()),
        _buildDetailRowWithIcon(infoIcons['status']!, 'Status', _getStatusText(visitor.status)),
        _buildDetailRowWithIcon(infoIcons['person']!, 'Submitted By', visitor.visitorName),
        _buildDetailRowWithIcon(infoIcons['relation']!, 'Relation', visitor.relation),
        _buildDetailRowWithIcon(
          infoIcons['date']!,
          'Submitted Date',
          '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}',
        ),
      ],
    );
  }

  Widget _buildDetailRowWithIcon(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods (same as in VerticalVisitCard)
  String _getVisitRegNo() {
    return 'VR-${DateTime.now().year}-${(visitor.visitorName.hashCode % 9999).abs().toString().padLeft(4, '0')}';
  }

  String _getRefNo() {
    return 'PR-${DateTime.now().year}-${(visitor.prisonerName.hashCode % 9999).abs().toString().padLeft(4, '0')}';
  }

  String _getGrievanceRegNo() {
    return 'GR-${DateTime.now().year}-${(visitor.visitorName.hashCode % 9999).abs().toString().padLeft(4, '0')}';
  }

  String _getApprovedDate() {
    if (visitor.status == VisitStatus.upcoming || visitor.status == VisitStatus.completed) {
      return '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}';
    }
    return 'Pending';
  }

  String _getRemarks() {
    switch (visitor.status) {
      case VisitStatus.completed:
        return 'Visit completed successfully';
      case VisitStatus.upcoming:
        return 'Approved for visit';
      case VisitStatus.pending:
        return 'Under review';
      case VisitStatus.expired:
        return 'Visit slot expired';
      default:
        return 'No remarks';
    }
  }

  String _getLeaveFromDate() {
    return '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}';
  }

  String _getLeaveToDate() {
    DateTime toDate = visitor.visitDate.add(Duration(days: 7));
    return '${toDate.day}/${toDate.month}/${toDate.year}';
  }

  String _getGrievanceCategory() {
    final categories = ['Medical', 'Food', 'Legal', 'Family', 'Facilities'];
    return categories[visitor.visitorName.hashCode % categories.length];
  }

  String _getGrievanceDescription() {
    return 'Issue regarding ${_getGrievanceCategory().toLowerCase()} facilities and services requiring immediate attention and resolution';
  }

  String _getStatusText(VisitStatus status) {
    switch (status) {
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.expired:
        return 'Expired';
      case VisitStatus.pending:
        return 'Pending';
      case VisitStatus.upcoming:
        return 'Upcoming';
    }
  }
}