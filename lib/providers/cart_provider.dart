import 'package:flutter/foundation.dart';
import '../components/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// CartProvider
/// Manages the state of the shopping cart, including adding/removing items and persisting data using SharedPreferences.
class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];

  /// Getter for all cart items
  List<CartItem> get cartItems => _cartItems;

  /// Getter for total price of all items in the cart
  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  /// Load cart items from SharedPreferences when the app starts
  Future<void> loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cartItems');
    if (cartData != null) {
      final List<dynamic> decodedData = json.decode(cartData);
      _cartItems.clear();
      // Map the JSON data to CartItem objects and add them to the list
      _cartItems.addAll(decodedData.map((item) => CartItem.fromJson(item)));
      notifyListeners();
    }
  }

  // save cart items to shared preferences
  Future<void> _saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData =
        json.encode(_cartItems.map((item) => item.toJson()).toList());
    await prefs.setString('cartItems', cartData);
  }

  /// Add a product to the cart
  /// If the product is already in the cart, increment its quantity.
  /// Otherwise, add it as a new item.
  void addToCart(CartItem item) {
    final index = _cartItems.indexWhere((cartItem) => cartItem.id == item.id);
    if (index != -1) {
      _cartItems[index].quantity++;
    } else {
      _cartItems.add(item);
    }
    _saveCartItems();
    notifyListeners();
  }

  /// Remove a product from the cart
  /// If the quantity is more than one, decrement it.
  /// Otherwise, remove the item from the cart.
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
      _saveCartItems();
      notifyListeners();
    }
  }
}
