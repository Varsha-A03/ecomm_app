import 'package:flutter/foundation.dart';
import '../components/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  // Get all cart items
  List<CartItem> get cartItems => _cartItems;

  // Get total price
  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  // Add product to cart
  void addToCart(CartItem item) {
    final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (index != -1) {
      _cartItems[index].quantity++;
    } else {
      _cartItems.add(item);
    }
    notifyListeners();
  }

  // Remove product from cart
  void removeFromCart(int itemId) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      // decrease quantity
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        // remove if quantity is zero
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }
}
