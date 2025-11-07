import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/widgets/navbar_widget.dart';

// MVP2
import 'package:homebased_project/mvp2/auth_page.dart';
import 'package:homebased_project/mvp2/views/activity_feed/activity_feed_page.dart';
import 'package:homebased_project/mvp2/views/storefront/storefront_page.dart';
import 'package:homebased_project/mvp2/views/menu/menu_page.dart';
import 'package:homebased_project/mvp2/views/orders/orders_page.dart';
import 'package:homebased_project/mvp2/views/profile/profile_page.dart';

List<Widget> sellerPages = [
  ActivityFeedPage(),
  StorefrontPage(),
  MenuPage(),
  OrdersPage(),
  ProfilePage(),
];

List<Widget> defaultUserPages = [Placeholder(), Placeholder(), ProfilePage()];

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  void _logout() async {
    await authService.signOut();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Stay Updated!'),
                    content: RichText(
                      text: TextSpan(
                        text: 'Join this Telegram channel: ',
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'https://t.me/food_n_friends',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = Uri.parse(
                                  'https://t.me/food_n_friends',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  // Handle unable to launch
                                  debugPrint('Could not launch $url');
                                }
                              },
                          ),
                          const TextSpan(
                            text:
                                ' to stay up to date with the latest developments.',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.campaign, color: Colors.black),
            label: const Text(
              'Stay Updated',
              style: TextStyle(color: Colors.black),
            ),
          ),

          const VerticalDivider(color: Colors.black, thickness: 1, width: 20),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(58, 244, 67, 54),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.black),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, value, child) {
          return sellerPages.elementAt(value);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
