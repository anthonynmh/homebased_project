import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/app_components/app_card.dart';

class StorefrontPromptCard extends StatelessWidget {
  final VoidCallback? onCreate;

  const StorefrontPromptCard({super.key, this.onCreate});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Store Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            const Text("You have not created a storefront yet."),
            const SizedBox(height: 16),
            AppFormButton(
              label: "Create Storefront",
              onPressed: onCreate,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
