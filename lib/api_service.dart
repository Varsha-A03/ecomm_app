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
}
