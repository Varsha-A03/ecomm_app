import 'package:flutter/material.dart';

class Productcard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onTap;

  const Productcard({required this.product, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // for the image and title , price to be in a column
          children: [
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
            const SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                // for title and price
                crossAxisAlignment: CrossAxisAlignment.start, // align.left
                children: [
                  Text(product['title'],
                      style: const TextStyle(
                        fontFamily: 'rubik',
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                      )),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    '\$${product['price'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.yellow.shade600,
                        size: 14.0,
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        '${product['rating']['rate']} (${product['rating']['count']} reviews)',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
