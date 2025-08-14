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
      default:
        return Colors.grey;
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
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VisitPreviewScreen1()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Left blue date block
            _buildDateBlock(),

            // Right content area
            Expanded(
              child: Container(
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: _buildDetails()),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStatusBadge(),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            if (sourceType == "meeting") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MeetFormScreen(
                                    fromRegisteredInmates: true,
                                    prefilledPrisonerName: inmate?['prisonerName'],
                                    prefilledPrison: inmate?['Prison'],
                                  ),
                                ),
                              );
                            } else if (sourceType == "parole") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ParoleScreen(selectedIndex: 2),
                                ),
                              );
                            } else if (sourceType == "grievance") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GrievanceDetailsScreen(selectedIndex: 3),
                                ),
                              );
                            }
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 24,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBlock() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFF4A90E2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(getDayOfWeek(visitor.visitDate),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(visitor.visitDate.day.toString().padLeft(2, '0'),
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          Text(getMonthName(visitor.visitDate),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(visitor.visitDate.year.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF4A90E2), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text('${visitor.startTime} - ${visitor.endTime}',
                  style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.person, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(visitor.visitorName,
                  style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.location_on, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(visitor.jail,
                  style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.group, size: 18, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                visitor.additionalVisitors > 0
                    ? '${visitor.additionalVisitors} additional participants'
                    : 'No additional participants',
                style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor(visitor.status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        getStatusText(visitor.status),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}