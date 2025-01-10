import 'package:flutter/material.dart';

/// WishlistPage
/// Displays a list of products that the user has added to their wishlist.
/// Users can view or remove items from the wishlist.
class WishlistPage extends StatelessWidget {
  final List<dynamic> wishlist;
  const WishlistPage({super.key, required this.wishlist});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;
    final isDesktop = screenWidth > 1024;
    return Scaffold(
        appBar: AppBar(
          title: Text('Wishlist',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.brown.shade600,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        body: wishlist.isEmpty
            ? Center(
                child: Text(
                  "Your wishlist is empty.",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              )
            : GridView.builder(
                padding: EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop
                      ? 6
                      : isTablet
                          ? 3
                          : 2,
                  mainAxisSpacing: 2.0,
                  crossAxisSpacing: 2.0,
                ),
                itemCount: wishlist.length,
                itemBuilder: (context, index) {
                  final product = wishlist[index];
                  return Card(
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Center(
                          child: Image.network(
                            product['image'],
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                        )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product['title'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '\$${product['price'].toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ));
  }
}
