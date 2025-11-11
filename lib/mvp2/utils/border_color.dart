import 'package:flutter/material.dart';

// utils
import 'package:homebased_project/mvp2/utils/field_status.dart';

Color getBorderColor(FieldStatus status) {
  switch (status) {
    case FieldStatus.success:
      return Colors.green;
    case FieldStatus.error:
      return Colors.red;
    default:
      return Colors.blue.shade200;
  }
}
