import 'package:flutter/material.dart';
import 'constants/theme.dart';
import 'screens/join_screen.dart';

void main() {
  runApp(const DiceDaysApp());
}

class DiceDaysApp extends StatelessWidget {
  const DiceDaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dice Days',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const JoinScreen(),
    );
  }
}
