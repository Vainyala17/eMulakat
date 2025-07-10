import 'package:flutter/material.dart';

import 'complaint_screen.dart';

class GrievanceHomeScreen extends StatelessWidget {
  const GrievanceHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grievance'),
        centerTitle: true,
        backgroundColor: Color(0xFF5A8BBA),
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5A8BBA),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ComplaintScreen()),
                  );
                },
                child: const Text(
                  'Register Grievance',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5A8BBA),
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ComplaintScreen()),
                  );
                },
                child: const Text(
                  'Preview Grievance',
                  style: TextStyle(fontSize: 16,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
