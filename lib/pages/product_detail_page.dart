import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/cart_item.dart';
import '../providers/cart_provider.dart';

/// ProductDetailPage
/// Displays detailed information about a product, including images, description,
/// price, reviews, and options to add to the cart or wishlist.
class ProductDetailPage extends StatelessWidget {
  final dynamic product;
  const ProductDetailPage({super.key, required this.product});

  /// Generates a set of sample reviews based on the product's rating and count.
  List<String> _generateReviews(double rating, int count) {
    // Simulated reviews
    const List<String> reviewTemplates = [
      "This product exceeded my expectations!",
      "Good quality and value for the price.",
      "Very reliable, I use it daily.",
      "Highly recommend to anyone considering this.",
      "Not bad, but could be better.",
      "Absolutely fantastic! 5 stars!",
      "Great product for its price.",
      "I’m satisfied with the purchase.",
      "Quality is top-notch.",
      "It does what it says, very pleased."
    ];

    // Randomly pick reviews based on the rating
    List<String> reviews = [];
    for (int i = 0; i < 5 && i < count; i++) {
      reviews
          .add(reviewTemplates[(i + rating.toInt()) % reviewTemplates.length]);
    }
    return reviews;
  }

  @override
  Widget build(BuildContext context) {
    final double rating = product['rating']['rate'];
    final int reviewCount = product['rating']['count'];
    final List<String> reviews = _generateReviews(rating, reviewCount);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown.shade600,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Stack(children: [
        // Scrollable content
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.network(
                    product['image'],
                    height: 250.0,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, StackTrace) =>
                        Icon(Icons.error),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                // Product title
                Text(
                  product['title'],
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 8.0),
                // Product price
                Text(
                  '\$${product['price'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8.0),
                // Product description
                Text(
                  product['description'],
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 3.0),
                // Product rating
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.yellow.shade600,
                      size: 15.0,
                    ),
                    Text(
                      '${product['rating']['rate']} (${product['rating']['count']} reviews)',
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                // Reviews section
                const Text(
                  "Reviews:",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 8.0),
                reviews.isEmpty
                    ? const Text(
                        "No reviews available.",
                        style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.person, color: Colors.brown),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    reviews[index],
                                    style: const TextStyle(
                                        fontSize: 16.0, color: Colors.black54),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                SizedBox(
                  height: 50.0,
                ),
              ],
            ),
          ),
        ),

        // fixed buttons at bottom
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Add to Wishlist button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final cartProvider =
                            Provider.of<CartProvider>(context, listen: false);
                        cartProvider.addToCart(
                          CartItem(
                              id: product['id'],
                              title: product['title'],
                              price: (product['price']
                                      is int) // Check if the price is an int
                                  ? product['price']
                                      .toDouble() // Convert to double
                                  : product[
                                      'price'], // Use as is if already a double
                              image: product['image']),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Added to cart: ${product['title']}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),

                  // view cart button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cartpage');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade600,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      child: const Text(
                        'View Cart',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ))
      ]),
    );
  }
}
