import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<String> userMode = ValueNotifier("User");

void setUserMode(String mode) {
  userMode.value = mode;
}
