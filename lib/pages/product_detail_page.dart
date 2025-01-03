import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final dynamic product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color(0xFFB7A7A9),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  product['image'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            product['title'],
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '\$${product['price']}',
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            product['description'],
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 50.0),
          Text(
            'Reviews (Coming Soon...)',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}
