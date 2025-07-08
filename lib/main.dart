import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(const SpeedforceApp());
}

class SpeedforceApp extends StatelessWidget {
  const SpeedforceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Help Assistant',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF13103F), // Your brand color
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF13103F),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
