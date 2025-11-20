import 'package:customer_appointment_system/screen/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:customer_appointment_system/widget/color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      home: const HomeScreen(),
    );
  }
}
