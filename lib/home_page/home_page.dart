import 'package:flutter/material.dart';
import 'package:homebased_project/login_page/login_page.dart';
import 'package:homebased_project/widgets/confirmation_dialog.dart';
import 'package:homebased_project/backend/auth_api/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  void _logout() async {
    await authService.signOut();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
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
