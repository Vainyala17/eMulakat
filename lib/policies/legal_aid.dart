import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../utils/color_scheme.dart';

class LegalAidScreen extends StatefulWidget {
  @override
  _LegalAidScreenState createState() => _LegalAidScreenState();
}

class _LegalAidScreenState extends State<LegalAidScreen> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://eprisons.nic.in/Legalaid/Secure/Login.aspx'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Legal Aid'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

