import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;
  final bool scrollable;

  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFFE8E0F8), Color(0xFFC8E8F8), Color(0xFFFFFFFF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
      child: child,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          decoration: const BoxDecoration(gradient: gradient),
          child: SafeArea(
            child: scrollable
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [content],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [content],
                  ),
          ),
        ),
      ),
    );
  }
}
