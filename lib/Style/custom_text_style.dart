import 'package:flutter/material.dart';

class CustomTextStyle {

  static final TextStyle itemInfo = TextStyle(
    color: Colors.black87,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle itemPrice = TextStyle(
    color: Colors.green[800],
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static TextStyle getDetailedItemPriceStyle(BuildContext context) {

    return TextStyle(
      color: Theme.of(context).primaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );
  }
}