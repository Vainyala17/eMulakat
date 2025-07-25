import 'package:flutter/material.dart';
import '../../dashboard/visit/visit_preview1.dart';
import '../../models/visitor_model.dart';
import '../../utils/color_scheme.dart';

class VisitDetailView extends StatefulWidget {
  final VisitorModel selectedVisitor;
  final List<VisitorModel> pastVisits;
  final List<VisitorModel> upcomingVisits;
  final Function(VisitorModel) onVisitorSelected;

  const VisitDetailView({
    Key? key,
    required this.selectedVisitor,
    required this.pastVisits,
    required this.upcomingVisits,
    required this.onVisitorSelected,
  }) : super(key: key);

  @override
  _VisitDetailViewState createState() => _VisitDetailViewState();
}

class _VisitDetailViewState extends State<VisitDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showPastVisits = true;
  VisitorModel? selectedVisitor;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        showPastVisits = _tabController.index == 0;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      case VisitStatus.approved:
        return Colors.green;
      case VisitStatus.rejected:
        return Colors.red;
      case VisitStatus.pending:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String getStatusText(VisitStatus status) {
    switch (status) {
      case VisitStatus.approved:
        return 'Approved';
      case VisitStatus.rejected:
        return 'Rejected';
      case VisitStatus.pending:
        return 'Pending';
    }
  }

  Widget _buildDetailedVisitCard(VisitorModel visitor) {
    bool isSelected = widget.selectedVisitor == visitor;

    return GestureDetector(
      onTap: () {
        widget.onVisitorSelected(visitor);
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
            color: isSelected ? AppColors.primary : Colors.grey.shade600, // 👈 change color based on selection
            width: isSelected ? 2.0 : 1.0, // 👈 slightly thicker when selected
          ),
        ),
        child: Row(
          children: [
            // Left blue date block (exactly like the image)
            Container(
              width: 110,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFF4A90E2), // Blue color from image
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getDayOfWeek(visitor.visitDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    visitor.visitDate.day.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    getMonthName(visitor.visitDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Right content area (white background like the image)
            Expanded(
              child: Container(
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Visit details column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Color(0xFF4A90E2),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child :Text(
                                  '${visitor.startTime} - ${visitor.endTime}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Visitor name
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  visitor.visitorName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Prison/Jail name
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  visitor.jail,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Additional visitors info
                          Row(
                            children: [
                              const Icon(
                                Icons.group,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                visitor.additionalVisitors > 0
                                    ? '${visitor.additionalVisitors} additional participants'
                                    : 'No additional participants',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge and arrow (like in the image)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Status badge with extra top padding to move it slightly upwards
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0), // 👈 move it up
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor(visitor.status),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              getStatusText(visitor.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Arrow icon
                        Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: isSelected ? 35: 30,
                              color: isSelected ? AppColors.primary : Colors.grey.shade600,
                              fontWeight: isSelected ? FontWeight.bold: FontWeight.normal,// ✅ dynamic color
                            ),
                            onPressed: isSelected
                                ? () {
                              setState(() {
                                selectedVisitor = visitor; // ✅ Set selected visitor
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VisitPreviewScreen1(),
                                ),
                              );
                            }
                                : null, // 👈 disable press when not selected
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8),
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.all_inclusive, size: 20),
                    const SizedBox(width: 8),
                    Text('Past Visits (${widget.pastVisits.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upcoming, size: 20),
                    const SizedBox(width: 8),
                    Text('Upcoming (${widget.upcomingVisits.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Tab Bar View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Past Visits Tab
              ListView.builder(
                itemCount: widget.pastVisits.length,
                itemBuilder: (context, index) {
                  return _buildDetailedVisitCard(widget.pastVisits[index]);
                },
              ),
              // Upcoming Visits Tab
              ListView.builder(
                itemCount: widget.upcomingVisits.length,
                itemBuilder: (context, index) {
                  return _buildDetailedVisitCard(widget.upcomingVisits[index]);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}