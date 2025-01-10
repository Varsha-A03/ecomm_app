import 'package:ecomm_app/providers/cart_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_service.dart';
import 'product_detail_page.dart';
import '../components/productcard.dart';
import '../pages/wishlistpage.dart';
import '../providers/wishlist_provider.dart';

/// Homepage - Displays a list of products, sorting and filtering options,
/// search functionality, and the ability to add items to the cart or wishlist.
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    _fetchAllProducts(); // initial fetch
    _scrollController
        .addListener(_handleScroll); // Attach infinite scroll listener

    // load wishlist items
    Provider.of<WishlistProvider>(context, listen: false).loadWishlistItems();
    Provider.of<CartProvider>(context, listen: false).loadCartItems();
  }

  final ApiService _apiService = ApiService();
  final List<dynamic> _allProducts = []; // All products fetched from API
  final List<dynamic> _products = []; // Products currently displayed
  int _page = 1; //current page
  bool _isLoading = false; // Whether more data is being loaded
  final int _limit = 10; // Number of products per page
  bool _hasMoreProducts = true;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode(); // add focus node

  final List<String> _categories = [
    "All",
    "electronics",
    "jewelery",
    "men's clothing",
    "women's clothing",
  ];

  String? _selectedCategory = 'All'; // default category
  RangeValues _priceRange = const RangeValues(0, 1000); // Default price range
  double _selectedRating = 0.0; // default rating filter
  List<dynamic> _filteredProducts = [];

  String _selectedSortCriteria = "Price (Low to High)";

  @override
  void dispose() {
    _searchFocusNode.dispose(); // dispose focusnode
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetches all products from the API
  Future<void> _fetchAllProducts() async {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true; // Set _isLoading to true before the api
    });

    // Update _allProducts and set the initial page of _products
    try {
      final List<dynamic> fetchedProducts =
          await _apiService.fetchAllProducts();
      setState(() {
        _allProducts.addAll(fetchedProducts);
        if (_allProducts.isNotEmpty) {
          // Load the first page directly
          _products.addAll(_allProducts.sublist(0, _limit));
          _page = 2; // Set the next page
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Fetches additional products for infinite scrolling
  void _fetchPaginatedProducts() {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // simulate pagination
    setState(() {
      if (_products.length >= _allProducts.length && _allProducts.isNotEmpty) {
        // if products fetched finishes reuse the products again
        _products.addAll(_allProducts);
      } else {
        // load paginated products
        final int startIndex = (_page - 1) * _limit;
        final int endIndex = startIndex + _limit;

        if (startIndex < _allProducts.length) {
          _products.addAll(_allProducts.sublist(
            startIndex,
            endIndex > _allProducts.length ? _allProducts.length : endIndex,
          ));
          _page++; // increment page for the next fetch
        } else {
          _hasMoreProducts = false; //  No more products to load
        }
      }
      _isLoading = false;
    });
  }

  /// Handles infinite scrolling
  void _handleScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchPaginatedProducts();
    }
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = List.from(_products);
      });
      return;
    }
    final searchedProducts = _filteredProducts.where((product) {
      final title = product['title'].toLowerCase();
      final searchQuery = query.toLowerCase();
      return title.contains(searchQuery);
    }).toList();

    setState(() {
      _filteredProducts = searchedProducts;
    });
  }

  void _applySorting(String? criteria) {
    setState(() {
      _selectedSortCriteria = criteria ?? "None";

      // Apply sorting to the filtered products
      _applySortingToFilteredProducts();
    });
  }

  // sorting logic
  void _applySortingToFilteredProducts() {
    List<dynamic> sortedProducts =
        _filteredProducts.isEmpty ? List.from(_products) : _filteredProducts;
    try {
      if (_selectedSortCriteria == "Price (Low to High)" ||
          _selectedSortCriteria == "None") {
        sortedProducts.sort((a, b) => a['price'].compareTo(b['price']));
      } else if (_selectedSortCriteria == "Price (High to Low)") {
        sortedProducts.sort((a, b) => b['price'].compareTo(a['price']));
      } else if (_selectedSortCriteria == "Most Reviewed") {
        sortedProducts.sort(
            (a, b) => b['rating']['count'].compareTo(a['rating']['count']));
      } else if (_selectedSortCriteria == "Highest Rated") {
        sortedProducts
            .sort((a, b) => b['rating']['rate'].compareTo(a['rating']['rate']));
      }

      setState(() {
        _filteredProducts = sortedProducts;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error applying sorting.")),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategory == "All" ||
            product['category'] == _selectedCategory;
        final withinPriceRanges = product['price'] >= _priceRange.start &&
            product['price'] <= _priceRange.end;
        final matchesRating = product['rating']['rate'] >= _selectedRating;

        return matchesCategory && withinPriceRanges && matchesRating;
      }).toList();
      // After filtering, apply sorting to the filtered list
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _priceRange = const RangeValues(0, 1000);
      _selectedRating = 0.0;
      _filteredProducts = List.from(_products);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Filters reset!")),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter by Category
                const Text(
                  'Filter by Category',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: [
                    "All",
                    "electronics",
                    "jewelery",
                    "men's clothing",
                    "women's clothing"
                  ].map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category[0].toUpperCase() + category.substring(1),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                // Price range slider
                const Text(
                  'Filter by Price Range',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 1000,
                  divisions: 10,
                  labels: RangeLabels(
                    '\$${_priceRange.start.round()}',
                    '\$${_priceRange.end.round()}',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _priceRange = values;
                    });
                  },
                ),
                // Rating Slider
                const SizedBox(height: 16),
                const Text(
                  'Filter by Rating',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _selectedRating,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  label: _selectedRating.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _selectedRating = value;
                    });
                  },
                ),
                // Apply Filters Button
                ElevatedButton(
                  onPressed: () {
                    _applyFilters(); // Apply all filters
                    Navigator.pop(context); // Close the modal
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade600,
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
                TextButton(onPressed: _resetFilters, child: Text('None')),
              ],
            ),
          );
        });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

// load wishlist items
  void _toggleWishlist(dynamic product) {
    final wishlistProvider =
        Provider.of<WishlistProvider>(context, listen: false);
    wishlistProvider.toggleWishlist(product);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;
    final isDesktop = screenWidth > 1024;

    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 4.0,
            backgroundColor: Colors.brown.shade600,
            iconTheme: IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () {
                  // navigate to cart page
                  Navigator.pushNamed(context, '/cartpage');
                },
                icon: const Icon(Icons.shopping_cart),
              ),
              PopupMenuButton<String?>(
                onSelected: _applySorting,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: "None", child: Text('None')),
                  const PopupMenuItem(
                      value: 'Price (Low to High)',
                      child: Text('Sort by Price(Low to High)')),
                  const PopupMenuItem(
                      value: 'Price (High to Low)',
                      child: Text('Sort by Price(High to Low)')),
                  const PopupMenuItem(
                      value: 'Most Reviewed', child: Text('Most Reviewed')),
                  const PopupMenuItem(
                      value: 'Highest Rated', child: Text('Highest Rated')),
                ],
              ),
            ],
          ),
          drawer: Drawer(
            backgroundColor: Color(0xFFF6ECE3),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.brown.shade600),
                  child:
                      const Text('Menu', style: TextStyle(color: Colors.white)),
                ),
                ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text(
                      'Wishlist',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WishlistPage(
                                  wishlist: wishlistProvider.wishlistItems)));
                    }),
                ListTile(
                  leading: const Icon(Icons.arrow_back),
                  title: const Text(
                    'Back',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text(
                    'Logout',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('authToken');
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showFilterOptions,
            child: const Icon(Icons.filter_alt),
          ),
          body: Column(children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 56.0),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context)
                        .unfocus(); // Dismiss any active input focus
                  },
                  child: TextField(
                    onChanged: _searchProducts,
                    mouseCursor: SystemMouseCursors.text,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Category nav bar
            Container(
              height: 50.0,
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: ScrollConfiguration(
                behavior: ScrollBehavior().copyWith(
                  scrollbars: false,
                  dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                  },
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return GestureDetector(
                        onTap: () => _filterByCategory(category),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          margin: const EdgeInsets.only(right: 8.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.brown.shade600
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Text(
                              category[0].toUpperCase() + category.substring(1),
                              style: TextStyle(
                                fontSize: 15.0,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            // Product grid
            Expanded(
              child: _products.isEmpty
                  ? Center(
                      child: Text(
                        'No products found. Wait Till the products load or try adjusting your filters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop
                              ? 4
                              : isTablet
                                  ? 3
                                  : 2, // Adaptive column count,
                          mainAxisSpacing:
                              isDesktop ? 16.0 : 2.0, // spacing between rows
                          crossAxisSpacing:
                              isDesktop ? 16.0 : 2.0 // spacing between products
                          ),
                      itemCount: (_filteredProducts.isNotEmpty
                              ? _filteredProducts.length
                              : _products.length) +
                          (_hasMoreProducts ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >=
                            (_filteredProducts.isNotEmpty
                                ? _filteredProducts.length
                                : _products.length)) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final product = _filteredProducts.isNotEmpty
                            ? _filteredProducts[index]
                            : _products[index];
                        final isWishlisted =
                            wishlistProvider.isWishlisted(product);
                        return Productcard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailPage(product: product),
                              ),
                            );
                          },
                          onWishlistToggle: () => _toggleWishlist(product),
                          isWishlisted: isWishlisted,
                        );
                      },
                    ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ]),
        ));
  }
}
