import 'package:flutter/material.dart';
import '../../dashboard/grievance/grievance_details_screen.dart';
import '../../dashboard/grievance/grievance_home.dart';
import '../../dashboard/parole/parole_home.dart';
import '../../dashboard/parole/parole_screen.dart';
import '../../dashboard/visit/whom_to_meet_screen.dart';
import '../../models/visitor_model.dart';
import '../../utils/color_scheme.dart';
import '../../dashboard/visit/visit_preview1.dart';

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
    'meeting': Icons.people_outline,
    'parole': Icons.exit_to_app_outlined,
    'grievance': Icons.report_problem_outlined,
  };

  // Icons for different info types
  Map<String, IconData> get infoIcons => {
    'person': Icons.person_outline,
    'father': Icons.family_restroom_outlined,
    'meeting': Icons.handshake_outlined,
    'mode': Icons.videocam_outlined,
    'physical': Icons.place_outlined,
    'video': Icons.video_call_outlined,
    'date': Icons.calendar_today_outlined,
    'approved': Icons.check_circle_outline,
    'remarks': Icons.note_outlined,
    'address': Icons.home_outlined,
    'reason': Icons.help_outline,
    'category': Icons.category_outlined,
    'description': Icons.description_outlined,
    'relation': Icons.family_restroom_outlined,
    'time': Icons.access_time_outlined,
    'jail': Icons.location_city_outlined,
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
        return Colors.green;
      case VisitStatus.expired:
        return Colors.red;
      case VisitStatus.pending:
        return Colors.orange;
      case VisitStatus.upcoming:
        return Colors.blue;
    }
  }

  IconData statusIcon(VisitStatus status) {
    switch (status) {
      case VisitStatus.completed:
        return Icons.check_circle;
      case VisitStatus.expired:
        return Icons.cancel;
      case VisitStatus.pending:
        return Icons.hourglass_empty;
      case VisitStatus.upcoming:
        return Icons.schedule;
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildCardContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    String title = '';
    IconData headerIcon = Icons.help_outline;

    switch (sourceType.toLowerCase()) {
      case 'meeting':
        title = _getVisitRegNo();
        headerIcon = sourceTypeIcons['meeting'] ?? Icons.people_outline;
        break;
      case 'parole':
        title = _getRefNo();
        headerIcon = sourceTypeIcons['parole'] ?? Icons.exit_to_app_outlined;
        break;
      case 'grievance':
        title = _getGrievanceRegNo();
        headerIcon = sourceTypeIcons['grievance'] ?? Icons.info_outline;
        break;
      default:
        title = _getVisitRegNo();
    }

    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
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
        _buildInfoRow('Meeting With:', visitor.prisonerName),
        const SizedBox(height: 8),
        _buildInfoRow('Mode of Meeting:', _getModeOfMeeting()),
        const SizedBox(height: 8),
        _buildInfoRow('Requested Visit Date:',
            '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}'),
        const SizedBox(height: 8),
        _buildInfoRow('Approved Visit Date:', _getApprovedDate()),
        const SizedBox(height: 8),
        _buildInfoRow('Remarks:', _getRemarks()),
      ],
    );
  }

  Widget _buildParoleContent() {
    return Column(
      children: [
        _buildInfoRow('Prisoner Name:', visitor.prisonerName),
        const SizedBox(height: 8),
        _buildInfoRow('Father Name:', visitor.prisonerFatherName),
        const SizedBox(height: 8),
        _buildInfoRow('Leave From Date:', _getLeaveFromDate()),
        const SizedBox(height: 8),
        _buildInfoRow('Leave To Date:', _getLeaveToDate()),
        const SizedBox(height: 8),
        _buildInfoRow('Spent Address:', _getSpentAddress()),
        const SizedBox(height: 8),
        _buildInfoRow('Reason:', _getReason()),
      ],
    );
  }

  Widget _buildGrievanceContent() {
    return Column(
      children: [
        _buildInfoRow('Prisoner Name:', visitor.prisonerName),
        const SizedBox(height: 8),
        _buildInfoRow('Grievance Category:', _getGrievanceCategory()),
        const SizedBox(height: 8),
        _buildInfoRow('Grievance:', _getGrievanceDescription()),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor(visitor.status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        getStatusText(visitor.status),
        style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  void _navigateToDetailScreen(BuildContext context) {
    // Navigate to detailed view screen
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

// Detail View Screen to show all information
class DetailViewScreen extends StatelessWidget {
  final VisitorModel visitor;
  final String sourceType;

  const DetailViewScreen({
    Key? key,
    required this.visitor,
    required this.sourceType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('$sourceType Details'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            color: Colors.black,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
        _buildDetailRow('Visit Reg No.:', _getVisitRegNo()),
        _buildDetailRow('Meeting With:', visitor.prisonerName),
        _buildDetailRow('Mode of Meeting:', visitor.mode ? 'Physical': 'Video Conferencing'),
        _buildDetailRow('Requested Visit Date:',
            '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}'),
        _buildDetailRow('Approved Visit Date:', _getApprovedDate()),
        _buildDetailRow('Visit Status:', _getStatusText(visitor.status)),
        _buildDetailRow('Remarks:', _getRemarks()),
        _buildDetailRow('Visitor Name:', visitor.visitorName),
        _buildDetailRow('Jail:', visitor.jail),
        _buildDetailRow('Time Slot:', '${visitor.startTime} - ${visitor.endTime}'),
      ],
    );
  }

  Widget _buildParoleDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Ref No.:', _getRefNo()),
        _buildDetailRow('Prisoner Name:', visitor.prisonerName),
        _buildDetailRow('Father Name:', visitor.prisonerFatherName),
        _buildDetailRow('Leave From Date:', _getLeaveFromDate()),
        _buildDetailRow('Leave To Date:', _getLeaveToDate()),
        _buildDetailRow('Spent Address:', visitor.address),
        _buildDetailRow('Reason:', 'Family emergency'),
        _buildDetailRow('Status:', _getStatusText(visitor.status)),
        _buildDetailRow('Applicant:', visitor.visitorName),
        _buildDetailRow('Relation:', visitor.relation),
      ],
    );
  }

  Widget _buildGrievanceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Grievance Reg No.:', _getGrievanceRegNo()),
        _buildDetailRow('Prisoner Name:', visitor.prisonerName),
        _buildDetailRow('Grievance Category:', _getGrievanceCategory()),
        _buildDetailRow('Grievance:', _getGrievanceDescription()),
        _buildDetailRow('Status:', _getStatusText(visitor.status)),
        _buildDetailRow('Submitted By:', visitor.visitorName),
        _buildDetailRow('Relation:', visitor.relation),
        _buildDetailRow('Submitted Date:',
            '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
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