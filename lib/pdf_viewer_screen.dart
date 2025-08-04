import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerScreen extends StatelessWidget {
  final String assetPath;

  PDFViewerScreen({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        backgroundColor: Color(0xFF3A6895),
      ),
      body: SfPdfViewer.asset(assetPath),
    );
  }
}




// ADDED: Fallback keywords in case API and cache both fail
// static List<KeywordModel> _getFallbackKeywords() {
//    return [
//      KeywordModel(
//        displayOptions: "Register a Visitor",
//        keywordsGlossary: ["visitor", "register visitor", "new visitor", "add visitor", "visitor registration"],
//        actionToPerform: "Launch the Visitor's Registration Form and fill up the form using Speech to Text feature",
//        appMethodToCall: "VisitHomeScreen",
//      ),
//      KeywordModel(
//        displayOptions: "Register a Grievance",
//        keywordsGlossary: ["grievance", "complaint", "register grievance", "file complaint", "grievance registration"],
//        actionToPerform: "Launch the Grievance Registration Form and fill up the form using Speech to Text feature",
//        appMethodToCall: "GrievanceHomeScreen",
//      ),
//      KeywordModel(
//        displayOptions: "Show the latest eGatepass",
//        keywordsGlossary: ["eGatepass", "gatepass", "getpass", "gate pass", "get pass", "show gatepass", "latest gatepass", "visitor pass", "entry pass"],
//        actionToPerform: "Display the latest generated eGatepass for the visitor",
//        appMethodToCall: "eVisitorPassScreen",
//      ),
//      KeywordModel(
//        displayOptions: "Show Prison to visit on Google Map",
//        keywordsGlossary: ["map", "google map", "location", "prison location", "directions", "navigate", "route", "address"],
//        actionToPerform: "Read the Google Map coordinates of the Prison to be visited and launch the Google Map",
//        appMethodToCall: "GoogleMapScreen",
//      ),
//      KeywordModel(
//        displayOptions: "Exit KaraSahayak",
//        keywordsGlossary: ["exit", "close", "stop", "bye", "exit karasahayak", "close chatbot", "quit", "leave"],
//        actionToPerform: "Exit the KaraSahayak and redirect to Dashboard UI",
//        appMethodToCall: "ExitApp",
//      ),
//    ];
//  }

// Enhanced method to validate API response structure