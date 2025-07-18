import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrisonMapScreen extends StatelessWidget {
  final Uri _mapUrl = Uri.parse(
    "https://www.google.com/maps/place/NutanTek+Solutions+LLP/@19.7251636,60.9691764,4z/data=!3m1!4b1!4m6!3m5!1s0x390ce5db65f6af0f:0xb29ad5bc8aabd76a!8m2!3d21.0680074!4d82.7525294!16s%2Fg%2F11k6fbjb7n?authuser=0&entry=ttu",
  );

  Future<void> _launchMap() async {
    if (await canLaunchUrl(_mapUrl)) {
      await launchUrl(_mapUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $_mapUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Prison Map")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _launchMap,
          icon: Icon(Icons.map),
          label: Text("Open Google Map"),
        ),
      ),
    );
  }
}
