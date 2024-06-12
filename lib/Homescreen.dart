import 'dart:convert';
import 'package:ecommerce_application/ShoppingCart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'CategoryScreen.dart';
import 'OrderHistoryPage.dart';
import 'Widget/CategoryButton.dart';
import 'Widget/HorizontalBanner.dart';

class Homescreen extends StatefulWidget{
  final String token;

  Homescreen({required this.token});
  @override
  State<StatefulWidget> createState()=>home();
}
class home extends State<Homescreen>{
  List<Product> _electronicsProducts = [];
  List<Product> _clothesProducts = [];
  List<Product> _jewelryProducts = [];
  List<Product> _womensProducts = [];
  List<Product> _allProducts = [];

  List<String> categoryname=[
    'electronics',"men's clothing",'jewelery',"women's clothing"
  ];
  TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts("electronics", _electronicsProducts);
    _fetchProducts("men's clothing", _clothesProducts);
    _fetchProducts("jewelery", _jewelryProducts);
    _fetchProducts("women's clothing", _womensProducts);
    _searchController.addListener(_searchProducts);

  }
  Future<void> _fetchProducts(String category, List<Product> productList) async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/category/$category'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        productList.clear();
        productList.addAll(data.map((item) => Product.fromJson(item)).toList());
        _allProducts.addAll(productList);
      });
    }
  }


  Widget _buildProductItem(Product product) {
    return GestureDetector(
      onTap: () {

      },
      child: Container(
        width: 150,
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                product.image,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 5),
            Text(
              product.title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text('\₹ ${convertprice(product.price).toString()}',
                style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
  void _searchProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.title.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query);
      }).toList();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Home Screen'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history_rounded),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => OrderHistoryPage(userToken: widget.token,),
              //   ),
              // );
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "We apologize for the inconvenience. Order history data could not be fetched at the moment. Please try again later."
                      )
                  )
              );

            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString('token');
              if(token!=null){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShoppingCart(token: token),
                ),
              );
              }
            },
          ),
        ],
      ),

      body: _allProducts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: HorizontalBanner(),
            ),
            SizedBox(height: 30),
            Container(
              margin: EdgeInsets.symmetric(horizontal:10),
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CategoryButton(
                      icon: Icons.apps,
                      label: 'All Categories',
                      onPressed: (){},
                    ),
                    SizedBox(width: 10,),
                    CategoryButton(
                      icon: Icons.checkroom,
                      label: 'electronics',
                      onPressed: (){},
                    ),
                    SizedBox(width: 10,),
                    CategoryButton(
                      icon: Icons.fastfood,
                      label: 'jewelery',
                      onPressed: (){},
                    ),
                    SizedBox(width: 10,),
                    CategoryButton(
                      icon: Icons.book,
                      label: "men's clothing",
                      onPressed: (){},
                    ),
                    SizedBox(width: 10,),
                    CategoryButton(
                      icon: Icons.book,
                      label: "women's clothing",
                      onPressed: (){},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/img.png",
                      width: 350,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal:10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Shop Whatever you want and become \n the best version of your",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child:Text("Items To Purchase",
                style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),)
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Electronics",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(category: "electronics"),
                        ),
                      );
                    },
                    child: Text('See All'),
                  ),
                ],
              ),
            ),
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _electronicsProducts.length,
                itemBuilder: (context, index) {
                  return _buildProductItem(_electronicsProducts[index]);
                },
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jewelery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(category: "jewelery"),
                        ),
                      );
                    },
                    child: Text('See All'),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _jewelryProducts.length,
                itemBuilder: (context, index) {
                  return _buildProductItem(_jewelryProducts[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Men's Clothing",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(category: "men's clothing"),
                        ),
                      );
                    },
                    child: Text('See All'),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _clothesProducts.length,
                itemBuilder: (context, index) {
                  return _buildProductItem(_clothesProducts[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Women's Clothing",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoryScreen(category: "women's clothing"),
                        ),
                      );
                    },
                    child: Text('See All'),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _womensProducts.length,
                itemBuilder: (context, index) {
                  return _buildProductItem(_womensProducts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
int convertprice(double dollor){
  int indianrupess;
  double newamt=dollor*83.62;
  indianrupess=newamt.toInt();
  return indianrupess.toInt();

}
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
    );
  }
}



