import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<String> userMode = ValueNotifier("seller");

void setUserMode(String mode) {
  userMode.value = mode;
}
