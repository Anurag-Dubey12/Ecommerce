import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_application/ShoppingCart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CartItem.dart';
import 'CategoryProduct.dart';

class CategoryScreen extends StatefulWidget {
  final String category;

  CategoryScreen({required this.category});

  @override
  State<StatefulWidget> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<CategoryProduct> _products = [];
  Map<int, int> _cart = {};
  String _selectedSortOption = 'Default';
  TextEditingController _searchController = TextEditingController();
  List<CategoryProduct> _filteredProducts = [];

  Map<int, bool> _isItemAdded = {};

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  int _getCartQuantity(int productId) {
    return _cart[productId] ?? 0;
  }

  double _getTotalPrice() {
    double total = 0;
    _cart.forEach((productId, quantity) {
      final product = _products.firstWhere((p) => p.id == productId);
      total += convertprice(product.price) * quantity;
    });
    return total;
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse(
        'https://fakestoreapi.com/products${widget.category == "All Categories" ? '' : '/category/${widget.category}'}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _products = data.map((item) => CategoryProduct.fromJson(item)).toList();
        _filteredProducts = List.from(_products);
      });
    } else {
      print('Failed to fetch products. Status code: ${response.statusCode}');
    }
  }

  void _addToCart(int productId) async {
    setState(() {
      if (_cart.containsKey(productId)) {
        _cart[productId] = _cart[productId]! + 1;
      } else {
        _cart[productId] = 1;
      }
      _isItemAdded[productId] = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      final product = _products.firstWhere((p) => p.id == productId);
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(token)
          .set({
        'items': FieldValue.arrayUnion([
          {
            'id': product.id,
            'title': product.title,
            'price': product.price,
            'image': product.image,
            'quantity': _cart[productId],
          }
        ])
      }, SetOptions(merge: true));
    }
  }
  List<CartItem> _getCartItems() {
    return _cart.entries.map((entry) {
      final product = _products.firstWhere((p) => p.id == entry.key);
      return CartItem(
        product.id,
        product.title,
        convertprice(product.price).toDouble(),
        product.image,
        entry.value,
      );
    }).toList();
  }

  void _sortProducts(String criterion) {
    setState(() {
      if (criterion == 'Price: Low to High') {
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
      } else if (criterion == 'Price: High to Low') {
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
      } else if (criterion == 'Title: A-Z') {
        _filteredProducts.sort((a, b) => a.title.compareTo(b.title));
      } else if (criterion == 'Title: Z-A') {
        _filteredProducts.sort((a, b) => b.title.compareTo(a.title));
      }
    });
  }

  void _filterProducts(String query) {
    final filtered = _products.where((product) {
      final titleLower = product.title.toLowerCase();
      final descriptionLower = product.description.toLowerCase();
      final searchLower = query.toLowerCase();

      return titleLower.contains(searchLower) || descriptionLower.contains(searchLower);
    }).toList();

    setState(() {
      _filteredProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.category),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search Item Here',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                _filterProducts(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownButton<String>(
                  value: _selectedSortOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSortOption = newValue!;
                      _sortProducts(_selectedSortOption);
                    });
                  },
                  items: <String>[
                    'Default',
                    'Price: Low to High',
                    'Price: High to Low',
                    'Title: A-Z',
                    'Title: Z-A',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final quantity = _getCartQuantity(product.id);
                final isItemAdded = _isItemAdded[product.id] ?? false;
                return GestureDetector(
                  onTap: () => _showItemDetails(context, product),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                product.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title + "\n",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _getShortDescription(product.description),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹${convertprice(product.price)} ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isItemAdded)
                              Text("Item Added to Cart")
                            else
                              ElevatedButton(
                                onPressed: () => _addToCart(product.id),
                                child: Text('Add'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.orange[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Icon(LineIcons.shoppingCart),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShoppingCart(
                                cartItems: _getCartItems(),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "View Cart",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(LineIcons.paypal),
                      SizedBox(width: 5),
                      GestureDetector(
                        child: Text(
                          "Total Amount\n ₹${_getTotalPrice().toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShoppingCart(
                                cartItems: _getCartItems(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

int convertprice(double dollar) {
  int indianRupees;
  double newAmt = dollar * 83.62;
  indianRupees = newAmt.toInt();
  return indianRupees.toInt();
}

void _showItemDetails(BuildContext context, CategoryProduct product) {
  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          height: MediaQuery.of(context).size.height * 0.85,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Description: ${product.description}',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Price: \$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16),
                      ),
                      // Add more details as needed
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _getShortDescription(String description) {
  const maxLength = 50;
  if (description.length <= maxLength) {
    return description;
  } else {
    return description.substring(0, maxLength) + '...';
  }
}