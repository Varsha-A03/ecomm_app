import 'package:ecomm_app/pages/homepage.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(ECommApp());
}

class ECommApp extends StatelessWidget {
  const ECommApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-commerce App',
      theme: ThemeData(
        primaryColor: Color(0xFF000000), // Black
        hintColor: Color(0xFF91766E), // Brown
        scaffoldBackgroundColor: Color(0xFFF6ECE3), // Beige
        appBarTheme: AppBarTheme(
          color: Color(0xFF000000), // Black AppBar
          titleTextStyle: TextStyle(color: Colors.white),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF000000)), // Black text
          bodyMedium: TextStyle(color: Color(0xFFB7A7A9)), // Granite text
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF91766E), // Brown bottom nav bar
        ),
      ),
      home: Homepage(), // Set the homepage as the starting screen
    );
  }
}
