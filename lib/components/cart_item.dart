/// CartItem
/// A model class to represent a product added to the cart.
/// Includes fields for the product ID, title, price, quantity, and image URL.
class CartItem {
  final int id; // Unique identifier for the product
  final String title; // Name of the product
  final double price; // Price of the product
  final String image; // Image URL of the product
  int quantity; // Quantity of the product in the cart

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  /// Converts the CartItem object to JSON format for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'image': image,
      'quatity': quantity,
    };
  }

  /// Creates a CartItem object from JSON data
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      quantity: (json['quantity'] ?? 1) as int, // default quanitity if null
    );
  }
}
