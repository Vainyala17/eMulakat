// 🔹 UPDATED my_registered_inmates_screen.dart - Based on actual screenshots
import 'package:flutter/material.dart';
import '../../dashboard/grievance/grievance_details_screen.dart';
import '../../dashboard/parole/parole_screen.dart';
import '../../dashboard/visit/whom_to_meet_screen.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class MyRegisteredInmatesScreen extends StatefulWidget {
  const MyRegisteredInmatesScreen({super.key});

  @override
  State<MyRegisteredInmatesScreen> createState() => _MyRegisteredInmatesScreenState();
}

class _MyRegisteredInmatesScreenState extends State<MyRegisteredInmatesScreen> {
  List<Map<String, dynamic>> inmates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    AuthService.checkAndHandleSession(context);
    _fetchInmates();
  }

  Future<void> _fetchInmates() async {
    try {
      final api = ApiService();
      final response = await api.getMyRegisteredInmates("7702000725");

      setState(() {
        if (response['prisoners'] != null && response['prisoners'] is List) {
          inmates = List<Map<String, dynamic>>.from(response['prisoners']);
        } else {
          inmates = [];
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching inmates: $e");
      setState(() {
        inmates = [];
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching inmates: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton({
    required String title,
    required Color color,
    required bool isEnabled,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color : Colors.grey[300],
          foregroundColor: isEnabled ? Colors.white : Colors.grey[600],
          padding: const EdgeInsets.symmetric(vertical: 8),
          elevation: isEnabled ? 2 : 0,
        ),
        onPressed: isEnabled ? onPressed : null,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (inmates.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No registered inmates found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: inmates.length,
        itemBuilder: (context, index) {
          final inmate = inmates[index];

          // Get flags from API response
          bool canMeeting = inmate['meeting_flag'] ?? false;
          bool canParole = inmate['parole_flag'] ?? false;
          bool canGrievance = inmate['grievance_flag'] ?? false;

          // Get data for display
          Map<String, dynamic>? meetingData = inmate['meeting_data'];
          Map<String, dynamic>? paroleData = inmate['parole_data'];
          Map<String, dynamic>? grievanceData = inmate['grievance_data'];

          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.black, width: 1),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.2),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Prisoner Name and Serial
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.black, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${inmate['prisoner_name'] ?? 'Unknown'} (#${index + 1})",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.blue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Download functionality coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Display meeting data if available
                  if (canMeeting && meetingData != null) ...[
                    _buildInfoRow(Icons.perm_identity, "Father Name: ${meetingData['visitor_name'] ?? inmate['father_name'] ?? 'N/A'}"),
                    _buildInfoRow(Icons.badge, "Gender/Age: ${meetingData['gender_age'] ?? '${inmate['gender']?.substring(0,1) ?? 'M'}/${inmate['age'] ?? 'N/A'}'}"),
                    _buildInfoRow(Icons.family_restroom, "Relation: ${meetingData['relation'] ?? inmate['relation_with_visitor'] ?? 'N/A'}"),
                    _buildInfoRow(Icons.meeting_room, "Mode of Visit: ${meetingData['mode_of_visit'] ?? 'N/A'}"),
                  ],

                  // Display parole data if available
                  if (canParole && paroleData != null) ...[
                    _buildInfoRow(Icons.date_range_outlined, "Parole From: ${paroleData['parole_from'] ?? 'N/A'}"),
                    _buildInfoRow(Icons.date_range, "Parole To: ${paroleData['parole_to'] ?? 'N/A'}"),
                    _buildInfoRow(Icons.explicit_outlined, "Reason: ${paroleData['reason'] ?? 'N/A'}"),
                  ],

                  // Display grievance data if available
                  if (canGrievance && grievanceData != null) ...[
                    _buildInfoRow(Icons.report_problem_outlined, "Category: ${grievanceData['category'] ?? 'N/A'}"),
                  ],

                  // If no specific data available but flags are true, show basic info
                  if (!canMeeting && !canParole && !canGrievance) ...[
                    _buildInfoRow(Icons.perm_identity, "Father Name: ${inmate['father_name'] ?? 'N/A'}"),
                    _buildInfoRow(Icons.badge, "Gender/Age: ${inmate['gender']?.substring(0,1) ?? 'M'}/${inmate['age'] ?? 'N/A'}"),
                    _buildInfoRow(Icons.family_restroom, "Relation: ${inmate['relation_with_visitor'] ?? 'N/A'}"),
                  ],

                  // Always show prison info
                  _buildInfoRow(Icons.location_on, "Prison: ${inmate['prison_name'] ?? 'N/A'}"),

                  // Show profile completion warning if needed
                  if (inmate['complete_profile_flag'] == false)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Profile incomplete - Complete profile to access all services",
                              style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Service buttons - same as your original design
                  Row(
                    children: [
                      _buildServiceButton(
                        title: "Meeting",
                        color: Colors.blue,
                        isEnabled: canMeeting,
                        onPressed: canMeeting ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MeetFormScreen(
                                selectedIndex: 1,
                                fromRegisteredInmates: true,
                                prefilledPrisonerName: inmate['prisoner_name'],
                                prefilledPrison: inmate['prison_name'],
                              ),
                            ),
                          );
                        } : null,
                      ),
                      const SizedBox(width: 8),
                      _buildServiceButton(
                        title: "Parole",
                        color: Colors.green,
                        isEnabled: canParole,
                        onPressed: canParole ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParoleScreen(
                                selectedIndex: 2,
                                fromRegisteredInmates: true,
                                prefilledPrisonerName: inmate['prisoner_name'],
                                prefilledPrison: inmate['prison_name'],
                              ),
                            ),
                          );
                        } : null,
                      ),
                      const SizedBox(width: 8),
                      _buildServiceButton(
                        title: "Grievance",
                        color: Colors.orange,
                        isEnabled: canGrievance,
                        onPressed: canGrievance ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GrievanceDetailsScreen(
                                selectedIndex: 3,
                                fromRegisteredInmates: true,
                                prefilledPrisonerName: inmate['prisoner_name'],
                                prefilledPrison: inmate['prison_name'],
                              ),
                            ),
                          );
                        } : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}