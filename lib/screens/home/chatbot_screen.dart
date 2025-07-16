import 'package:flutter/material.dart';

class ChatbotScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Chatbot"),
        backgroundColor: Color(0xFF5A8BBA),
      ),
      body: Center(
        child: Text(
          "How can I help you today?",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
