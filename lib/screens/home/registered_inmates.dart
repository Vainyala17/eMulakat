import 'package:flutter/material.dart';
import '../../dashboard/grievance/grievance_details_screen.dart';
import '../../dashboard/parole/parole_screen.dart';
import '../../dashboard/visit/whom_to_meet_screen.dart';
import '../../services/api_service.dart';

class MyRegisteredInmatesScreen extends StatefulWidget {
  const MyRegisteredInmatesScreen({super.key});

  @override
  State<MyRegisteredInmatesScreen> createState() => _MyRegisteredInmatesScreenState();
}

class _MyRegisteredInmatesScreenState extends State<MyRegisteredInmatesScreen> {
  final List<Map<String, dynamic>> inmates = [
    // Meeting + Parole + Grievance (All 3 services)
    {
      "serial": 1,
      "prisonerName": "Ashok Kumar",
      "visitorName": "Govind Ram", // For meeting
      "genderAge": "M/47", // For meeting
      "relation": "Brother", // For meeting
      "modeOfVisit": "Yes", // For meeting
      "paroleFrom": "10 Aug 2025", // For parole
      "paroleTo": "20 Aug 2025", // For parole
      "reason": "To maintain family and social ties", // For parole
      "category": "III Treated by the prison authorities", // For grievance
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    // Meeting + Parole only
    {
      "serial": 2,
      "prisonerName": "Anil Kumar",
      "visitorName": "Kewal Singh", // For meeting
      "genderAge": "M/57", // For meeting
      "relation": "Lawyer", // For meeting
      "modeOfVisit": "Yes", // For meeting
      "paroleFrom": "15 Aug 2025", // For parole
      "paroleTo": "25 Aug 2025", // For parole
      "reason": "Other", // For parole
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    // Meeting + Grievance only
    {
      "serial": 3,
      "prisonerName": "Test Kumar",
      "visitorName": "Rajesh Singh", // For meeting
      "genderAge": "M/21", // For meeting
      "relation": "Lawyer", // For meeting
      "modeOfVisit": "No", // For meeting
      "category": "Manhandling by co prisoners", // For grievance
      "prison": "PHQ",
    },
    // Parole + Grievance only
    {
      "serial": 4,
      "prisonerName": "Raj Shekar",
      "paroleFrom": "5 Jul 2025", // For parole
      "paroleTo": "25 Sep 2025", // For parole
      "reason": "To maintain family and social ties", // For parole
      "category": "Basic Facilities not provided inside prison", // For grievance
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    // Meeting only
    {
      "serial": 5,
      "prisonerName": "Ram Kumar",
      "visitorName": "Sita Devi", // For meeting
      "genderAge": "F/45", // For meeting
      "relation": "Wife", // For meeting
      "modeOfVisit": "Yes", // For meeting
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    // Parole only
    {
      "serial": 6,
      "prisonerName": "Prashant Singh",
      "paroleFrom": "18 Nov 2025", // For parole
      "paroleTo": "1 Dec 2025", // For parole
      "reason": "To maintain family and social ties", // For parole
      "prison": "PHQ",
    },
    // Grievance only
    {
      "serial": 7,
      "prisonerName": "Sid Kumar",
      "category": "III Treated by the prison authorities", // For grievance
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    // All 3 services (another example)
    {
      "serial": 8,
      "prisonerName": "Dilip Mhatre",
      "visitorName": "Sunita Mhatre", // For meeting
      "genderAge": "F/40", // For meeting
      "relation": "Wife", // For meeting
      "modeOfVisit": "Yes", // For meeting
      "paroleFrom": "20 Aug 2025", // For parole
      "paroleTo": "30 Aug 2025", // For parole
      "reason": "Other", // For parole
      "category": "Manhandling by co prisoners", // For grievance
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    // Meeting + Parole only
    {
      "serial": 9,
      "prisonerName": "Nirav Rao",
      "visitorName": "Kavita Rao", // For meeting
      "genderAge": "F/35", // For meeting
      "relation": "Sister", // For meeting
      "modeOfVisit": "No", // For meeting
      "paroleFrom": "25 Aug 2025", // For parole
      "paroleTo": "5 Sep 2025", // For parole
      "reason": "To maintain family and social ties", // For parole
      "prison": "PHQ",
    },
    // Parole + Grievance only
    {
      "serial": 10,
      "prisonerName": "Mahesh Patil",
      "paroleFrom": "1 Sep 2025", // For parole
      "paroleTo": "10 Sep 2025", // For parole
      "reason": "Other", // For parole
      "category": "Basic Facilities not provided inside prison", // For grievance
      "prison": "CENTRAL JAIL NO.2, TIHAR",
    },
    // All 3 services
    {
      "serial": 11,
      "prisonerName": "Ramesh Dodhia",
      "visitorName": "Meera Dodhia", // For meeting
      "genderAge": "F/38", // For meeting
      "relation": "Wife", // For meeting
      "modeOfVisit": "Yes", // For meeting
      "paroleFrom": "12 Sep 2025", // For parole
      "paroleTo": "22 Sep 2025", // For parole
      "reason": "To maintain family and social ties", // For parole
      "category": "Manhandling by co prisoners", // For grievance
      "prison": "PHQ",
    }
  ];

  List<Map<String, dynamic>> inmate = [];
  bool isLoading = true; // to show loader while fetching

  @override
  void initState() {
    super.initState();
    _fetchInmates();
  }

  Future<void> _fetchInmates() async {
    try {
      final api = ApiService();
      // Call API with mobile number (here hardcoded, later get from storage/login)
      final response = await api.getMyRegisteredInmates("7702000725");

      // Your JSON structure has `prisoner_details`, so extract properly
      setState(() {
        inmate = [response['prisoner_details']];
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching inmates: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  // Check if inmate has meeting data
  bool hasMeetingData(Map<String, dynamic> inmate) {
    return inmate.containsKey('visitorName') &&
        inmate.containsKey('genderAge') &&
        inmate.containsKey('relation') &&
        inmate.containsKey('modeOfVisit');
  }

  // Check if inmate has parole data
  bool hasParoleData(Map<String, dynamic> inmate) {
    return inmate.containsKey('paroleFrom') &&
        inmate.containsKey('paroleTo') &&
        inmate.containsKey('reason');
  }

  // Check if inmate has grievance data
  bool hasGrievanceData(Map<String, dynamic> inmate) {
    return inmate.containsKey('category');
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: inmates.length,
        itemBuilder: (context, index) {
          final inmate = inmates[index];

          // Check which services are available
          bool canMeeting = hasMeetingData(inmate);
          bool canParole = hasParoleData(inmate);
          bool canGrievance = hasGrievanceData(inmate);

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
                  // Header with Serial No. and Prisoner Name
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
                                "${inmate['prisonerName']} (#${inmate['serial']})",
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

                  // Dynamic data display based on available services
                  // Meeting data
                  if (canMeeting) ...[
                    _buildInfoRow(Icons.perm_identity, "Father Name: ${inmate['visitorName']}"),
                    _buildInfoRow(Icons.badge, "Gender/Age: ${inmate['genderAge']}"),
                    _buildInfoRow(Icons.family_restroom, "Relation: ${inmate['relation']}"),
                    _buildInfoRow(Icons.meeting_room, "Mode of Visit: ${inmate['modeOfVisit']}"),
                  ],

                  // Parole data
                  if (canParole) ...[
                    _buildInfoRow(Icons.date_range_outlined, "Parole From: ${inmate['paroleFrom']}"),
                    _buildInfoRow(Icons.date_range, "Parole To: ${inmate['paroleTo']}"),
                    _buildInfoRow(Icons.explicit_outlined, "Reason: ${inmate['reason']}"),
                  ],

                  // Grievance data
                  if (canGrievance) ...[
                    _buildInfoRow(Icons.report_problem_outlined, "Category: ${inmate['category']}"),
                  ],

                  // Prison (always show)
                  _buildInfoRow(Icons.location_on, "Prison: ${inmate['prison']}"),

                  const SizedBox(height: 12),

                  // Service buttons - all visible but only enabled if data exists
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
                                prefilledPrisonerName: inmate['prisonerName'],
                                prefilledPrison: inmate['prison'],
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
                                prefilledPrisonerName: inmate['prisonerName'],
                                prefilledPrison: inmate['prison'],
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
                                prefilledPrisonerName: inmate['prisonerName'],
                                prefilledPrison: inmate['prison'],
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