import 'package:flutter/material.dart';
import '../api_service.dart';
import 'product_detail_page.dart';

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

  final FocusNode _searchFocusNode = FocusNode(); // add focus node
  @override
  void dispose() {
    _searchFocusNode.dispose(); // dispose focusnode
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchAllProducts(); // initial fetch
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
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        if (_products.length >= _allProducts.length &&
            _allProducts.isNotEmpty) {
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
    });
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _products.clear();
        _products.addAll(_allProducts.sublist(0, _limit));
      });
      return;
    }
    final filteredProducts = _allProducts.where((product) {
      final title = product['title'].toLowerCase();
      final searchQuery = query.toLowerCase();
      return title.contains(searchQuery);
    }).toList();

    setState(() {
      _products.clear();
      _products.addAll(filteredProducts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          focusNode: _searchFocusNode,
          decoration: const InputDecoration(
            contentPadding: EdgeInsetsDirectional.only(start: 25.0),
            hintText: 'Search Products...',
            hintStyle: TextStyle(
                fontStyle: FontStyle.italic, color: Color(0xFFF6ECE3)),
            border: InputBorder.none,
          ),
          style: TextStyle(
            color:
                _searchFocusNode.hasFocus ? Color(0xFFF6ECE3) : Colors.white70,
            fontSize: 16.0,
            fontStyle: FontStyle.italic,
          ),
          onChanged: (value) {
            _searchProducts(value);
          },
        ),
        elevation: 4.0,
        backgroundColor: Colors.brown.shade600,
        iconTheme: IconThemeData(color: Colors.white10),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          print(
              "ScrollNotification detected. pixels: ${scrollInfo.metrics.pixels}, Max: ${scrollInfo.metrics.maxScrollExtent}");
          print("_isLoading: $_isLoading, _hasMoreProducts: $_hasMoreProducts");
          print(
              "Near bottom condition: ${scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100}");
          if (!_isLoading &&
              _hasMoreProducts &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 100) {
            print("Reached near bottom, fetching more products...");
            _fetchPaginatedProducts(); // Fetch the next page when reaching the bottom
          }
          return false;
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 2.0, // spacing between rows
                crossAxisSpacing: 2.0 // spacing between products
                ),
            itemCount: _products.length + (_hasMoreProducts ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _products.length && _hasMoreProducts) {
                // Show loading indicator at the bottom of the list
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final product = _products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
                child: Container(
                  key:
                      ValueKey(product['id']), // Use a unique key for each item
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color.fromARGB(208, 255, 255, 255),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          offset: const Offset(5.0, 5.0),
                          blurRadius: 9.0,
                          spreadRadius: 2.0,
                        ),
                      ]),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 5.0),
                  padding: const EdgeInsets.only(top: 25.0, bottom: 10.0),
                  child: Column(
                    // for the image and title , price to be in a column
                    children: [
                      ClipRRect(
                        // for rounded contaner

                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          product['image'],
                          height: 80.0,
                          width: 80.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          // for title and price
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // align.left
                          children: [
                            SizedBox(
                              width: 150,
                              child: Text(product['title'],
                                  style: const TextStyle(
                                    fontFamily: 'rubik',
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ),
                            Text(
                              '\$${product['price']}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
