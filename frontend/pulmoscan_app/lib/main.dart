import 'package:flutter/material.dart';
import 'package:pulmoscan_app/screens/login.dart';
import 'package:pulmoscan_app/screens/dashboard.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulmoScan IA',
      theme: ThemeData(
        primaryColor: Color(0xFF0059FF),
        scaffoldBackgroundColor: Color(0xFFF9FAFB),
        fontFamily: 'Inter',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF6B7280)),
        ),
      ),
      home: Builder(
        builder: (context) => LoginPageExact(
          onLogin: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardResponsive()),
            );
          },
        ),
      ),
    );
  }
}