import 'package:flutter/material.dart';

class ActivityFeedPage extends StatelessWidget {
  const ActivityFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Activity feed coming soon!\nA better way for sellers manage their community.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
