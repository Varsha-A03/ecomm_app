import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    return GestureDetector(
      onTap: onTap, // Navigate to product detail page
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // for the image and title , price to be in a column
          children: [
            // Product image
            ClipRRect(
                // for rounded contaner
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Image.network(
                    product['image'],
                    height: 80.0,
                    fit: BoxFit.cover,
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
                )),
            // Product title
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 8.0),
              child: Column(
                // for title and price
                crossAxisAlignment: CrossAxisAlignment.start, // align.left
                children: [
                  Text(
                    product['title'],
                    style: const TextStyle(
                      fontFamily: 'rubik',
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2, // Limit title to two lines
                  ),
                  // Product price
                  Text(
                    '\$${product['price'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.yellow.shade600,
                        size: 14.0,
                      ),
                      Text(
                        '${product['rating']['rate']} (${product['rating']['count']} reviews)',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                      ),
                      // Wishlist button
                      IconButton(
                          onPressed: onWishlistToggle,
                          icon: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            color: isWishlisted ? Colors.red : Colors.grey,
                          )),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
