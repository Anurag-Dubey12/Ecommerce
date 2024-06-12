import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DatabaseHelper.dart';
import 'OrderData.dart';
import 'package:iconsax/iconsax.dart';

class OrderHistoryPage extends StatefulWidget {
  final String userToken;

  OrderHistoryPage({required this.userToken});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late Future<List<OrderData>> _orderList;

  @override
  void initState() {
    super.initState();
    _orderList = _fetchOrders();
  }

  Future<List<OrderData>> _fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: token)
          .get();

      print('Fetched ${querySnapshot.docs.length} orders');

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('Order data: $data');
        return OrderData(
          id: int.parse(doc.id),
          itemName: data['items'][0]['name'],
          quantity: data['items'][0]['quantity'],
          itemPrice: data['items'][0]['price'],
          orderDate: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to fetch orders');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: FutureBuilder<List<OrderData>>(
        future: _orderList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text(order.itemName),
                  leading: Icon(Icons.shopping_bag),
                  subtitle: Text('Quantity: ${order.quantity} | Price: ₹${order.itemPrice.toStringAsFixed(2)}'),
                  trailing: Text(
                    '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}