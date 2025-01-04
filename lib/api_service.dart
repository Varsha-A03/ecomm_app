import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<List<dynamic>> fetchAllProducts() async {
    final response =
        await http.get(Uri.parse('https://fakestoreapi.com/products'));

    if (response.statusCode == 200) {
      print("Fetched products: ${json.decode(response.body)}");
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception("Failed to load products");
    }
  }

  Future<String> loginUser(String email, String password) async {
    final Uri url = Uri.parse('https://fakestoreapi.com/auth/login');

    // Print the payload for debugging
    print("Sending payload: ${jsonEncode({
          'username': email,
          'password': password
        })}");

    // Send POST request with username and password
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': email, 'password': password}),
    );

    // Print the response body for debugging
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Token received: ${data['token']}");
      return data['token'];
    } else {
      throw Exception("Invalid credentials or server error");
    }
  }
}
