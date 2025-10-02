import 'package:flutter/material.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';
import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/login_page/login_page.dart';
import 'package:homebased_project/views/pages/explore_page.dart';
import 'package:homebased_project/views/pages/profile_page.dart';
import 'package:homebased_project/widgets/navbar_widget.dart';

List<Widget> pages = [ExplorePage(), ProfilePage()];

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
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Knock Knock'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, value, child) {
          return pages.elementAt(value);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
