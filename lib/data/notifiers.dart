import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(4);
ValueNotifier<String> userMode = ValueNotifier("seller");

void setUserMode(String mode) {
  userMode.value = mode;

  // stay on profile page index
  if (mode == "user") {
    selectedPageNotifier.value = 2;
  } else {
    selectedPageNotifier.value = 4;
  }
}
