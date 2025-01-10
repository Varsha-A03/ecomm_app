import 'package:flutter/material.dart';

/// ProductCard
/// A reusable widget to display product details such as image, title, price, and wishlist toggle.
/// It also supports an onTap action to navigate to the product detail page.
class Productcard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onTap;
  final VoidCallback onWishlistToggle;
  final bool isWishlisted;

  const Productcard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onWishlistToggle,
    required this.isWishlisted,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    return GestureDetector(
      onTap: onTap, // Navigate to product detail page
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          children: [
            // Main content of the card
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.network(
                      product['image'],
                      height:
                          isDesktop ? screenWidth * 0.15 : screenWidth * 0.20,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ),
                // Product title, price, and rating
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product title
                      Text(
                        product['title'],
                        style: TextStyle(
                          fontFamily: 'rubik',
                          fontSize: isDesktop ? 18.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Product price
                      Text(
                        '\$${product['price'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: isDesktop ? 16.0 : 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Product rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.yellow.shade600,
                            size: 14.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            '${product['rating']['rate']}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            '(${product['rating']['count']} reviews)',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Wishlist button at the top-right corner
            Positioned(
              top: 3.0,
              right: 3.0,
              child: IconButton(
                onPressed: onWishlistToggle,
                icon: Icon(
                  isWishlisted
                      ? Icons.favorite
                      : Icons.favorite_border_outlined,
                  color: isWishlisted ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
