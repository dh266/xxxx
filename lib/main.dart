import 'package:flutter/material.dart';
import 'screens/node_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Node Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NodeListScreen(),
    );
  }
}
