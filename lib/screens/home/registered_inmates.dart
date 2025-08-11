import 'package:flutter/material.dart';

import '../../dashboard/grievance/grievance_home.dart';
import '../../dashboard/parole/parole_home.dart';
import '../../dashboard/visit/visit_home.dart';

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
      "jailAddress": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 2,
      "prisonerName": "Anil Kumar",
      "visitorName": "Kewal Singh",
      "genderAge": "M/57",
      "relation": "Lawyer",
      "modeOfVisit": "Yes",
      "jailAddress": "CENTRAL JAIL NO.2, TIHAR",
    },
    {
      "serial": 3,
      "prisonerName": "Test",
      "visitorName": "",
      "genderAge": "M/21",
      "relation": "Lawyer",
      "modeOfVisit": "-",
      "jailAddress": "PHQ",
    }
  ];


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: inmates.length,
      itemBuilder: (context, index) {
        final inmate = inmates[index];
        return Card(
          color: Colors.white, // ✅ White background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.grey, width: 1), // ✅ Grey border
          ),
          elevation: 4, // ✅ Shadow
          shadowColor: Colors.black.withOpacity(0.2), // ✅ Soft shadow
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
                    Text(
                      "${inmate['serial']}. ${inmate['prisonerName']}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.blue),
                      onPressed: () {
                        // TODO: implement download logic
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text("Visitor: ${inmate['visitorName']}"),
                Text("Gender/Age: ${inmate['genderAge']}"),
                Text("Relation: ${inmate['relation']}"),
                Text("Mode of Visit: ${inmate['modeOfVisit']}"),
                Text("Jail Address: ${inmate['jailAddress']}"),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => VisitHomeScreen(selectedIndex: 1)),
                        );
                      },
                      child: const Text(
                        "Meeting",
                        style: TextStyle(color: Colors.black), // ✅ Correct way
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ParoleHomeScreen(selectedIndex: 2)),
                        );
                      },
                      child: const Text("Parole",style: TextStyle(color: Colors.black), // ✅ Correct way
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => GrievanceHomeScreen(selectedIndex: 3)),
                        );
                      },
                      child: const Text("Grievance",style: TextStyle(color: Colors.black), // ✅ Correct way
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}