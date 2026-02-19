import 'package:flutter/material.dart';

class FunctionUtil {
  static void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  static void showErrorSnackBar(BuildContext context) {
    showSnackBar(context, 'Something went wrong!', Colors.red);
  }
}
