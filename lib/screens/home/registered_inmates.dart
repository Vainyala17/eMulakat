import 'package:flutter/material.dart';

import '../../dashboard/grievance/grievance_details_screen.dart';
import '../../dashboard/grievance/grievance_home.dart';
import '../../dashboard/parole/parole_home.dart';
import '../../dashboard/visit/visit_home.dart';
import '../../dashboard/visit/whom_to_meet_screen.dart';

class MyRegisteredInmatesScreen extends StatefulWidget {
  const MyRegisteredInmatesScreen({super.key});

  @override
  State<MyRegisteredInmatesScreen> createState() => _MyRegisteredInmatesScreenState();
}

class _MyRegisteredInmatesScreenState extends State<MyRegisteredInmatesScreen> {
  final List<Map<String, dynamic>> inmates = [
    {
      "serial": 1,
      "prisonerName": "Ashok Kumar",
      "visitorName": "Govind Ram",
      "genderAge": "M/47",
      "relation": "Brother",
      "modeOfVisit": "Yes",
      "prison": "CENTRAL JAIL NO.2, TIHAR", // Fixed: lowercase 'prison'
    },
    {
      "serial": 2,
      "prisonerName": "Anil Kumar",
      "visitorName": "Kewal Singh",
      "genderAge": "M/57",
      "relation": "Lawyer",
      "modeOfVisit": "Yes",
      "prison": "CENTRAL JAIL NO.2, TIHAR", // Fixed: lowercase 'prison'
    },
    {
      "serial": 3,
      "prisonerName": "Test",
      "visitorName": "Rajesh",
      "genderAge": "M/21",
      "relation": "Lawyer",
      "modeOfVisit": "-",
      "prison": "PHQ", // Fixed: lowercase 'prison'
    }
  ];

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
              style: const TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
                            Icon(Icons.person, color: Colors.black,size: 18,), // Prisoner icon
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${inmate['prisonerName']} (#${inmate['serial']})",
                                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis, // Avoid overflow
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.blue),
                        onPressed: () {
                          // TODO: implement download logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Download functionality coming soon')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(Icons.perm_identity, "Father Name: ${inmate['visitorName']}"),
                  _buildInfoRow(Icons.badge, "Gender/Age: ${inmate['genderAge']}"),
                  _buildInfoRow(Icons.family_restroom, "Relation: ${inmate['relation']}"),
                  _buildInfoRow(Icons.meeting_room, "Mode of Visit: ${inmate['modeOfVisit']}"),
                  _buildInfoRow(Icons.location_on, "Prison: ${inmate['prison']}"), // Fixed: lowercase 'prison'
                  const SizedBox(height: 12),
                  // Fixed: Better button layout with proper spacing
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white, // Fixed: Use foregroundColor instead of text color
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            Navigator.push( // Fixed: Use push instead of pushReplacement
                              context,
                              MaterialPageRoute(
                                builder: (context) => MeetFormScreen(
                                  fromRegisteredInmates: true,
                                  prefilledPrisonerName: inmate['prisonerName'],
                                  prefilledPrison: inmate['prison'],
                                ), // Added const
                              ),
                            );
                          },
                          child: const Text("Meeting"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white, // Fixed: Use foregroundColor
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            Navigator.push( // Fixed: Use push instead of pushReplacement
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ParoleHomeScreen(selectedIndex: 2), // Added const
                              ),
                            );
                          },
                          child: const Text("Parole"),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white, // Fixed: Use foregroundColor
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: () {
                            Navigator.push( // Fixed: Use push instead of pushReplacement
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GrievanceDetailsScreen(selectedIndex: 3), // Added const
                              ),
                            );
                          },
                          child: const Text("Grievance"),
                        ),
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