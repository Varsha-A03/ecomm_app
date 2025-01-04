import 'package:ecomm_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controllers to get user input
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    final String userName = _userNameController.text;
    final String password = _passwordController.text;

    // Check for empty fields
    if (userName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Call the login function from ApiService
      final token = await _apiService.loginUser(userName, password);
      print("Login successful, token: $token");
      // Save the token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      // show success dialog
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Login Successful'),
                icon: Icon(
                  Icons.verified_rounded,
                  color: Colors.lightGreen,
                  size: 20.0,
                ),
                content: const Text('You have been logged in successfully!'),
                actions: [
                  TextButton(
                      onPressed: () => {
                            Navigator.pop(context),
                            // Navigate to the homepage or show success
                            Navigator.pushReplacementNamed(
                                context, '/homepage'),
                          },
                      child: const Text('OK')),
                ],
              ));
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
      print(_errorMessage);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Login Failed!'),
                icon: Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 20.0,
                ),
                content: Text(_errorMessage!),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK')),
                ],
              ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.brown.shade600,
      ),
      body: SingleChildScrollView(
        // Allow scrolling if content overflows
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Image(
                image: AssetImage('assets/images/loginimage.jpg'),
              ),
            ),
            SizedBox(
              height: 24.0,
            ),
            Text(
              'Welcome Back!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'Please enter your login credentials.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 10.0,
                    )),
                fillColor: Color(0xFFF6ECE3),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                    width: 2.0,
                  ),
                ),
                fillColor: Color(0xFFF6ECE3),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _login,
              // ignore: sort_child_properties_last
              child: Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shadowColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
