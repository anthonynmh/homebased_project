import 'package:flutter/material.dart';

import 'package:homebased_project/mvp2/app_components/app_form_button.dart';
import 'package:homebased_project/mvp2/profile/profile_components/profile_option_tile.dart';

class ProfileActionsSection extends StatelessWidget {
  final VoidCallback onSwitchMode;
  final VoidCallback openTelegram;
  final VoidCallback onLogout;

  const ProfileActionsSection({
    super.key,
    required this.onSwitchMode,
    required this.openTelegram,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFormButton(
          label: "Switch Profile Mode",
          onPressed: () {
            onSwitchMode();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.sync),
        ),

        const Divider(height: 32),

        ProfileOptionTile(
          icon: Icons.campaign,
          iconColor: Colors.blue,
          title: 'Stay Updated',
          subtitle: 'Join our Telegram channel',
          onTap: openTelegram,
        ),

        const Divider(),

        ProfileOptionTile(
          icon: Icons.logout,
          iconColor: Colors.red,
          title: 'Logout',
          subtitle: '',
          onTap: () {
            Navigator.pop(context);
            onLogout();
          },
        ),
      ],
    );
  }
}
