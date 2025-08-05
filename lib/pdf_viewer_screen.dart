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




// Widget? getScreenFromName(String name) {
//   switch (name) {
//     case 'VisitHomeScreen':
//       return VisitHomeScreen(fromChatbot: true);
//     case 'GrievanceHomeScreen':
//       return GrievanceHomeScreen(fromChatbot: true);
//     case 'eVisitorPassScreen':
//       return eVisitorPassScreen(visitor: visitor); // Ensure `visitor` is defined
//     case 'GoogleMapScreen':
//     case 'showGoogleMap':
//       _launchGoogleMap(); // Function that launches the map
//       return null; // Not a screen to navigate, just launch a URL
//     case 'HelpDocScreen':
//       _launchHelpDoc(); // Function that launches help docs
//       return null;
//     case 'ExitApp':
//     case 'exitKaraSahayak':
//       Navigator.pop(context); // You cannot call Navigator.pop directly here unless you're in a build method with access to context
//       return null;
//     default:
//       return null;
//   }
// }
//
// List<Widget> buttons = [];
//
// for (int i = 0; i < keyword.actionToPerform.length; i++) {
//   final screen = getScreenFromName(keyword.actionToPerform);
//
//   if (screen != null) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => screen),
//     ).then((_) {
//       _showReturnMessage();
//     }).catchError((error) {
//       print('❌ Navigation error: $error');
//       _addBotMessage(
//         "Sorry, I couldn't open ${keyword.displayOptions}. Please try again later.",
//         showOptions: true,
//       );
//     });
//   }
// }

