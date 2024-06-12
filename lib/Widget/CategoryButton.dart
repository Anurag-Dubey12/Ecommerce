import 'package:ecommerce_application/CategoryScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget{
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  CategoryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.teal,
          child: IconButton(
            icon: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              if(label.contains("All Categories",0)){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryScreen(category: "products"),
                  ),
                );
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(category: label),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}