  import 'dart:convert';

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'CartItem.dart';
  import 'CheckoutPage.dart';
  import 'DatabaseHelper.dart';
  import 'Widget/CartItemWidget.dart';

  class ShoppingCart extends StatefulWidget {
    final String? token;
    final List<CartItem>? cartItems;

    ShoppingCart({this.cartItems,this.token});

    @override
    _ShoppingCartState createState() => _ShoppingCartState();
  }

  class _ShoppingCartState extends State<ShoppingCart> {
    List<CartItem> cartItems = [];

    @override
    void initState() {
      super.initState();
      cartItems = widget.cartItems ?? [];
      _loadCartItems();

    }
    void _loadCartItems() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final snapshot = await FirebaseFirestore.instance.collection('cart').doc(widget.token).get();
        final data = snapshot.data();
        if (data != null && data['items'] != null) {
          final List<dynamic> items = data['items'];
          setState(() {
            cartItems = items.map((item) {
              return CartItem(
                item['id'],
                item['title'],
                item['price'],
                item['image'],
                item['quantity'],
              );
            }).toList();
          });
        }
      }
    }
    void _removeItem(int index) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token != null) {
        await FirebaseFirestore.instance.collection('cart').doc(token).update({
          'items': FieldValue.arrayRemove([
            cartItems[index].toMap(),
          ])
        });
      }

      setState(() {
        cartItems.removeAt(index);
      });
    }

    void _increaseQuantity(int index) async {
      setState(() {
        cartItems[index].quantity++;
      });

      _updateCartItemInFirestore(cartItems[index]);
    }

    void _decreaseQuantity(int index) async {
      if (cartItems[index].quantity > 1) {
        setState(() {
          cartItems[index].quantity--;
        });

        _updateCartItemInFirestore(cartItems[index]);
      }
    }

    void _updateCartItemInFirestore(CartItem item) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token != null) {
        List<Map<String, dynamic>> updatedItems = [];

        for (var cartItem in cartItems) {
          if (cartItem.productId == item.productId) {
            cartItem.quantity = item.quantity;
            updatedItems.add(cartItem.toMap());
          } else {
            updatedItems.add(cartItem.toMap());
          }
        }
        if (!cartItems.any((cartItem) => cartItem.productId == item.productId)) {
          updatedItems.add({
            'id': item.productId,
            'name': item.name,
            'price': item.price,
            'imagePath': item.imagePath,
            'quantity': item.quantity,
          });
        }
        await FirebaseFirestore.instance.collection('cart').doc(token).update({
          'items': updatedItems,
        });

        setState(() {
          cartItems = updatedItems.map((item) => CartItem(
            item['id'],
            item['name'],
            item['price'],
            item['imagePath'],
            item['quantity'],
          )).toList();
        });
      }
    }


    void _clearCart() {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('cart');
        setState(() {
          cartItems.clear();
        });
      });
    }

    int convertprice(double dollar) {
      int indianRupees;
      double newAmt = dollar * 83.62;
      indianRupees = newAmt.toInt();
      return indianRupees.toInt();
    }

    @override
    Widget build(BuildContext context) {
      double total = cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('My Cart'),
          backgroundColor: Colors.white,
        ),
        body: cartItems.isEmpty
            ? Center(
          child: Text(
            "Your Cart is Empty\nPlease Add something",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        )
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return CartItemWidget(
                    item: cartItems[index],
                    onRemove: () => _removeItem(index),
                    onIncreaseQuantity: () => _increaseQuantity(index),
                    onDecreaseQuantity: () => _decreaseQuantity(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '₹$total',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(
                      cartItems: cartItems,
                      total: total,
                      onClearCart: _clearCart,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text(
                'Buy Now',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }