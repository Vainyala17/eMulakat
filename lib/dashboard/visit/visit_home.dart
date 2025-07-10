import 'package:e_mulakat/screens/registration/meet_form_screen.dart';
import 'package:flutter/material.dart';

class VisitScreen extends StatelessWidget {
  const VisitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grievance'),
        centerTitle: true,
        backgroundColor: Color(0xFF5A8BBA),
        foregroundColor: Colors.white,
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
                    MaterialPageRoute(builder: (context) => MeetFormScreen()),
                  );
                },
                child: const Text(
                  'Register Visit',
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
                    MaterialPageRoute(builder: (context) => MeetFormScreen()),
                  );
                },
                child: const Text(
                  'Preview Visit',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
