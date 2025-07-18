import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/color_scheme.dart';

class PrisonMapScreen extends StatefulWidget {
  @override
  _PrisonMapScreenState createState() => _PrisonMapScreenState();
}

class _PrisonMapScreenState extends State<PrisonMapScreen> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://eprisons.nic.in/NPIPDashboard/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prison Map'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

