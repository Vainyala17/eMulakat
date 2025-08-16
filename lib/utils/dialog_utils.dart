import 'package:flutter/material.dart';

class DialogUtils {
  static Future<bool> onWillPop(BuildContext context, {bool showingCards = false}) async {
    if (showingCards) return true;

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Please use Logout and close the App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('OK'),
          ),
        ],
      ),
    ) ?? false;
  }
}
