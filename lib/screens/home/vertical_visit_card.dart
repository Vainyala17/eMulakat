import 'package:flutter/material.dart';
import '../../models/visitor_model.dart';
import '../../utils/color_scheme.dart';
import 'detail_view.dart';

// ✅ FIXED: Remove duplicate methods and fix syntax errors

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

  // ✅ FIXED: Generate data based on visit type and API fields
  String _getVisitRegNo() {
    // Use actual API data if available, otherwise generate
    if (visitor.id.isNotEmpty && visitor.id != DateTime.now().millisecondsSinceEpoch.toString()) {
      return visitor.id;
    }
    return 'VR-${DateTime.now().year}-${(visitor.prisonerName.hashCode % 9999).abs().toString().padLeft(4, '0')}';
  }

  String _getRefNo() {
    if (visitor.id.isNotEmpty && visitor.id != DateTime.now().millisecondsSinceEpoch.toString()) {
      return visitor.id;
    }
    return 'PR-${DateTime.now().year}-${(visitor.prisonerName.hashCode % 9999).abs().toString().padLeft(4, '0')}';
  }

  String _getGrievanceRegNo() {
    if (visitor.id.isNotEmpty && visitor.id != DateTime.now().millisecondsSinceEpoch.toString()) {
      return visitor.id;
    }
    return 'GR-${DateTime.now().year}-${(visitor.prisonerName.hashCode % 9999).abs().toString().padLeft(4, '0')}';
  }

  String _getModeOfMeeting() {
    // Use API data if available
    if (visitor.meetingMode?.isNotEmpty == true) {
      return visitor.meetingMode!;
    }
    return visitor.mode ? 'Physical' : 'Video Conferencing';
  }

  String _getApprovedDate() {
    // Use API approved date if available
    if (visitor.apprVisitDate?.isNotEmpty == true && visitor.apprVisitDate != null) {
      return visitor.apprVisitDate!;
    }

    if (visitor.status == VisitStatus.upcoming || visitor.status == VisitStatus.completed) {
      return '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}';
    }
    return 'Pending';
  }

  String _getRemarks() {
    // Use API remarks if available
    if (visitor.remarks?.isNotEmpty == true) {
      return visitor.remarks!;
    }

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

  String _getRequestedDate() {
    // Use API requested date if available
    if (visitor.reqVisitDate?.isNotEmpty == true) {
      return visitor.reqVisitDate!;
    }
    return '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}';
  }

  String _getLeaveFromDate() {
    // Use API leave from date if available
    if (visitor.leaveFromDate?.isNotEmpty == true) {
      return visitor.leaveFromDate!;
    }
    return '${visitor.visitDate.day}/${visitor.visitDate.month}/${visitor.visitDate.year}';
  }

  String _getLeaveToDate() {
    // Use API leave to date if available
    if (visitor.leaveToDate?.isNotEmpty == true) {
      return visitor.leaveToDate!;
    }
    DateTime toDate = visitor.visitDate.add(const Duration(days: 7));
    return '${toDate.day}/${toDate.month}/${toDate.year}';
  }

  String _getSpentAddress() {
    // Use API address or visitor address
    if (visitor.address.isNotEmpty) {
      return visitor.address;
    }
    return 'Address not provided';
  }

  String _getReason() {
    // Use API reason if available
    if (visitor.reason?.isNotEmpty == true) {
      return visitor.reason!;
    }
    return 'Family emergency';
  }

  String _getGrievanceCategory() {
    // Use API category if available
    if (visitor.grievanceCategory?.isNotEmpty == true) {
      return visitor.grievanceCategory!;
    }
    final categories = ['Medical', 'Food', 'Legal', 'Family', 'Facilities'];
    return categories[visitor.prisonerName.hashCode % categories.length];
  }

  String _getGrievanceDescription() {
    // Use API grievance description if available
    if (visitor.grievance?.isNotEmpty == true) {
      return visitor.grievance!;
    }
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
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

    switch (sourceType.toLowerCase()) {
      case 'meeting':
        title = _getVisitRegNo();
        break;
      case 'parole':
        title = _getRefNo();
        break;
      case 'grievance':
        title = _getGrievanceRegNo();
        break;
      default:
        title = _getVisitRegNo();
    }

    return Row(
      children: [
        // ✅ FIXED: Removed extra SizedBox that was causing alignment issues
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
          _getRequestedDate(),
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
          padding: const EdgeInsets.all(8),
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
        color: statusColor(visitor.status),
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
