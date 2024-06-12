import 'package:flutter/material.dart';

class CategoryProduct {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;

  CategoryProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });

  factory CategoryProduct.fromJson(Map<String, dynamic> json) {
    return CategoryProduct(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
    );
  }
}
