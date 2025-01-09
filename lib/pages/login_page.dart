import '../utils/api_service.dart';
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
  bool _obscureText = true;
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
                      Navigator.pushReplacementNamed(context, '/homepage'),
                    },
                    child: const Text('OK'),
                  ),
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
        body: Stack(
      children: [
        // background image
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.png', // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        // Centered Card with login fields
        Center(
          child: Card(
            color: Color(0xFFF6ECE3),
            elevation: 10.0,
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Please enter your credentials',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            )),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                    obscureText: _obscureText,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade600,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ));
  }
}
