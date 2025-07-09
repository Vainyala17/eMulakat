import 'package:flutter/material.dart';
import '../../utils/color_scheme.dart';

class ContactUsPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Contact Us',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For support and queries:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text('National Informatics Centre \n A-Block, CGO Complex, Lodhi Road \n New Delhi - 110 003 India'),
          SizedBox(height: 4),
          Text('🌐 Website: eprisons.nic.in'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'OK',
            style: TextStyle(color: Theme.of(context).primaryColor,),
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ContactUsPopup(),
    );
  }
}