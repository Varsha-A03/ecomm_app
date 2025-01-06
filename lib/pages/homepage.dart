import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import 'product_detail_page.dart';
import '../components/productcard.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
    'Electronics',
    'Fashion',
    'Books',
    'Home',
    'Beauty'
  ];

  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 1000); // Default price range
  double _selectedRating = 0.0; // default rating filter
  List<dynamic> _filteredProducts = [];

  String _selectedSortCriteria = "Price (Low to High)";

  @override
  void initState() {
    super.initState();
    _fetchAllProducts(); // initial fetch
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchFocusNode.dispose(); // dispose focusnode
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllProducts() async {
    if (_isLoading) {
      print("Already loading data, skipping fetch.");
      return;
    }
    setState(() {
      _isLoading = true; // Set _isLoading to true before the api
    });

    print("Fetching products... Page: $_page");
    // Update _allProducts and set the initial page of _products
    try {
      final List<dynamic> fetchedProducts =
          await _apiService.fetchAllProducts();
      print("Total products fetched: ${fetchedProducts.length}");
      setState(() {
        _allProducts.addAll(fetchedProducts);
        if (_allProducts.isNotEmpty) {
          // Load the first page directly
          _products.addAll(_allProducts.sublist(0, _limit));
          _page = 2; // Set the next page
        }
      });
    } catch (error) {
      print("Error fetching products: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      print("Loading state set to false.");
    }
  }

  void _fetchPaginatedProducts() {
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // if starting index exceeds total products , stop loading

    // simulate pagination
    setState(() {
      if (_products.length >= _allProducts.length && _allProducts.isNotEmpty) {
        // if products fetched finishes reuse the products again
        _products.addAll(_allProducts);
        print("reusing");
      } else {
        // load paginated products
        final int startIndex = (_page - 1) * _limit;
        final int endIndex = startIndex + _limit;
        print(
            "startIndex: $startIndex, endIndex: $endIndex, total: ${_allProducts.length}");

        if (startIndex < _allProducts.length) {
          _products.addAll(_allProducts.sublist(
            startIndex,
            endIndex > _allProducts.length ? _allProducts.length : endIndex,
          ));
          print(
              "Current paginated products: ${_products.length}, total: ${_allProducts.length}");
          _page++; // increment page for the next fetch
        } else {
          _hasMoreProducts = false; //  No more products to load
          print("No more products to load even after reuse ");
        }
      }
      _isLoading = false;
    });
  }

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

  // sorting logic
  void _applySorting(String criteria) {
    setState(() {
      _selectedSortCriteria = criteria;
    });
    List<dynamic> sortedProducts = [..._products];
    if (criteria == "Price (Low to High)") {
      sortedProducts.sort((a, b) => a['price'].compareTo(b['price']));
    } else if (criteria == "Price (High to Low)") {
      sortedProducts.sort((a, b) => b['price'].compareTo(a['price']));
    } else if (criteria == "Popularity") {
      sortedProducts
          .sort((a, b) => b['rating']['count'].compareTo(a['rating']['count']));
    } else if (criteria == "Rating") {
      sortedProducts
          .sort((a, b) => b['rating']['rate'].compareTo(a['rating']['rate']));
    }

    setState(() {
      _filteredProducts = sortedProducts;
    });
    Navigator.pop(context); // close popup
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesCategory = _selectedCategory == null ||
            product['category'] == _selectedCategory;
        final withinPriceRanges = product['price'] >= _priceRange.start &&
            product['price'] <= _priceRange.end;
        final matchesRating = product['rating']['rate'] >= _selectedRating;

        return matchesCategory && withinPriceRanges && matchesRating;
      }).toList();
    });
    Navigator.pop(context); // close drawer
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _priceRange = const RangeValues(0, 1000);
      _selectedRating = 0.0;
      _filteredProducts = List.from(_products);
    });
    Navigator.pop(context);
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
                // Category filter
                const Text(
                  'Filter by Category',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                DropdownButton(
                  hint: const Text('Select Category'),
                  value: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                        value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 16),
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
                      _applyFilters();
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
                      _applyFilters();
                    });
                  },
                ),
                TextButton(onPressed: _resetFilters, child: Text('None')),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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
                icon: const Icon(Icons.shopping_cart)),
            PopupMenuButton<String>(
              position: PopupMenuPosition.over,
              offset: Offset(-50, 0),
              onSelected: _applySorting,
              itemBuilder: (context) => [
                const PopupMenuItem(value: null, child: Text('None')),
                const PopupMenuItem(
                    value: 'Price (Low to High)',
                    child: Text('Sort by Price(Low to High)')),
                const PopupMenuItem(
                    value: 'Price (High to Low)',
                    child: Text('Sort by Price(High to Low)')),
                const PopupMenuItem(
                    value: 'Rating', child: Text('Sort by Rating')),
                const PopupMenuItem(
                    value: 'Popularity', child: Text('Sort by Popularity')),
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
                leading: const Icon(Icons.arrow_back),
                title: const Text(
                  'Back',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchProducts,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty && _products.isEmpty
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 2.0, // spacing between rows
                            crossAxisSpacing: 2.0 // spacing between products
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
      ),
    );
  }
}
