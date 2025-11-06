import 'package:flutter/material.dart';

class StorefrontPage extends StatelessWidget {
  const StorefrontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Storefront coming soon!\nYour extension beyond your home.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
