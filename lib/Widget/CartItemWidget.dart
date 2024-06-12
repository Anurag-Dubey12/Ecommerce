import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../CartItem.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncreaseQuantity;
  final VoidCallback onDecreaseQuantity;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${item.price}',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: onDecreaseQuantity,
              ),
              Text(
                '${item.quantity}',
                style: TextStyle(fontSize: 16),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: onIncreaseQuantity,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}