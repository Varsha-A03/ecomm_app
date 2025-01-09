import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// WishlistProvider
/// Manages the state of the wishlist, including adding/removing items and persisting data using SharedPreferences.
class WishlistProvider with ChangeNotifier {
  final List<dynamic> _wishlistItems = [];

  /// Getter for all wishlist items
  List<dynamic> get wishlistItems => _wishlistItems;

  /// Load wishlist items from SharedPreferences when the app starts

  Future<void> loadWishlistItems() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistData = prefs.getString('wishlistItems');
    if (wishlistData != null) {
      final List<dynamic> decodedData = json.decode(wishlistData);
      _wishlistItems.clear();
      _wishlistItems.addAll(decodedData);
      notifyListeners();
    }
  }

  /// Save wishlist items to SharedPreferences
  Future<void> _saveWishlistItems() async {
    final prefs = await SharedPreferences.getInstance();
    final wishlistData = json.encode(_wishlistItems);
    await prefs.setString('wishlistItems', wishlistData);
  }

  // Add item to wishlist
  void addToWishlist(dynamic item) {
    if (!_wishlistItems
        .any((wishlistItem) => wishlistItem['id'] == item['id'])) {
      _wishlistItems.add(item);
      _saveWishlistItems();
      notifyListeners();
    }
  }

  // remove item from wishlist
  void removeFromWishlist(int itemId) {
    _wishlistItems.removeWhere((item) => item['id'] == itemId);
    _saveWishlistItems();
    notifyListeners();
  }

  /// Add an item to the wishlist
  /// If the item is already in the wishlist, remove it (toggle functionality).
  /// Otherwise, add it to the wishlist.
  void toggleWishlist(dynamic product) {
    if (_wishlistItems.any((item) => item['id'] == product['id'])) {
      removeFromWishlist(product['id']);
    } else {
      addToWishlist(product);
    }
  }

  /// Check if a product is in the wishlist
  bool isWishlisted(dynamic product) {
    return _wishlistItems.any((item) => item['id'] == product['id']);
  }
}
