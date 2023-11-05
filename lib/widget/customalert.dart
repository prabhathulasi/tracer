import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onPressed;

  CustomAlertDialog(
      {required this.title, required this.message, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: onPressed,
          child: Text("OK"),
        ),
      ],
    );
  }
}
