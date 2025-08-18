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
