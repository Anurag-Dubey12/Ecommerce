// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'CartProvider.dart';
//
// class CartScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Cart'),
//       ),
//       body: Consumer<CartProvider>(
//         builder: (context, cart, child) {
//           return Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: cart.cartItems.length,
//                   itemBuilder: (context, index) {
//                     final product = cart.cartItems[index];
//                     return ListTile(
//                       leading: Image.network(product.image),
//                       title: Text(product.title),
//                       subtitle: Text('\$${product.price}'),
//                       trailing: IconButton(
//                         icon: Icon(Icons.remove_circle),
//                         onPressed: () {
//                           Provider.of<CartProvider>(context, listen: false)
//                               .removeFromCart(product); // Use Provider.of to access the CartProvider
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text('Total: \$${cart.totalPrice}', style: TextStyle(fontSize: 20)),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   // Handle checkout logic
//                 },
//                 child: Text('Checkout'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
