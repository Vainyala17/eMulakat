import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/color_scheme.dart';

class PrisonCitizenServicesScreen extends StatefulWidget {
  @override
  _PrisonCitizenServicesScreenState createState() => _PrisonCitizenServicesScreenState();
}

class _PrisonCitizenServicesScreenState extends State<PrisonCitizenServicesScreen> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://eprisons.nic.in/citizenservice/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prison Citizen Services'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
