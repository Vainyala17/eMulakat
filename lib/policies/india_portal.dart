import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/color_scheme.dart';

class IndiaPortalScreen extends StatefulWidget {
  @override
  _IndiaPortalScreenState createState() => _IndiaPortalScreenState();
}

class _IndiaPortalScreenState extends State<IndiaPortalScreen> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.india.gov.in/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('India Portal'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

