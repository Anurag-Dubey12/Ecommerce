import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HorizontalBanner extends StatefulWidget {
  @override
  _HorizontalBannerState createState() => _HorizontalBannerState();
}

class _HorizontalBannerState extends State<HorizontalBanner> {
  final List<String> salesOffers = [
    "50% Off on Electronics!",
    "Big Sale on Jewelry!",
    "Limited Time Offer on Clothing!",
    "Special Discounts for Women's Fashion!",
  ];

  ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(milliseconds: 30), (Timer timer) {
      setState(() {
        _scrollPosition += 1;
        if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0;
        }
        _scrollController.jumpTo(_scrollPosition);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: Offset(0, 3),
        //   ),
        // ],
      ),
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: salesOffers.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              salesOffers[index],
              style: TextStyle(fontSize: 18,color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}