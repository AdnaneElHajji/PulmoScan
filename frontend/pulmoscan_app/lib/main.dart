import 'package:flutter/material.dart';
import 'package:pulmoscan_app/screens/login.dart';
import 'package:pulmoscan_app/screens/dashboard.dart';
import 'package:pulmoscan_app/theme/v4_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulmoScan IA',
      debugShowCheckedModeBanner: false,
      theme: V4.theme(),
      home: Builder(
        builder: (context) => LoginPageExact(
          onLogin: (ctx) {
            Navigator.pushReplacement(
              ctx,
              MaterialPageRoute(builder: (_) => DashboardResponsive()),
            );
          },
        ),
      ),
    );
  }
}
