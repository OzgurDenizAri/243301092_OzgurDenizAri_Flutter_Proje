import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AriYabanciDilApp());
}

class AriYabanciDilApp extends StatelessWidget {
  const AriYabanciDilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arı Yabancı Dil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB300)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
