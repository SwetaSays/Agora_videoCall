import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1200), _go);
  }

  void _go() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.videocam, size: 80, color: Colors.deepPurple),
          SizedBox(height: 12),
          Text('Flutter Video App', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
