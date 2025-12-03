import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  /// Shows a SnackBar with optional error styling
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : Theme.of(this).snackBarTheme.backgroundColor ?? Colors.grey[800],
      ),
    );
  }
}
