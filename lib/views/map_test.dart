import 'package:flutter/material.dart';

// Replace with the page you want to test
import 'map_view.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(), // <— Change this to whatever page you're testing
    ),
  );
}
