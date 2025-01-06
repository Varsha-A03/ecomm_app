import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.brown.shade600,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cartItems = cartProvider.cartItems;

          return Column(
            children: [
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(
                        child: Text(
                          "Your cart is empty!",
                          style: TextStyle(fontSize: 16.0, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return ListTile(
                              leading: Image.network(
                                item.image,
                                height: 50.0,
                                width: 50.0,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, StackTrace) =>
                                    const Icon(Icons.error),
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Price: \$${item.price.toStringAsFixed(2)}\nQuantity: ${item.quantity}",
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      cartProvider.removeFromCart(item.id);
                                    },
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    color: Colors.red,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      cartProvider.addToCart(item);
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.green,
                                  ),
                                ],
                              ));
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 1.0, color: Colors.grey),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: cartProvider.cartItems.isNotEmpty
                          ? () {
                              Navigator.pushNamed(context, '/checkout');
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade600,
                      ),
                      child: const Text(
                        "Proceed to Checkout",
                        style: TextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
