import 'package:flutter/material.dart';
import 'node_list_screen.dart';
import 'control_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(
                icon: Icon(Icons.sensors),
                text: 'Nodes',
              ),
              Tab(
                icon: Icon(Icons.control_camera),
                text: 'Controls',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NodeListScreen(),
            ControlScreen(),
          ],
        ),
      ),
    );
  }
} 