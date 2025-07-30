import 'package:flutter/material.dart';
import 'package:homebased_project/data/notifiers.dart';
import 'package:homebased_project/views/pages/explore_page.dart';
import 'package:homebased_project/views/pages/profile_page.dart';
import 'package:homebased_project/widgets/navbar_widget.dart';

List<Widget> pages = [ExplorePage(), ProfilePage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Knock Knock'), centerTitle: true),
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
