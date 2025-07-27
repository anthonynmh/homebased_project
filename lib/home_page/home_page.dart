import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homebased_project/providers/auth_state.dart';
import 'package:homebased_project/landing_page/landing_page.dart';
import 'package:homebased_project/widgets/confirmation_dialog.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  void _logout() async {
    final authState = Provider.of<AuthState>(context, listen: false);

    try {
      await authState.auth0?.webAuthentication().logout(
        useHTTPS: false,
      ); // TODO: set to true for deployment
    } catch (e) {
      print('Logout error: $e');
    }

    authState.clear();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
    );
  }

  void _showLogoutDialog() async {
    final confirmed = await showLogoutConfirmation(
      context,
      'Are you sure you want to log out?',
    );
    if (confirmed) _logout();
  }

  @override
  Widget build(BuildContext context) {
    // final credentials = Provider.of<AuthState>(context).credentials;

    Widget page;

    switch (_selectedIndex) {
      case 0:
        page = const Center(child: Placeholder(fallbackHeight: 200));
        break;
      case 1:
        page = const Center(child: Placeholder(fallbackHeight: 200));
        break;
      case 2:
        page = const Center(child: Placeholder(fallbackHeight: 200));
        break;
      default:
        throw UnimplementedError('No page for index $_selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('homebased App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
    );
  }
}
