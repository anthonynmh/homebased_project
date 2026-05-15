import 'package:flutter/material.dart';

import 'package:homebased_project/v2/screens/v2_home_shell.dart';

class V2App extends StatelessWidget {
  const V2App({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFC46A35);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Communitii V2',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF7F1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF7F1),
          foregroundColor: Color(0xFF17201D),
          elevation: 0,
          centerTitle: false,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFFFEFE2),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected
                  ? const Color(0xFFC46A35)
                  : const Color(0xFF647067),
              size: 23,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected
                  ? const Color(0xFFC46A35)
                  : const Color(0xFF647067),
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              fontSize: 12,
            );
          }),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: const Color(0xFFFFEFE2),
          side: const BorderSide(color: Color(0xFFE5DED4)),
          labelStyle: const TextStyle(
            color: Color(0xFF39433E),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: const V2HomeShell(),
    );
  }
}
