

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/home/home_screen.dart';


void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16),
            Text(
              "Success",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Your visit has been successfully scheduled!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text(
                "OK",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showReadOnlyAlert(BuildContext context, String fieldName) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: Colors.orange, size: 60),
            SizedBox(height: 16),
            Text(
              "Field Locked",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Can't edit $fieldName field. This information is pre-filled and cannot be modified.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5A8BBA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget buildReadOnlyTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required String hint,
  String? Function(String?)? validator,
  bool readOnly = false,
  int maxLines = 1,
  String? fieldName,
  bool isRequired = false,
}) {
  return GestureDetector(
    onTap: readOnly ? () => _showReadOnlyAlert(context, fieldName ?? label) : null,
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label*' : label,
        hintText: hint,
        border: OutlineInputBorder(),
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
        filled: true,
        suffixIcon: readOnly ? Icon(Icons.lock_outline, color: Colors.grey) : null,
      ),
      style: TextStyle(
        color: readOnly ? Colors.grey[600] : Colors.black,
      ),
      validator: validator,
      readOnly: readOnly,
      maxLines: maxLines,
      inputFormatters: readOnly ? [] : [
        TextInputFormatter.withFunction((oldValue, newValue) {
          String text = newValue.text;
          if (text.isNotEmpty) {
            text = text.split(' ').map((word) {
              if (word.isNotEmpty) {
                return word[0].toUpperCase() + word.substring(1).toLowerCase();
              }
              return word;
            }).join(' ');
          }
          return TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        }),
      ],
    ),
  );
}