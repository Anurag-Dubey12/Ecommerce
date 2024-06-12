import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CartItem.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double total;
  final VoidCallback onClearCart;

  CheckoutPage({required this.cartItems, required this.total, required this.onClearCart});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment successful: ${response.paymentId}');
    await _placeOrder(widget.cartItems,widget.total);
    widget.onClearCart();
    _showOrderPlacedDialog(context);
  }
  Future<void> _placeOrder(List<CartItem> cartItems, double total) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      if (token != null && token.isNotEmpty) {
        await FirebaseFirestore.instance.collection('orders').doc(token).set({
          'userId': token,
          'total': total,
          'items': cartItems.map((item) => {
            'name': item.name,
            'price': item.price,
            'quantity': item.quantity,
            'imagePath': item.imagePath,
          }).toList(),
          'timestamp': Timestamp.now(),
        });
      } else {
        throw Exception('User token is null or empty');
      }
    } catch (e) {
      print('Error placing order: $e');
    }
  }


  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment error: ${response.code} - ${response.message}');
    _showPaymentErrorDialog(context);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet: ${response.walletName}');
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_6ALJzRFk7QdVEe',
      'amount': (widget.total * 100).toInt(),
      'name': 'Ecommerce Application',
      'description': 'Payment for your order',
      'prefill': {'contact': '9004040592', 'email': 'test@example.com'},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: ${e.toString()}');
    }
  }

  void _showOrderPlacedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Placed'),
        content: Text('Your order has been placed successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Error'),
        content: Text('Oops! Something went wrong with the payment. Please try again later.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Image.network(item.imagePath, width: 50, height: 50),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text('₹${convertprice(item.price)} x ${item.quantity}'),
                                  ],
                                ),
                              ),
                              Text('₹${convertprice(item.price) * item.quantity}'),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${convertprice(widget.total)}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Shipping Details',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
                validator: (value){
                  if(value!.isEmpty ){
                    return 'Please Enter Name';
                  }
                  else{
                    return null;
                  }
                },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value){
                if(value!.isEmpty ){
                  return 'Please Enter Address';
                }
                else{
                  return null;
                }
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value){
                if(value!.isEmpty || value.length < 10  ){
                  return 'Please Enter Valid Phone Number';
                }
                else{
                  return null;
                }
              },
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _openCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                  textStyle: TextStyle(fontSize: 20),
                ),
                child: Text(
                  'Pay Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  int convertprice(double dollar) {
    int indianRupees;
    double newAmt = dollar * 83.62;
    indianRupees = newAmt.toInt();
    return indianRupees.toInt();
  }
}