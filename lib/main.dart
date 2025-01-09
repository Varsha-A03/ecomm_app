// Entry point for the application
import 'package:ecomm_app/pages/cartpage.dart';
import 'package:ecomm_app/pages/checkoutpage.dart';
import 'package:ecomm_app/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/login_page.dart';
import 'package:provider/provider.dart';
import './providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';

void main() async {
  // Ensure Flutter binding is initialized before running async code
  WidgetsFlutterBinding.ensureInitialized();
  // Check for stored authentication token
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  final isLoggedIn = token != null && token.isNotEmpty;
  // Run the application with providers for state management
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: ECommApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class ECommApp extends StatelessWidget {
  final bool isLoggedIn;
  const ECommApp({super.key, required this.isLoggedIn});

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
      // Navigate to the homepage if logged in, otherwise to the login page
      home: isLoggedIn ? const Homepage() : const LoginPage(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(), // Default route is the login page
        '/homepage': (context) => Homepage(), // Route for the homepage
        '/cartpage': (context) => CartPage(),
        '/checkout': (context) => CheckoutPage(),
      },
    );
  }
}
